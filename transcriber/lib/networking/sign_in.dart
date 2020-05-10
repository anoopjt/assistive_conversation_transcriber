// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;
// final GoogleSignIn googleSignIn = GoogleSignIn();

// String name;
// String email;
// String imageUrl;

// Future<String> signInWithGoogle() async {
//   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//   final GoogleSignInAuthentication googleSignInAuthentication =
//       await googleSignInAccount.authentication;

//   final AuthCredential credential = GoogleAuthProvider.getCredential(
//     accessToken: googleSignInAuthentication.accessToken,
//     idToken: googleSignInAuthentication.idToken,
//   );

//   final AuthResult authResult = await _auth.signInWithCredential(credential);
//   final FirebaseUser user = authResult.user;

//   // Checking if email and name is null
//   assert(user.email != null);
//   assert(user.displayName != null);
//   assert(user.photoUrl != null);

//   name = user.displayName;
//   email = user.email;
//   imageUrl = user.photoUrl;

//   // Only taking the first part of the name, i.e., First Name
//   if (name.contains(" ")) {
//     name = name.substring(0, name.indexOf(" "));
//   }

//   assert(!user.isAnonymous);
//   assert(await user.getIdToken() != null);

//   final FirebaseUser currentUser = await _auth.currentUser();
//   assert(user.uid == currentUser.uid);

//   return 'signInWithGoogle succeeded: $user';
// }

// void signOutGoogle() async {
//   await googleSignIn.signOut();

//   print("User Sign Out");
// }

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

Map userProfile;
final facebookLogin = FacebookLogin();

Future<String> loginWithFB() async {
  final result = await facebookLogin.logIn(['email']);

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      final token = result.accessToken.token;
      final graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),email&access_token=${token}');
      final profile = JSON.jsonDecode(graphResponse.body);
      print('signInWithFacebook succeeded: $profile');
      return 'signInWithFacebook succeeded: $profile';
      break;

    case FacebookLoginStatus.cancelledByUser:
      return 'cancelledByUser';
      break;
    case FacebookLoginStatus.error:
      return 'error';
      break;
  }
}

void logout() async{
  await facebookLogin.logOut();
  print("User Sign Out");
}
