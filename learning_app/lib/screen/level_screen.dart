import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/auth/sign_in_screen.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  static Color greenPrimary = Color(0xff4caf50);
  static Color greenAccent = Color(0xff81c784);
  static const backgroundGradient = LinearGradient(colors: [
    Color(0xffe8f5e9), Colors.white,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter
  
  );

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  int currentIndex = 0;

  final List<String> language = [
    'German',
    'Spanish',
    'French',
    'Italian',
    'Korean'
  ];

  Future<void> changeLanguage() async{
    final userId = FirebaseAuth.instance.currentUser!.uid;

    String? selectedLanguage = await showDialog<String>(
      context: context, 
      builder: (BuildContext contex){
        return SimpleDialog(
          title: Text('Select Language'),
          children: language.map((lang){
            return SimpleDialogOption(
              onPressed: (){
                Navigator.pop(context, lang);
              },
              child: Text(lang),
            );
          }).toList()
        );
      }
      );

      if(selectedLanguage != null){
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'language': selectedLanguage
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('language change to $selectedLanguage')));
      }
  }
  @override
  Widget build(BuildContext context) {

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final levelsQuery = FirebaseFirestore.instance.collection('users').doc(userId).collection('levels').
        orderBy('levelNumber');
        

    return Scaffold(

      body: Container(

        decoration: BoxDecoration(
          gradient: LevelScreen.backgroundGradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16
              ),
              child: Row(
                children: [
                  Text('language tutor', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: LevelScreen.greenPrimary
                  ),),
                  Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.settings,
                    color: LevelScreen.greenPrimary,
                    ),
                    onSelected: (value) async{
                      if(value == 'language'){
                        await changeLanguage();
                      }else if(value == 'logout'){
                        await FirebaseAuth.instance.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
                      }
                    },
                    itemBuilder: (context)=>[
                      PopupMenuItem(
                        value: 'language',
                        child: ListTile(
                          leading: Icon(Icons.language, color: LevelScreen.greenPrimary,),
                          title: Text('change language'),
                        ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.redAccent,),
                            title: Text('logout'),
                          ))
                    ])
                ],
              ),
              ),
            ],
          )
          ),
      ),
    );
  }
}