import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'main.dart';
import 'dart:io';
import 'dart:async';
import 'package:mailer2/mailer.dart';
import 'package:firebase_storage/firebase_storage.dart';

String email;

// ignore: camel_case_types
class grievance extends StatefulWidget {
  grievance({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _grievancestate createState() => new _grievancestate();
}

// ignore: camel_case_types
class _grievancestate extends State<grievance> {
  final db = Firestore.instance;
  String doc;
  File _imageFile;
  var download;
  String fileName;
  StorageReference reference;

  List<String> _categories = <String>[
    '',
    "Complaints",
    "Feedback",
    "Suggestions"
  ];
  String _category = '';
  List<String> _departments = <String>[
    '',
    "Advisory",
    "Development",
    "Drainage",
    "Education",
    "Election",
    "Electricity",
    "Health",
    "Vehical",
    "Water",
  ];
  String _department = '';
  TextEditingController _description = new TextEditingController();
  TextEditingController _subject = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Future getImage() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  void fetch() {
    DocumentReference documentReference =
        db.collection("Admin").document(_department);
    documentReference.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        email = datasnapshot.data['Email'].toString();
        print(email);
        sendMail();
      }
    });
  }

  void sendMail() {
    GmailSmtpOptions options = new GmailSmtpOptions()
      ..username = 'teamenigma96@gmail.com'
      ..password = 'opagpdcvbjrvkdzw';
    SmtpTransport emailTransport = new SmtpTransport(options);
    Envelope envelope = new Envelope()
      ..from = 'teamenigma96@gmail.com'
      //..recipients.add(email)
      ..recipients.add(s)
      ..subject = 'Your Grievance has been submitted'
      //..attachments.add(new Attachment(file: new File(fileName)))
      ..html =
          "<html><body><p><font size=3>Thanks for contacting us!<br>Your request for Form ID: <b>$doc</b> has been received and we\'ll get back to you as soon as possible.<br><br>Your form details are as following,<br>1. Category: $_category <br>2. Department: $_department" +
              "<br>2. Subject: " +
              _subject.text +
              " <br>4. Description: " +
              _description.text +
              "</font></p></body></html>";
    emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));

    envelope = new Envelope()
      ..from = 'team@gmail.com'
      ..recipients.add(email)
      ..subject = 'Form Added'
      //..attachments.add(new Attachment(file: new File(fileName)))
      ..html =
          "<html><body><p><font size=3>A new Grievance Form with Form ID: <b>$doc</b> has been received of your department. </font></p></body></html>";
    emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));
  }

  void submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, dynamic> data = <String, dynamic>{
        "04 Category": _category,
        "05 Department": _department,
        "06 Subject": _subject.text,
        "07 Description": _description.text,
        "08 ImageURL": download,
        "03 Email Id": s,
        "02 Name": name,
        "01 Submitted On": Timestamp.now(),
        "09 Status": 'Open',
        "10 Phone Number": phone,
        "11 Address": address,
      };
      final docRef = await db.collection("Forms").add(data).whenComplete(() {
        print("Form Added");
      }).catchError((e) => print(e));
      doc = docRef.documentID;
      fetch();
      Toast.show("Form Submitted Successfuly", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
    }
    if (_imageFile != null) {
      Toast.show(
          "Uploading Image... Please wait... Don't press back button", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      fileName = Path.basenameWithoutExtension(_imageFile.path);
      reference = FirebaseStorage.instance.ref().child('CCRS/Images/$fileName');
      StorageUploadTask uploadTask = reference.putFile(_imageFile);
      await uploadTask.onComplete;
      String downloadAddress = await reference.getDownloadURL();
      download = downloadAddress;
      print(download);
    } else
      download = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      // appBar: new AppBar(
      //   title: new Text("Grievances Form", style: TextStyle(color: Colors.white)),
      //   iconTheme: new IconThemeData(color: Colors.white),
      // ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: AssetImage("assets/bg.jpg"),
            fit: BoxFit.cover,
            color: Colors.grey.shade800,
            colorBlendMode: BlendMode.darken,
          ),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Theme(
                data: ThemeData(
                    brightness: Brightness.dark,
                    accentColor: Colors.lightBlue,
                    primaryColor: Colors.blueAccent,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 53),
                      ),
                      Text(
                        "Grievance Form",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontFamily: 'Google-Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Text(
                      //   "Fields marked with * are mendatory...",
                      //   style: TextStyle(
                      //       fontSize: 10,
                      //       fontFamily: 'Google-Sans',
                      //       fontStyle: FontStyle.italic),
                      //   textAlign: TextAlign.left,
                      // ),
                      new FormField(
                        builder: (FormFieldState state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: const Icon(Icons.category),
                              labelText: 'Category*',
                            ),
                            isEmpty: _category == '',
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton(
                                value: _category,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _category = newValue;
                                    print(newValue);
                                    state.didChange(newValue);
                                  });
                                },
                                items: _categories.map((String value) {
                                  return new DropdownMenuItem(
                                    value: value,
                                    child: new Text(
                                      value,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Google-Sans'),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      FormField(
                        builder: (FormFieldState state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: const Icon(Icons.recent_actors),
                              labelText: 'Department*',
                            ),
                            isEmpty: _department == '',
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton(
                                value: _department,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _department = newValue;
                                    print(newValue);
                                    state.didChange(newValue);
                                  });
                                },
                                items: _departments.map((String value) {
                                  return new DropdownMenuItem(
                                    value: value,
                                    child: new Text(
                                      value,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Google-Sans'),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.subject),
                          hintText: 'Eg: Complaint regarding xyz',
                          labelText: 'Subject*',
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'Please enter subject';
                          return null;
                        },
                        controller: _subject,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.description),
                          alignLabelWithHint: true,
                          hintText:
                              'Enter complete details for the complaint/feedback/suggestions',
                          labelText: 'Description*',
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'Please enter description';
                          else if (value.length < 200)
                            return 'Minimum 200 caracters required';
                          return null;
                        },
                        controller: _description,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        maxLength: 1000,
                        maxLengthEnforced: true,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      MaterialButton(
                        color: Colors.white,
                        height: 45,
                        textColor: Colors.blueAccent,
                        child: Text('Upload Image',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Google-Sans')),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        splashColor: Colors.white10,
                        onPressed: getImage,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      _imageFile == null
                          ? Container()
                          : Image.file(_imageFile, height: 400, width: 400),
                      MaterialButton(
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          child: Text('Submit',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Google-Sans')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          splashColor: Colors.white10,
                          onPressed: submit,
                        ),
                      Padding(padding: EdgeInsets.only(top: 20))
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
