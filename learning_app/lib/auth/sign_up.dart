import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/auth/sign_in_screen.dart';
import 'package:learning_app/screen/level_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static Color greenPrimary = Color(0xfff4caf50);

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoadingc=false;
  String errorMessage = '';
  

  Future<void> signUP() async{
    if(!_formKey.currentState!.validate()) return;

    setState(() {
      isLoadingc = true;
      errorMessage = '';
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
        );

        final uid = credential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': emailController.text.trim(),
          'xp': 0,
          'streak':0,
          'language': 'German',
          'lastActive': DateTime.now()
        });
        
        //clone level for the useer
        final levelSnapshot = await FirebaseFirestore.instance.collection('levels').get();
        for(final doc in levelSnapshot.docs){
          await FirebaseFirestore.instance.collection('users').doc(uid).collection('levels').doc(doc.id).set(
            {
              'isUnlocked': doc['levelNumber'] == 1,
             'levelNumber': doc['levelNumber'],
             'title': doc['title']

            }
          );
        }

       Navigator.push(context, MaterialPageRoute(builder: (context)=>LevelScreen()));

    } on FirebaseException catch (e){
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
    }finally{
      isLoadingc = false;
    }

  }

  @override
  Widget build(BuildContext context) {

    const backgroundGradient = LinearGradient(
      colors: [
        Color(0xffe8f5e9), Colors.white
      ]
    );
    const greyBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey
      )
    );
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40
                ),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10)
                    )]
                  ),

                 child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Create Account',
                      style: TextStyle(
                        color: greenPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                      SizedBox(height: 12,),
                      TextFormField(
                        controller: emailController,
                        cursorColor: Colors.grey,
                        style: TextStyle(
                          color: Colors.black
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: greyBorder,
                          enabledBorder: greyBorder,
                          focusedBorder: greyBorder,
                          prefixIcon: Icon(Icons.email)
                        ),
                        validator: (v) => 
                        v == null || !v.contains('@') ? 'enter a valid email' : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),


                      TextFormField(
                        cursorColor: Colors.grey,
                        controller: passwordController,obscureText: true,
                        style: TextStyle(
                          color: Colors.black 
                        ),
                        decoration: InputDecoration(
                          labelText: 'password',
                          border: greyBorder,
                          enabledBorder: greyBorder,
                          focusedBorder: greyBorder,
                          prefixIcon: Icon(Icons.lock)
                        ),
                        validator: (value) => 
                        value == null || value.length < 6 ? 'please enter password(len..must 6)' : null
                      ),
                      SizedBox(height: 20,),

                      if(errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 20,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                            isLoadingc ? null : signUP();
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            elevation: 4,
                          ),

                          child: isLoadingc ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(   
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ) : Text('SignUp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                          ),
                      ),

                      SizedBox(height: 20,),

                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (contex)=>SignInScreen()));
                      }, 
                      child: Text('Already have an account, then! LogIn',
                      style: TextStyle(
                        color: Colors.black54
                      ),
                      )
                      ),
                    ],
                  )
                  ),

                ),
              ),
            )
            ),
        ),
        

    );
  }
}