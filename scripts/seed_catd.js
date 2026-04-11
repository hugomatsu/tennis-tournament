/**
 * Seed script for 5ª Liga Tênis — Cat D (Americano)
 * Tournament ID: 6ddb6dfc-1677-40e1-9eb3-abe50be54ee9
 *
 * Usage:
 *   1. Save Firebase service account key as scripts/service-account.json
 *   2. Run: node scripts/seed_catd.js
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
const CATEGORY_NAME = 'Cat D';
const CATEGORY_TYPE = 'singles';
const MATCH_DURATION = 90;

// Note: "Eduardo" here is the player from Group D (Eduardo Barbosa is the separate Group B player)
const GROUPS = {
  A: ['Marcelo', 'Thais Miura', 'José Luiz', 'Juliane'],
  B: ['Wesley', 'Henrique', 'Rebeca Medri', 'Eduardo Barbosa'],
  C: ['Júlio', 'Paulo Fraga', 'Luisa Neiva', 'Victor Hugo'],
  D: ['Eduardo (D)', 'Brenda', 'Jansen', 'Leticia'],
  E: ['Bruno', 'José Victor', 'Estéfani', 'Élio'],
};

// 50 unique cross-group matches (20 players × 5 each / 2)
const MATCHES = [
  // Group A cross-group
  ['Marcelo', 'Wesley'],
  ['Marcelo', 'Henrique'],
  ['Marcelo', 'Júlio'],
  ['Marcelo', 'Eduardo (D)'],
  ['Marcelo', 'Bruno'],
  ['Thais Miura', 'Wesley'],
  ['Thais Miura', 'Júlio'],
  ['Thais Miura', 'Paulo Fraga'],
  ['Thais Miura', 'Jansen'],
  ['Thais Miura', 'Estéfani'],
  ['José Luiz', 'Rebeca Medri'],
  ['José Luiz', 'Luisa Neiva'],
  ['José Luiz', 'Eduardo (D)'],
  ['José Luiz', 'Brenda'],
  ['José Luiz', 'Élio'],
  ['Juliane', 'Eduardo Barbosa'],
  ['Juliane', 'Victor Hugo'],
  ['Juliane', 'Leticia'],
  ['Juliane', 'Bruno'],
  ['Juliane', 'José Victor'],
  // Group B new cross-group
  ['Wesley', 'Paulo Fraga'],
  ['Wesley', 'Brenda'],
  ['Wesley', 'José Victor'],
  ['Henrique', 'Paulo Fraga'],
  ['Henrique', 'Júlio'],
  ['Henrique', 'Eduardo (D)'],
  ['Henrique', 'Estéfani'],
  ['Rebeca Medri', 'Luisa Neiva'],
  ['Rebeca Medri', 'Brenda'],
  ['Rebeca Medri', 'Jansen'],
  ['Rebeca Medri', 'Élio'],
  ['Eduardo Barbosa', 'Victor Hugo'],
  ['Eduardo Barbosa', 'Leticia'],
  ['Eduardo Barbosa', 'José Victor'],
  ['Eduardo Barbosa', 'Bruno'],
  // Group C new cross-group
  ['Júlio', 'Jansen'],
  ['Júlio', 'Estéfani'],
  ['Paulo Fraga', 'Eduardo (D)'],
  ['Paulo Fraga', 'Bruno'],
  ['Luisa Neiva', 'Jansen'],
  ['Luisa Neiva', 'Brenda'],
  ['Luisa Neiva', 'Élio'],
  ['Victor Hugo', 'Leticia'],
  ['Victor Hugo', 'Estéfani'],
  ['Victor Hugo', 'José Victor'],
  // Group D new cross-group
  ['Eduardo (D)', 'Élio'],
  ['Brenda', 'José Victor'],
  ['Jansen', 'Estéfani'],
  ['Leticia', 'Élio'],
  ['Leticia', 'Bruno'],
];

async function seed() {
  console.log('🎾  Seeding Cat D for tournament', TOURNAMENT_ID);

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
    playersCount: admin.firestore.FieldValue.increment(20),
  });

  await participantBatch.commit();
  console.log('✅  20 participants created');

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
  console.log('✅  20 group standings created (Groups A–E)');

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
