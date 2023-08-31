import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';
import { getAuth } from 'firebase/auth';

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBRqFxecZYe87DnYh7gYyzY_goAKmhrpV8",
  authDomain: "realchar-a58de.firebaseapp.com",
  projectId: "realchar-a58de",
  storageBucket: "realchar-a58de.appspot.com",
  messagingSenderId: "329881922764",
  appId: "1:329881922764:web:86620c703c32f2a608a669",
  measurementId: "G-CN8CGSZV9M"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

export default auth;
export const analytics = getAnalytics();
