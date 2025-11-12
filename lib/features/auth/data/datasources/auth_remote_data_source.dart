import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vezu/features/auth/data/models/user_data_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithGoogleCredential();
  Future<UserDataModel?> fetchUser(String uid);
  Future<void> saveUser(UserDataModel user, {required bool isNewUser});
  User? get currentUser;
  Future<void> signOut();
  Future<String?> uploadProfilePhoto(String userId, String filePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore,
        _storage = storage;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<UserCredential> signInWithGoogleCredential() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Kullanıcı Google oturum açma işlemini iptal etti.',
      );
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserDataModel?> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return UserDataModel.fromDocument(doc);
  }

  @override
  Future<void> saveUser(UserDataModel user, {required bool isNewUser}) {
    return _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap(isNewUser: isNewUser), SetOptions(merge: true));
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<String?> uploadProfilePhoto(String userId, String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return null;
    }

    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users').child(userId).child(fileName);
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}

