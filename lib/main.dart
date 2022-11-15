import 'dart:async';
import 'dart:typed_data';

import 'package:english_words/english_words.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'autentication_notifier.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:file_picker/file_picker.dart';

final SnappingSheetController snappingSheetController = SnappingSheetController();
var snappingPosition = 200.0;
var url = "https://www.whysoseriousredux.com/suspects/joker.jpg";


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingNotifier(),
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                resizeToAvoidBottomInset: true,
                body: Center(
                    child: Text(snapshot.error.toString(),
                        textDirection: TextDirection.ltr)));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyApp();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  bool isLoginDisabled = false;
  bool isSignupDisabled = false;
  bool isLogedIn = false;
  Timer? timer;



  // Future showSheet() => showSlidingBottomSheet(
  //   context,
  //   builder: (context) => SlidingSheetDialog(
  //
  //   )
  // );

  sync() {
    final saved = Provider.of<SettingNotifier>(context, listen: false);
    timer = Timer.periodic(
        const Duration(seconds: 10), (timer) => saved.syncSaved());
  }

  unSync() {
    timer?.cancel();
  }

  void _pushLogin() {
    var authService = Provider.of<SettingNotifier>(context, listen: false);
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (context) {
              var auth = Provider.of<SettingNotifier>(context, listen: false);
              final TextEditingController emailController = TextEditingController();
              final TextEditingController passwordController = TextEditingController();
              final TextEditingController confirmPasswordController = TextEditingController();
              return Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    title: const Text('Login'),
                  ),
                  body: Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Welcome to Startup Names Generator, please log in!",
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                obscureText: false,
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                ),
                              ),
                              SizedBox(height: 40),
                              TextButton(
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(380, 50)),
                                  foregroundColor: const MaterialStatePropertyAll<
                                      Color>(Colors.white),
                                  backgroundColor: const MaterialStatePropertyAll<
                                      Color>(Colors.deepPurple),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: const BorderSide(width: 3,
                                          color: Colors.deepPurple),
                                    ),
                                  ),
                                ),
                                onPressed: isLoginDisabled ? null : () {
                                  setState(() {
                                    isLoginDisabled = true;
                                  });
                                  var curEmail = emailController.text;
                                  auth.signIn(
                                      emailController.text, passwordController.text,
                                      context).then((value) async {
                                    if (value) {
                                      setState(() {
                                        isLoginDisabled = false;
                                        isLogedIn = true;
                                      });
                                      const snack = SnackBar(
                                        content: Text('Login success'),
                                        duration: Duration(seconds: 3),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          snack);
                                      sync();
                                      passwordController.clear();
                                      emailController.clear();
                                      auth.getImageUrl(curEmail);
                                      Navigator.of(context).pop();
                                    } else {
                                      passwordController.clear();
                                      var snak = const SnackBar(
                                        content: Text(
                                            'There was an error logging into the app'),
                                        duration: Duration(seconds: 3),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          snak);
                                      setState(() {
                                        isLoginDisabled = false;
                                      });
                                    }
                                  });
                                },
                                child: Column(
                                  children: const <Widget>[
                                    Text("Login"),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor: const MaterialStatePropertyAll<
                                      Color>(Colors.white),
                                  backgroundColor: const MaterialStatePropertyAll<
                                      Color>(Colors.blue),
                                  minimumSize: MaterialStateProperty.all(Size(380, 50)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: const BorderSide(width: 3,
                                          color: Colors.blue),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Container(
                                          height: 800 - MediaQuery.of(context).viewInsets.bottom,
                                          color: Colors.white,
                                          child:Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context).viewInsets.bottom),
                                              child: Center(
                                                child: SingleChildScrollView(
                                                  reverse: true,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        const Text('Please confirm your password below:'),
                                                        TextField(
                                                            obscureText: true,
                                                            controller: confirmPasswordController,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Password',
                                                            )),
                                                        SizedBox(height: 10),
                                                        ElevatedButton(
                                                            child: const Text('Confirm'),
                                                            onPressed: () async {
                                                              if (confirmPasswordController
                                                                  .text ==
                                                                  passwordController
                                                                      .text) {
                                                                if (isSignupDisabled) {
                                                                  return;
                                                                }
                                                                setState(() {
                                                                  isSignupDisabled = true;
                                                                });
                                                                auth.singUp(
                                                                    emailController.text,
                                                                    passwordController
                                                                        .text,
                                                                    context).then((
                                                                    value) {
                                                                  if (value != null) {
                                                                    const snack = SnackBar(
                                                                      content: Text(
                                                                          'Signup success'),
                                                                      duration: Duration(
                                                                          seconds: 3),
                                                                    );
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                        snack);
                                                                    passwordController
                                                                        .clear();
                                                                    emailController
                                                                        .clear();
                                                                    confirmPasswordController.clear();
                                                                    setState(() {
                                                                      isSignupDisabled = false;
                                                                      isLogedIn = true;
                                                                    });
                                                                    Navigator.of(context).pop();
                                                                    Navigator.of(context).pop();
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text(
                                                                              'There was an error signing up'),
                                                                          duration: Duration(
                                                                              seconds: 2),
                                                                        ));
                                                                    passwordController.clear();
                                                                    confirmPasswordController.clear();
                                                                    setState(() {
                                                                      isSignupDisabled =
                                                                      false;
                                                                    });
                                                                  }
                                                                });
                                                              }
                                                              else {
                                                                ScaffoldMessenger.of(
                                                                    context)
                                                                    .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'Password must match!'),
                                                                      duration: Duration(
                                                                          seconds: 3),
                                                                    ));
                                                                Navigator.pop(context);
                                                              }
                                                            }
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                          )
                                      );
                                    },
                                  );
                                },
                                child: Column(
                                  children: const <Widget>[
                                    Text("New user? Click to sign up"),
                                  ],
                                ),
                              ),
                            ],
                          )
                      )
                  )
              );
            }
        )
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          var auth = Provider.of<SettingNotifier>(context, listen: false);
          final tiles = auth.saved.map(
                (pair) {
              return Dismissible(
                background: Container(
                    color: Colors.deepPurple,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                            children: const [
                              Icon(
                                Icons.delete,
                              ),
                              Text(
                                "Delete suggestion",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            ]
                        )
                    )
                ),
                key: ValueKey<String>(pair),

                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Suggestions"),
                        content: Text(
                            "Are you sure you want to delete $pair from your saved Suggestions?"),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                auth.saved.remove(pair);
                              },
                              child: const Text("Yes")
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                },

                onDismissed: (DismissDirection direction) {
                  icon:
                  Icons.delete;
                  setState(() {});
                },
                child: ListTile(
                  title: Text(
                    pair,
                    style: _biggerFont,
                  ),
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];
          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('Saved Suggestions'),
              ),
              //body: ListView(children: divided),
              body: Stack(
                children: [
                  ListView(children: divided),
                ],
              )
          );
        },
      ),
    );
  }

  void _pushLogout(BuildContext context)  {
    var auth = Provider.of<SettingNotifier>(context, listen: false);
    setState(() {
      isLogedIn = false;
      auth.saved.clear();
    });

    unSync();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out'),
        duration: Duration(seconds: 2),
      ),
    );
    auth.logout();
    auth.cleanUrl();
  }
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<SettingNotifier>(context, listen: false);
    var curEmail = auth.user?.email;
    if(curEmail == null){
      curEmail = "";
    }
    var loginButton = IconButton(
      icon: const Icon(Icons.login_sharp),
      onPressed: _pushLogin,
      tooltip: "Login",
    );
    var logoutButton = IconButton(
      icon: const Icon(Icons.logout_sharp),
      onPressed: () {
        _pushLogout(context);
        curEmail = "";
      },
      tooltip: "Logout",
    );
    //FilePickerResult? result;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: isLogedIn ? logoutButton : loginButton,
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: Stack(
            children: [
              ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, i) {
                    if (i.isOdd) return const Divider();
                    final index = i ~/ 2;
                    if (index >= _suggestions.length) {
                      _suggestions.addAll(generateWordPairs().take(100));
                    }
                    final alreadySaved =
                    auth.saved.contains(_suggestions[index].asPascalCase);
                    return ListTile(
                      title: Text(
                        _suggestions[index].asPascalCase,
                        style: _biggerFont,
                      ),
                      trailing: Icon(
                        alreadySaved ? Icons.favorite : Icons.favorite_border,
                        color: alreadySaved ? Colors.red : null,
                        semanticLabel: alreadySaved ? "Remove from saved" : "Save",
                      ),
                      onTap: () {
                        setState(() {
                          if (alreadySaved) {
                            auth.saved.remove(_suggestions[index].asPascalCase);
                          } else {
                            auth.saved.add(_suggestions[index].asPascalCase);
                          }
                        });
                      },
                    );
                  }),
              if(isLogedIn)
                mainSnappingSheet(),
            ]
        )
    );
  }
}

