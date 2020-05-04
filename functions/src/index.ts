import * as ff from 'firebase-functions';
import * as admin from 'firebase-admin';

const functions = ff.region('europe-west2');

admin.initializeApp(
  { credential: admin.credential.applicationDefault() }
);

const store = admin.firestore();

export const helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

export const joinTable = functions.https.onRequest(async (request, response) => {
  const { uid } = await token(request);
  const { table } = request.body;
  await store.collection(`tables/${table}/players`).add({ uid });
});

const token = async (request: ff.https.Request) => await admin.auth().verifyIdToken(request.headers['authorization']?.split(' ')[1] || '');