import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/auth/sign_up.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> signIn() async{

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
        );
    } on FirebaseAuthException catch(e){
      setState(() {
        errorMessage = e.message ?? 'Sign in faield';
      });
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    
    const backgroundGradient = LinearGradient(
      colors: [Color(0xffe8f5e9), Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
      );

      const greyBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey
        ),
      );

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10)
                      )
                    ]
                  ),

                  child: Column(
                    children: [
                      Text('welcome back',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                      ),
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      TextField(
                        controller: emailController,
                        style: TextStyle(
                          color: Colors.black
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: greyBorder,
                          enabledBorder: greyBorder,
                          focusedBorder: greyBorder,
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      
                      TextField(
                        controller: passwordController,
                        style: TextStyle(
                          color: Colors.black
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: greyBorder,
                          enabledBorder: greyBorder,
                          focusedBorder: greyBorder,
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      SizedBox(height: 30,),

                      if(errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            elevation: 4
                          ),
                          child: isLoading ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ) : Text('sign_in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),)
                          ),
                      ),

                      SizedBox(
                        height: 40,
                      ),

                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                      }, 
                      child: Text("Don't have an Account Please! Sign UP ",
                      style: TextStyle(color: Colors.black54),
                      ),
                      ),
                    ],
                  ),
                ),

              ),
            )
            ),
        ),
    );
  }
}