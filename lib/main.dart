import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'HomeScreen.dart';
import 'package:flutter/material.dart';
import 'Providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UserProvider(),
      child: MaterialApp(
        home: SafeArea(
          child: LoginScreen(),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  String _password;
  String _mobileNumber;

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Enter your email here..."),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() {
                _email = value.trim();
              });
            },
          ),
          TextField(
            decoration:
                InputDecoration(hintText: "Enter your Password here..."),
            obscureText: true,
            onChanged: (value) {
              setState(() {
                _password = value.trim();
              });
            },
          ),
          TextField(
            decoration:
                InputDecoration(hintText: "Enter your Mobile number here..."),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                _mobileNumber = value.trim();
              });
              userProvider.setName(value);
            },
          ),
          MaterialButton(
            onPressed: () {
              auth.createUserWithEmailAndPassword(
                  email: _email, password: _password);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text('Sign up'),
          ),
          MaterialButton(
            onPressed: () {
              auth.signInWithEmailAndPassword(
                  email: _email, password: _password);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text('Sign in'),
          ),
          MaterialButton(
            onPressed: () {
              auth.verifyPhoneNumber(
                  phoneNumber: _mobileNumber,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    await auth.signInWithCredential(credential);
                  },
                  verificationFailed: (FirebaseAuthException exception) {
                    if (exception.code == 'invalid-phone-number') {
                      print('Invalid phone number');
                    }
                  },
                  codeSent: (String verificationId, [int resendToken]) {
                    final _codeController = TextEditingController();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: Text('Enter code'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              PhoneAuthCredential _credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: _codeController.text.trim());
                              await auth
                                  .signInWithCredential(_credential)
                                  .then((UserCredential result) => {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(),
                                          ),
                                        ),
                                      })
                                  .catchError((e) {
                                return "error";
                              });
                            },
                            textColor: Colors.amber,
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    );
                  },
                  timeout: const Duration(seconds: 60),
                  codeAutoRetrievalTimeout: (String verificationID) {});
            },
            child: Text("Generate OTP"),
          ),
        ],
      ),
    );
  }
}
