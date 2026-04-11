/**
 * Seed script for 5ª Liga Tênis — Cat B (Americano)
 * Tournament ID: 6ddb6dfc-1677-40e1-9eb3-abe50be54ee9
 *
 * Usage:
 *   1. Save Firebase service account key as scripts/service-account.json
 *   2. Run: node scripts/seed_catb.js
 */

const admin = require('../functions/node_modules/firebase-admin');
const { randomUUID } = require('crypto');

let serviceAccount;
try {
  serviceAccount = require('./service-account.json');
} catch {
  console.error('❌  Service account not found at scripts/service-account.json');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const TOURNAMENT_ID = '6ddb6dfc-1677-40e1-9eb3-abe50be54ee9';
const CATEGORY_NAME = 'Cat B';
const CATEGORY_TYPE = 'singles';
const MATCH_DURATION = 90;

const GROUPS = {
  A: ['Gustavo Fogaça', 'Maranzato', 'Ronaldo B.', 'João Soller'],
  B: ['Alan Mota', 'Daniel Amorim', 'André', 'Guilherme Eik'],
  C: ['Vincent', 'Ronaldo', 'Léo Campos', 'Danilo Oliveira'],
  D: ['Danilo Gomes', 'Paulo Alves', 'Marco Miranda', 'Alexandre M Rocha'],
};

// 40 unique cross-group matches (16 players × 5 each / 2)
const MATCHES = [
  // Group A cross-group
  ['Gustavo Fogaça', 'Alan Mota'],
  ['Gustavo Fogaça', 'Daniel Amorim'],
  ['Gustavo Fogaça', 'Vincent'],
  ['Gustavo Fogaça', 'Ronaldo'],
  ['Gustavo Fogaça', 'Danilo Gomes'],
  ['Maranzato', 'André'],
  ['Maranzato', 'Guilherme Eik'],
  ['Maranzato', 'Léo Campos'],
  ['Maranzato', 'Danilo Oliveira'],
  ['Maranzato', 'Paulo Alves'],
  ['Ronaldo B.', 'Alan Mota'],
  ['Ronaldo B.', 'André'],
  ['Ronaldo B.', 'Vincent'],
  ['Ronaldo B.', 'Marco Miranda'],
  ['Ronaldo B.', 'Alexandre M Rocha'],
  ['João Soller', 'Daniel Amorim'],
  ['João Soller', 'Guilherme Eik'],
  ['João Soller', 'Ronaldo'],
  ['João Soller', 'Marco Miranda'],
  ['João Soller', 'Alexandre M Rocha'],
  // Group B new cross-group
  ['Alan Mota', 'Léo Campos'],
  ['Alan Mota', 'Danilo Oliveira'],
  ['Alan Mota', 'Danilo Gomes'],
  ['Daniel Amorim', 'Vincent'],
  ['Daniel Amorim', 'Paulo Alves'],
  ['Daniel Amorim', 'Alexandre M Rocha'],
  ['André', 'Ronaldo'],
  ['André', 'Danilo Oliveira'],
  ['André', 'Marco Miranda'],
  ['Guilherme Eik', 'Léo Campos'],
  ['Guilherme Eik', 'Danilo Gomes'],
  ['Guilherme Eik', 'Paulo Alves'],
  // Group C new cross-group
  ['Vincent', 'Danilo Gomes'],
  ['Vincent', 'Marco Miranda'],
  ['Ronaldo', 'Paulo Alves'],
  ['Ronaldo', 'Alexandre M Rocha'],
  ['Léo Campos', 'Danilo Gomes'],
  ['Léo Campos', 'Alexandre M Rocha'],
  ['Danilo Oliveira', 'Paulo Alves'],
  ['Danilo Oliveira', 'Marco Miranda'],
];

async function seed() {
  console.log('🎾  Seeding Cat B for tournament', TOURNAMENT_ID);

  const tournamentDoc = await db.collection('tournaments').doc(TOURNAMENT_ID).get();
  if (!tournamentDoc.exists) throw new Error(`Tournament ${TOURNAMENT_ID} not found`);
  const tournamentName = tournamentDoc.data().name;
  console.log('✅  Tournament found:', tournamentName);

  const categoryId = randomUUID();
  await db.collection('tournaments').doc(TOURNAMENT_ID)
    .collection('categories').doc(categoryId).set({
      id: categoryId,
      tournamentId: TOURNAMENT_ID,
      name: CATEGORY_NAME,
      type: CATEGORY_TYPE,
      matchDurationMinutes: MATCH_DURATION,
      description: '',
    });
  console.log('✅  Category created:', categoryId);

  const participantIdByName = {};
  const participantBatch = db.batch();

  for (const [groupId, players] of Object.entries(GROUPS)) {
    for (const name of players) {
      const participantId = randomUUID();
      participantIdByName[name] = participantId;
      const ref = db.collection('tournaments').doc(TOURNAMENT_ID)
        .collection('participants').doc(participantId);
      participantBatch.set(ref, {
        id: participantId,
        name,
        userIds: [],
        avatarUrls: [],
        status: 'approved',
        categoryId,
        joinedAt: admin.firestore.Timestamp.now(),
      });
    }
  }

  participantBatch.update(db.collection('tournaments').doc(TOURNAMENT_ID), {
    playersCount: admin.firestore.FieldValue.increment(16),
  });

  await participantBatch.commit();
  console.log('✅  16 participants created');

  const standingsBatch = db.batch();
  for (const [groupId, players] of Object.entries(GROUPS)) {
    for (const name of players) {
      const standingId = randomUUID();
      standingsBatch.set(
        db.collection('tournaments').doc(TOURNAMENT_ID).collection('standings').doc(standingId),
        {
          id: standingId,
          tournamentId: TOURNAMENT_ID,
          categoryId,
          groupId,
          participantId: participantIdByName[name],
          participantName: name,
          participantUserIds: [],
          participantAvatarUrls: [],
          matchesPlayed: 0,
          wins: 0,
          losses: 0,
          points: 0,
          setsWon: 0,
          setsLost: 0,
          gamesWon: 0,
          gamesLost: 0,
        },
      );
    }
  }
  await standingsBatch.commit();
  console.log('✅  16 group standings created (Groups A–D)');

  const matchBatch = db.batch();
  for (let i = 0; i < MATCHES.length; i++) {
    const [p1Name, p2Name] = MATCHES[i];
    const p1Id = participantIdByName[p1Name];
    const p2Id = participantIdByName[p2Name];
    if (!p1Id) { console.warn('⚠️  Unknown player:', p1Name); continue; }
    if (!p2Id) { console.warn('⚠️  Unknown player:', p2Name); continue; }

    const matchId = randomUUID();
    matchBatch.set(db.collection('matches').doc(matchId), {
      id: matchId,
      tournamentId: TOURNAMENT_ID,
      categoryId,
      categoryName: CATEGORY_NAME,
      tournamentName,
      player1Id: p1Id,
      player1Name: p1Name,
      player1UserIds: [],
      player1AvatarUrls: [],
      player2Id: p2Id,
      player2Name: p2Name,
      player2UserIds: [],
      player2AvatarUrls: [],
      opponentName: p2Name,
      round: 'Americano',
      status: 'Preparing',
      matchIndex: i,
      durationMinutes: MATCH_DURATION,
      score: null,
      winner: null,
      time: null,
      court: null,
      locationId: tournamentDoc.data().locationId ?? null,
      player1Cheers: 0,
      player2Cheers: 0,
      player1Confirmed: false,
      player2Confirmed: false,
    });
  }
  await matchBatch.commit();
  console.log(`✅  ${MATCHES.length} matches created`);

  console.log('\n🏆  Seed complete!');
  console.log('   Category ID:', categoryId);
  console.log('   Matches:', MATCHES.length);
  console.log('   Players:', Object.keys(participantIdByName).length);
}

seed().catch((err) => {
  console.error('❌  Seed failed:', err);
  process.exit(1);
});
