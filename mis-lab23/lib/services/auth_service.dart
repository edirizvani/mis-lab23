import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../screens/categories_screen.dart';
import '../screens/login.dart';

class AuthService{

  Future<String?> register(String email, String password, BuildContext context) async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      return "Success!";
    } on FirebaseAuthException catch(e){
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch(e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password, BuildContext context) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Future.delayed(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => CategoriesScreen()));
      });
      return "Success!";
    } on FirebaseAuthException catch(e){
      if(e.code == "INVALID_LOGIN_CREDENTIALS"){
        return 'Invalid login credentials.';
      } else {
        return e.message;
      }
    }
    catch(e) {
      return e.toString();
    }
  }

  Future<String?> getEmail() async {
    String? email = FirebaseAuth.instance.currentUser?.email ?? "Email not found.";
    print(email);
    return email;
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
    });
  }
}