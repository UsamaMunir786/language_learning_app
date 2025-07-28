import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/auth/sign_in_screen.dart';
import 'package:lottie/lottie.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  static Color greenPrimary = Color(0xff4caf50);
  static Color greenAccent = Color(0xff81c784);
  static const backgroundGradient = LinearGradient(
    colors: [Color(0xffe8f5e9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int _currentIndex = 0;

  final List<String> language = [
    'German',
    'Spanish',
    'French',
    'Italian',
    'Korean',
  ];

  Future<void> changeLanguage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext contex) {
        return SimpleDialog(
          title: Text('Select Language'),
          children:
              language.map((lang) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, lang);
                  },
                  child: Text(lang),
                );
              }).toList(),
        );
      },
    );

    if (selectedLanguage != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'language': selectedLanguage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('language change to $selectedLanguage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final levelsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('levels')
        .orderBy('levelNumber');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LevelScreen.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      'language tutor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LevelScreen.greenPrimary,
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.settings,
                        color: LevelScreen.greenPrimary,
                      ),
                      onSelected: (value) async {
                        if (value == 'language') {
                          await changeLanguage();
                        } else if (value == 'logout') {
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'language',
                              child: ListTile(
                                leading: Icon(
                                  Icons.language,
                                  color: LevelScreen.greenPrimary,
                                ),
                                title: Text('change language'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(
                                  Icons.logout,
                                  color: Colors.redAccent,
                                ),
                                title: Text('logout'),
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),

              // user streak card with language
              StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  final userData = snapshot.data!;
                  final email = userData['email'] ?? 0;
                  final name = email.split('@')[0];
                  final streak = userData['streak'] ?? 0;
                  final language = userData['language'] ?? 'German';

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/cool.png'),
                          radius: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Learning: $language',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffff8a65), Color(0xffff7043)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '🔥 $streak',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'days',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),

                  child: StreamBuilder(
                    stream: levelsQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final levels = snapshot.data!.docs;

                      if (levels.isEmpty) {
                        return Center(
                          child: Text(
                            'No levels available yet!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children:
                              levels.asMap().entries.map((entry) {
                                final index = entry.key;
                                final doc = entry.value;

                                final title = doc['title'] ?? 'level';
                                final levelNumber =
                                    doc['levelNumber'] ?? index + 1;
                                final bool isUnlocked =
                                    doc['isUnlocked'] ?? (levelNumber == 1);
                                final bool isLeft = index % 2 == 0;

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        isLeft
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                    children: [
                                      if (!isLeft)
                                        Lottie.asset(
                                          'assets/animation/animation.json',
                                          height: 80,
                                          width: 80,
                                        ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap:
                                                isUnlocked
                                                    ? () {
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder:
                                                      //         (
                                                      //           context,
                                                      //         ) => ScreenOne(

                                                      //           levelNumber: levelNumber,

                                                      //         ),
                                                      //   ),
                                                      // );
                                                    }
                                                    : null,
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient:
                                                    isUnlocked
                                                        ? LinearGradient(
                                                          colors: [
                                                            LevelScreen
                                                                .greenPrimary,
                                                            LevelScreen
                                                                .greenAccent,
                                                          ],
                                                        )
                                                        : LinearGradient(
                                                          colors: [
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                          ],
                                                        ),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 12,
                                                    offset: Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              width: 80,
                                              height: 80,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      isUnlocked
                                                          ? Icons.star
                                                          : Icons.lock,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      '$levelNumber',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isLeft)
                                        Lottie.asset(
                                          'assets/animation/animation3.json',
                                          height: 80,
                                          width: 80,
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(), // ✅ No semicolon here!
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 12,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if(index == 1){
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>LeaderboardScreen()));
            }else if(index == 2){
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/home.png'),
              ),
              label: 'Home'
              ),
              BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/rank.png'),
              ),
              label: 'Leaderboard'
              ),
              BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/avatar.png'),
              ),
              label: 'Profile'
              ),
          ]
          ),
    );
  }
}
