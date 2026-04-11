/**
 * Seed script for 5ª Liga Tênis — Cat C (Americano)
 * Tournament ID: 6ddb6dfc-1677-40e1-9eb3-abe50be54ee9
 *
 * Usage:
 *   1. Download a Firebase service account key from:
 *      Firebase Console → Project Settings → Service accounts → Generate new private key
 *   2. Save it as scripts/service-account.json
 *   3. Run: node scripts/seed_catc.js
 */

const admin = require('../functions/node_modules/firebase-admin');
const { randomUUID } = require('crypto');

const SERVICE_ACCOUNT_PATH = 'service-account.json';

let serviceAccount;
try {
  serviceAccount = require(`./${SERVICE_ACCOUNT_PATH.replace('./', '')}`);
} catch {
  console.error('❌  Service account not found at', SERVICE_ACCOUNT_PATH);
  console.error('    Download it from Firebase Console → Project Settings → Service accounts');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// ─── Configuration ────────────────────────────────────────────────────────────

const TOURNAMENT_ID = '6ddb6dfc-1677-40e1-9eb3-abe50be54ee9';
const CATEGORY_NAME = 'Cat C';
const CATEGORY_TYPE = 'singles';
const MATCH_DURATION = 90;

// ─── Groups ───────────────────────────────────────────────────────────────────

const GROUPS = {
  A: ['Lucas', 'Cristina', 'Bruno', 'Renato'],
  B: ['Romeu', 'João Pedro', 'Adriano', 'Léo Campos'],
  C: ['Rouglas', 'Eduardo Viera', 'Camila', 'Guilherme Teixeira'],
  D: ['Michel', 'Anuar', 'Vitinho', 'Fernando Leite'],
  E: ['André', 'Rodrigo Silva', 'Lucilene', 'Jansen'],
  F: ['Alceu Nakayama', 'Plinio', 'Fernando', 'João Carlos'],
  G: ['Gildo', 'Erick Yokota', 'Alexandre M Rocha', 'Felipe Cafú'],
  H: ['Danilo Gomes', 'Vagner', 'Hugo', 'Guilherme Eik'],
};

// ─── Matches (80 cross-group Americano matches) ───────────────────────────────
// Format: [player1Name, player2Name]

const MATCHES = [
  // Group A cross-group matches
  ['Lucas', 'Romeu'],
  ['Lucas', 'Rouglas'],
  ['Lucas', 'Michel'],
  ['Lucas', 'André'],
  ['Lucas', 'Alceu Nakayama'],
  ['Cristina', 'João Pedro'],
  ['Cristina', 'Eduardo Viera'],
  ['Cristina', 'Anuar'],
  ['Cristina', 'Rodrigo Silva'],
  ['Cristina', 'Plinio'],
  ['Bruno', 'Adriano'],
  ['Bruno', 'Camila'],
  ['Bruno', 'Vitinho'],
  ['Bruno', 'Lucilene'],
  ['Bruno', 'Fernando'],
  ['Renato', 'Léo Campos'],
  ['Renato', 'Guilherme Teixeira'],
  ['Renato', 'Fernando Leite'],
  ['Renato', 'Jansen'],
  ['Renato', 'João Carlos'],
  // Group B new cross-group matches
  ['Romeu', 'Eduardo Viera'],
  ['Romeu', 'Anuar'],
  ['Romeu', 'Rodrigo Silva'],
  ['Romeu', 'Erick Yokota'],
  ['João Pedro', 'Camila'],
  ['João Pedro', 'Vitinho'],
  ['João Pedro', 'Lucilene'],
  ['João Pedro', 'Alexandre M Rocha'],
  ['Adriano', 'Guilherme Teixeira'],
  ['Adriano', 'Fernando Leite'],
  ['Adriano', 'Jansen'],
  ['Adriano', 'Felipe Cafú'],
  ['Léo Campos', 'Rouglas'],
  ['Léo Campos', 'Michel'],
  ['Léo Campos', 'André'],
  ['Léo Campos', 'Gildo'],
  // Group C new cross-group matches
  ['Rouglas', 'Michel'],
  ['Rouglas', 'Plinio'],
  ['Rouglas', 'Danilo Gomes'],
  ['Eduardo Viera', 'Anuar'],
  ['Eduardo Viera', 'Fernando'],
  ['Eduardo Viera', 'Vagner'],
  ['Camila', 'Vitinho'],
  ['Camila', 'João Carlos'],
  ['Camila', 'Hugo'],
  ['Guilherme Teixeira', 'Fernando Leite'],
  ['Guilherme Teixeira', 'Alceu Nakayama'],
  ['Guilherme Teixeira', 'Guilherme Eik'],
  // Group D new cross-group matches
  ['Michel', 'Gildo'],
  ['Michel', 'Vagner'],
  ['Anuar', 'Erick Yokota'],
  ['Anuar', 'Hugo'],
  ['Vitinho', 'Alexandre M Rocha'],
  ['Vitinho', 'Guilherme Eik'],
  ['Fernando Leite', 'Felipe Cafú'],
  ['Fernando Leite', 'Danilo Gomes'],
  // Group E new cross-group matches
  ['André', 'Plinio'],
  ['André', 'Erick Yokota'],
  ['André', 'Hugo'],
  ['Rodrigo Silva', 'Fernando'],
  ['Rodrigo Silva', 'Alexandre M Rocha'],
  ['Rodrigo Silva', 'Guilherme Eik'],
  ['Lucilene', 'João Carlos'],
  ['Lucilene', 'Felipe Cafú'],
  ['Lucilene', 'Danilo Gomes'],
  ['Jansen', 'Alceu Nakayama'],
  ['Jansen', 'Gildo'],
  ['Jansen', 'Vagner'],
  // Group F new cross-group matches
  ['Alceu Nakayama', 'Alexandre M Rocha'],
  ['Alceu Nakayama', 'Danilo Gomes'],
  ['Plinio', 'Felipe Cafú'],
  ['Plinio', 'Vagner'],
  ['Fernando', 'Gildo'],
  ['Fernando', 'Hugo'],
  ['João Carlos', 'Erick Yokota'],
  ['João Carlos', 'Guilherme Eik'],
  // Group G new cross-group matches
  ['Gildo', 'Danilo Gomes'],
  ['Erick Yokota', 'Vagner'],
  ['Alexandre M Rocha', 'Hugo'],
  ['Felipe Cafú', 'Guilherme Eik'],
];

// ─── Main ─────────────────────────────────────────────────────────────────────

async function seed() {
  console.log('🎾  Seeding Cat C for tournament', TOURNAMENT_ID);

  // 1. Fetch tournament
  const tournamentDoc = await db.collection('tournaments').doc(TOURNAMENT_ID).get();
  if (!tournamentDoc.exists) {
    throw new Error(`Tournament ${TOURNAMENT_ID} not found in Firestore`);
  }
  const tournamentName = tournamentDoc.data().name;
  console.log('✅  Tournament found:', tournamentName);

  // 2. Create category
  const categoryId = randomUUID();
  await db
    .collection('tournaments')
    .doc(TOURNAMENT_ID)
    .collection('categories')
    .doc(categoryId)
    .set({
      id: categoryId,
      tournamentId: TOURNAMENT_ID,
      name: CATEGORY_NAME,
      type: CATEGORY_TYPE,
      matchDurationMinutes: MATCH_DURATION,
      description: '',
    });
  console.log('✅  Category created:', categoryId);

  // 3. Create participants (one per player, status = approved)
  const participantIdByName = {};
  const participantBatch = db.batch();

  for (const [groupId, players] of Object.entries(GROUPS)) {
    for (const name of players) {
      const participantId = randomUUID();
      participantIdByName[name] = participantId;
      const ref = db
        .collection('tournaments')
        .doc(TOURNAMENT_ID)
        .collection('participants')
        .doc(participantId);
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

  // Update tournament player count
  const tournamentRef = db.collection('tournaments').doc(TOURNAMENT_ID);
  participantBatch.update(tournamentRef, {
    playersCount: admin.firestore.FieldValue.increment(32),
  });

  await participantBatch.commit();
  console.log('✅  32 participants created');

  // 4. Create group standings
  const standingsBatch = db.batch();
  for (const [groupId, players] of Object.entries(GROUPS)) {
    for (const name of players) {
      const standingId = randomUUID();
      const ref = db
        .collection('tournaments')
        .doc(TOURNAMENT_ID)
        .collection('standings')
        .doc(standingId);
      standingsBatch.set(ref, {
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
      });
    }
  }
  await standingsBatch.commit();
  console.log('✅  32 group standings created (Groups A–H)');

  // 5. Create matches (80 Americano cross-group matches)
  // Firestore batch limit = 500; 80 is well within range
  const matchBatch = db.batch();
  for (let i = 0; i < MATCHES.length; i++) {
    const [p1Name, p2Name] = MATCHES[i];
    const p1Id = participantIdByName[p1Name];
    const p2Id = participantIdByName[p2Name];

    if (!p1Id) { console.warn('⚠️  Unknown player:', p1Name); continue; }
    if (!p2Id) { console.warn('⚠️  Unknown player:', p2Name); continue; }

    const matchId = randomUUID();
    const ref = db.collection('matches').doc(matchId);
    matchBatch.set(ref, {
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
