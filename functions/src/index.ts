import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const firestore = admin.firestore();

interface Article {
    readonly message: String;
    readonly createDateTime: Date;
}

interface RootArticle extends Article {
    authorRef?: FirebaseFirestore.DocumentReference;
}

export const onUsersArticleCreate = functions.firestore.document('users/{userId}/articles/{articleId}').onCreate(async (snapshot, context) => {
    await copyToRootWithUsersArticle(snapshot, context);
});

export const onUsersArticleUpdate = functions.firestore.document('users/{userId}/articles/{articleId}').onUpdate(async (change, context) => {
    await copyToRootWithUsersArticle(change.after, context);
});

async function copyToRootWithUsersArticle(snapshot: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) {
    const articleId = snapshot.id;
    const userId = context.params.userId;
    const article = snapshot.data() as RootArticle;
    article.authorRef = firestore.collection('users').doc(userId);
    await firestore.collection('articles').doc(articleId).set(article, { merge: true });
}