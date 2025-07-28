import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/auth/sign_in_screen.dart';
import 'package:learning_app/screen/level_screen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

@override
  void initState(){
    super.initState();
    
    Future.delayed(Duration(seconds: 2), (){
      checkAuthState();
    });
  }

  void checkAuthState(){
    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      // already signin
           Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LevelScreen()),
    );
    }
    else{
      // not signin
      Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));

    }
  }
  @override
  Widget build(BuildContext context) {

    const backgroundGradient = LinearGradient(
      colors: [Color(0xFFE8F5E9), Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
      );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,

        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Spacer(flex: 2,),
                Lottie.asset('assets/animation/animation.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain
                ),
                SizedBox(height: 20,),
                Text('LanguageMaster',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 24),
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 3,
                ),
                ),
                
              ],
            ),
          ),
          ),
      ),
    );
  }
}