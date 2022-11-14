import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingNotifier extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  var _status = Status.Unauthenticated;
  final _firestore = FirebaseFirestore.instance;
  final saved = <String>[];
  User? _user;
  DocumentReference? docRef;

  SettingNotifier() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        status = Status.Unauthenticated;
        user = null;
      } else {
        status = Status.Authenticated;
        user = firebaseUser;
      }
      notifyListeners();
    });
  }

  Future<UserCredential?> singUp(
      String email, String password, BuildContext ctx) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      addUser(email, password, saved);
      return user;
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
    }
    return null;
  }

  Future<bool> signIn(String email, String password, BuildContext ctx) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      List<String> userSaved = List<String>.from(await getSaved());
      saved.addAll(userSaved);
      saved.toSet().toList();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
    }
    return false;
  }

  String get status => _status;

  set status(String status) {
    _status = status;
    notifyListeners();
  }

  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  void logout() async {
    await syncSaved();
    status = Status.Unauthenticated;
    _auth.signOut();

    setState() {};
    notifyListeners();
  }

  addUser(String email, String password, saved) async {
    var docRef = await _firestore.collection('users').add({
      'email': email,
      'password': password,
      'saved': saved,
      'uid': _user?.uid,
      'image': ""
    });
    return docRef;
  }





  getSaved() async => await _firestore
      .collection('users')
      .where("uid", isEqualTo: _user?.uid)
      .get()
      .then((value) => value.docs[0].data()['saved']);

  syncSaved() async =>
      await _firestore
          .collection('users')
          .where("uid", isEqualTo: _user?.uid)
          .get()
          .then((value) => value.docs[0].reference.update({'saved': saved}));

}

class Status {
  static const Uninitialized = "Uninitialized";
  static const Authenticated = "Authenticated";
  static const Authenticating = "Authenticating";
  static const Unauthenticated = "Unauthenticated";
}
