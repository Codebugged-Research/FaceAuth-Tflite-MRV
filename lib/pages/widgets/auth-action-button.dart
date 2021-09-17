import 'package:FaceNetAuthentication/constants/uiConstants.dart';
import 'package:FaceNetAuthentication/pages/db/database.dart';
import 'package:FaceNetAuthentication/pages/profile.dart';
import 'package:FaceNetAuthentication/pages/xd.dart';
import 'package:FaceNetAuthentication/services/facenet.service.dart';
import 'package:flutter/material.dart';
import 'package:FaceNetAuthentication/pages/home.dart';
import 'package:geolocator/geolocator.dart';

class User {
  String user;
  String password;

  User({@required this.user, @required this.password});

  static User fromDB(String dbuser) {
    return new User(user: dbuser.split(':')[0], password: dbuser.split(':')[1]);
  }
}

// ignore: must_be_immutable
class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {@required this.onPressed,
      @required this.isLogin,
      @required this.position});

  final Future _initializeControllerFuture;
  final Function onPressed;
  final Position position;
  bool isLogin;

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User predictedUser;
  bool isThere = false;

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;

    var userAndPass = _predictUser();
    if (userAndPass != null) {
      this.predictedUser = User.fromDB(userAndPass);
      setState(() {
        isThere = true;
      });
      print("______________________________" + isThere.toString());
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (BuildContext context) => AgainScreen()));
    } else {
      /// creates a new user in the 'database'
      await _dataBaseService.saveData(
          user,
          password,
          predictedData,
          widget.position.latitude.toString(),
          widget.position.longitude.toString());

      /// resets the face stored in the face net service
      this._faceNetService.setPredictedData(null);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
    }
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;

    if (this.predictedUser.password == password) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => Profile(
                username: this.predictedUser.user,
              )));
    } else {
      print(" WRONG PASSWORD!");
    }
  }

  String _predictUser() {
    String userAndPass = _faceNetService.predict();
    return userAndPass ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Color(0xff25354E),
      label: widget.isLogin ? Text('Sign in') : Text('Sign up'),
      icon: Icon(Icons.camera_alt),
      // Provide an onPressed callback.
      onPressed: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
            if (widget.isLogin) {
              var userAndPass = _predictUser();
              if (userAndPass != null) {
                this.predictedUser = User.fromDB(userAndPass);
              }
              Scaffold.of(context)
                  .showBottomSheet((context) => signSheet(context));
            } else {
              var userAndPass = _predictUser();
              if (userAndPass != null) {
                this.predictedUser = User.fromDB(userAndPass);
                Scaffold.of(context).showBottomSheet(
                  (context) => WillPopScope(
                    onWillPop: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      return true;
                    },
                    child: Container(
                      height: 240,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'You are already Registered as ${predictedUser.user}! Sign In',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: SizedBox(
                              width: UIConstants.fitToWidth(250, context),
                              child: RaisedButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text('Sign In',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) => MyHomePage()),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                Scaffold.of(context)
                    .showBottomSheet((context) => signSheet(context));
              }
            }
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
    );
  }

  signSheet(context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 300,
      child: Column(
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome Back! ' + predictedUser.user + '! 😄',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ))
                  : Container(),
          !widget.isLogin
              ? TextField(
                  controller: _userTextEditingController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color(0xff25354E),
                      ),
                      labelText: "Your Name"),
                )
              : Container(),
          widget.isLogin && predictedUser == null
              ? Container()
              : TextField(
                  controller: _passwordTextEditingController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.security,
                        color: Color(0xff25354E),
                      ),
                      labelText: "Password"),
                  obscureText: true,
                ),
          widget.isLogin && predictedUser != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: SizedBox(
                    width: UIConstants.fitToWidth(250, context),
                    child: RaisedButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child:
                          Text('Login', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        _signIn(context);
                      },
                    ),
                  ),
                )
              : !widget.isLogin
                  ? Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: SizedBox(
                        width: UIConstants.fitToWidth(250, context),
                        child: RaisedButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('Sign Up!',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            await _signUp(context);
                          },
                        ),
                      ),
                    )
                  : Container(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
