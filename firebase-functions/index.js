const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

/**
 * sendSmsCode Firebase Cloud Function
 * Triggers: callable
 * Params: phoneNumber (string)
 */
exports.sendSmsCode = functions.https.onCall(async (data, context) => {
  const phoneNumber = data.phoneNumber;
  if (!phoneNumber) {
    throw new functions.https.HttpsError('invalid-argument', 'phoneNumber is required');
  }
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  const kaspiApiUrl = functions.config().kaspi.url;
  const kaspiToken = functions.config().kaspi.token;

  try {
    await axios.post(`${kaspiApiUrl}/sendSms`, { phone: phoneNumber, code }, {
      headers: { Authorization: `Bearer ${kaspiToken}` }
    });
    // optionally store verification code using admin.firestore() or other service
    return { status: 'sent' };
  } catch (err) {
    console.error('sendSmsCode error', err);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS');
  }
});

/**
 * confirmSmsCode Firebase Cloud Function
 * Triggers: callable
 * Params: phoneNumber (string), code (string)
 */
exports.confirmSmsCode = functions.https.onCall(async (data, context) => {
  const phoneNumber = data.phoneNumber;
  const code = data.code;
  if (!phoneNumber || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'phoneNumber and code are required');
  }

  const kaspiApiUrl = functions.config().kaspi.url;
  const kaspiToken = functions.config().kaspi.token;

  try {
    const res = await axios.post(`${kaspiApiUrl}/confirmSms`, { phone: phoneNumber, code }, {
      headers: { Authorization: `Bearer ${kaspiToken}` }
    });
    return res.data;
  } catch (err) {
    console.error('confirmSmsCode error', err);
    throw new functions.https.HttpsError('internal', 'Failed to confirm SMS');
  }
});
