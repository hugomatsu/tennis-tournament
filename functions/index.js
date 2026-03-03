const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();

/**
 * Cloud Function triggered when a match document is updated.
 * Creates in-app notifications and sends FCM push notifications
 * to relevant users (participants + followers) when:
 * - Match status changes
 * - Match date/time changes
 * - Match score/result is set
 */
exports.onMatchUpdated = onDocumentUpdated("matches/{matchId}", async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const matchId = event.params.matchId;

    if (!beforeData || !afterData) return null;

    // Detect what changed
    const statusChanged = beforeData.status !== afterData.status;
    const dateChanged = beforeData.time !== afterData.time;
    const scoreChanged = (!beforeData.score && afterData.score) ||
        (beforeData.score !== afterData.score && afterData.score);
    const winnerSet = !beforeData.winner && afterData.winner;

    if (!statusChanged && !dateChanged && !scoreChanged && !winnerSet) {
        return null; // No relevant change
    }

    // Build notification content
    let title = "";
    let body = "";
    let type = "matchUpdate";

    const matchLabel = `${afterData.player1Name || "A definir"} vs ${afterData.player2Name || "A definir"}`;

    const statusTranslations = {
        "Preparing": "Preparando",
        "Scheduled": "Agendado",
        "Confirmed": "Confirmado",
        "Live": "Live",
        "Completed": "Concluído",
        "Cancelled": "Cancelado"
    };

    if (winnerSet || scoreChanged) {
        type = "result";
        title = "Resultado do Jogo";
        body = `${matchLabel}: ${afterData.score || ""}. Vencedor: ${afterData.winner || "A definir"}`;
    } else if (statusChanged) {
        type = "statusChange";
        title = "Status do Jogo Atualizado";
        const localizedStatus = statusTranslations[afterData.status] || afterData.status;
        body = `${matchLabel} agora está ${localizedStatus}`;
    } else if (dateChanged) {
        type = "dateChange";
        title = "Jogo Reagendado";
        body = `A data de ${matchLabel} foi atualizada`;
    }

    // Collect all relevant user IDs (participants + followers)
    const userIds = new Set();

    // Add participant user IDs
    const p1UserIds = afterData.player1UserIds || [];
    const p2UserIds = afterData.player2UserIds || [];
    p1UserIds.forEach((id) => { if (id) userIds.add(id); });
    p2UserIds.forEach((id) => { if (id) userIds.add(id); });

    // Find users who follow this match
    try {
        const followersSnapshot = await db.collection("users")
            .where("followedMatchIds", "array-contains", matchId)
            .get();
        followersSnapshot.forEach((doc) => userIds.add(doc.id));
    } catch (e) {
        console.log("Error fetching followers:", e);
    }

    if (userIds.size === 0) return null;

    // For each user, check their notification settings and create notification
    const batch = db.batch();
    const fcmTokens = [];

    for (const userId of userIds) {
        // Check user notification settings
        try {
            const userDoc = await db.collection("users").doc(userId).get();
            const userData = userDoc.data();

            if (!userData) continue;

            const settings = userData.notificationSettings || {};

            // Check if user wants this type of notification
            if (type === "result" && settings.matchResults === false) continue;
            if (type === "dateChange" && settings.matchScheduleChanges === false) continue;
            if (type === "statusChange" && settings.matchScheduleChanges === false) continue;

            // Check if this is a followed match (not a participant) and followedUpdates is off
            const isParticipant = p1UserIds.includes(userId) || p2UserIds.includes(userId);
            if (!isParticipant && settings.followedUpdates === false) continue;

            // Create notification document
            const notifRef = db.collection("notifications").doc();
            batch.set(notifRef, {
                userId: userId,
                title: title,
                body: body,
                type: type,
                matchId: matchId,
                tournamentId: afterData.tournamentId || null,
                isRead: false,
                createdAt: FieldValue.serverTimestamp(),
            });

            // Collect FCM tokens for push notification
            const tokens = userData.fcmTokens || [];
            tokens.forEach((token) => {
                if (token) {
                    fcmTokens.push({ token, userId });
                }
            });
        } catch (e) {
            console.log(`Error processing user ${userId}:`, e);
        }
    }

    // Commit all notification documents
    try {
        await batch.commit();
        console.log(`Created notifications for ${userIds.size} users`);
    } catch (e) {
        console.error("Error committing notification batch:", e);
    }

    // Send FCM push notifications
    if (fcmTokens.length > 0) {
        const messaging = getMessaging();
        const sendPromises = fcmTokens.map(async ({ token, userId }) => {
            try {
                await messaging.send({
                    token: token,
                    notification: {
                        title: title,
                        body: body,
                    },
                    data: {
                        matchId: matchId,
                        tournamentId: afterData.tournamentId || "",
                        type: type,
                    },
                    // iOS specific settings
                    apns: {
                        payload: {
                            aps: {
                                badge: 1,
                                sound: "default",
                            },
                        },
                    },
                    // Android specific settings
                    android: {
                        priority: "high",
                        notification: {
                            sound: "default",
                            channelId: "match_updates",
                        },
                    },
                });
            } catch (e) {
                // Remove invalid tokens
                if (
                    e.code === "messaging/invalid-registration-token" ||
                    e.code === "messaging/registration-token-not-registered"
                ) {
                    console.log(`Removing invalid token for user ${userId}`);
                    await db.collection("users").doc(userId).update({
                        fcmTokens: FieldValue.arrayRemove([token]),
                    });
                } else {
                    console.log(`Error sending FCM to ${userId}:`, e.message);
                }
            }
        });

        await Promise.all(sendPromises);
        console.log(`Sent ${fcmTokens.length} push notifications`);
    }

    return null;
});