class mainSnappingSheet extends StatefulWidget {
  const mainSnappingSheet({Key? key}) : super(key: key);

  @override
  State<mainSnappingSheet> createState() => _mainSnappingSheetState();
}

class _mainSnappingSheetState extends State<mainSnappingSheet> {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<SettingNotifier>(context, listen: false);
    var curEmail = auth.user?.email;
    if(curEmail == null){
      curEmail = "";
    }
    const _biggerFont = TextStyle(fontSize: 18);
    return SnappingSheet(
            snappingPositions: [
              SnappingPosition.factor(
                positionFactor: 0.0,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.top,
              ),
              SnappingPosition.pixels(
                positionPixels: snappingPosition,
                snappingCurve: Curves.elasticOut,
                snappingDuration: Duration(milliseconds: 1750),
              ),
              SnappingPosition.factor(
                positionFactor: 1.0,
                snappingCurve: Curves.bounceOut,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.bottom,
              ),
            ],
            controller: snappingSheetController,
            lockOverflowDrag: true,
            grabbingHeight: 75,
            grabbing: InkWell(
              onTap: () async {
                setState(()  {
                  snappingSheetController.snapToPosition(
                    SnappingPosition.factor(positionFactor: 1.0),
                  );
                });
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding:EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Row(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Welcome back, $curEmail"),
                    Icon(Icons.arrow_upward_outlined,size:15,color:Colors.black.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
            sheetBelow: SnappingSheetContent(
              draggable: true,
              child: Container(
                height:  580 - MediaQuery.of(context).viewInsets.bottom,
                color: Colors.white,
                child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ListView(
                          children: [
                            Text(curEmail!,style: _biggerFont,),
                            SizedBox(height: 10),
                            Image.network(Provider.of<SettingNotifier>(context, listen: true).imageUrl),
                            SizedBox(height: 10),
                            TextButton(
                              style: ButtonStyle(
                                foregroundColor: const MaterialStatePropertyAll<
                                    Color>(Colors.white),
                                backgroundColor: const MaterialStatePropertyAll<
                                    Color>(Colors.lightBlue),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
                                if (result != null) {
                                  Uint8List? fileBytes = result.files.first.bytes;
                                  try {
                                    if(fileBytes != null) {
                                      try {
                                        await FirebaseStorage.instance
                                            .ref()
                                            .child(
                                            '$curEmail/curProfileImage')
                                            .delete();
                                      }catch(error){
                                        print("error deleting previous image");
                                        print(error.toString());
                                      }
                                      await FirebaseStorage.instance.ref(
                                          '$curEmail/curProfileImage').putData(
                                          fileBytes);
                                      try {
                                        setState (()  {
                                          auth.getImageUrl(curEmail!);
                                        });
                                      }catch (error){
                                        url = '';
                                        print("error getting image's url");
                                        print(error.toString());
                                      }
                                    }
                                    else {
                                      print("file is empty");
                                    }
                                  }catch(error){
                                    print(error.toString());
                                    print("error");
                                  }
                                  result = null;
                                }
                                else{
                                  print("no image");
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('No image selected'),
                                    duration: Duration(seconds: 2),
                                  ));
                                  return;
                                }
                              },
                              child: Text(
                                "Change Avatar", style: _biggerFont,),
                            ),
                          ]
                      ),
                    )
                ),
              ),
            ),
          );
        }
      }



