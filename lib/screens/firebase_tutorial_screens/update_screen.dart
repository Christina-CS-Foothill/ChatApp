import './firebase_tut_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firebase_tut_screen.dart';
import '../../models/User.dart';

class UpdateScreen extends StatelessWidget {
  static const routeName = '/update';

  const UpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerName;
    TextEditingController controllerAge;
    final userId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Current User'),
      ),
      body: FutureBuilder<User>(
          future: readUser(userId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              controllerAge = new TextEditingController(
                  text: (snapshot.data!.age).toString());
              controllerName =
                  new TextEditingController(text: snapshot.data!.name);

              return snapshot.data == null
                  ? const Center(
                      child: Text('Failed'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        TextField(
                          controller: controllerName,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextField(
                          controller: controllerAge,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Age'),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        FlatButton(
                          onPressed: () {
                            updateUser(
                              updatedName: controllerName.text,
                              updatedAge: int.parse(controllerAge.text),
                              userId: userId,
                            );
                            controllerName.clear();
                            controllerAge.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update User'),
                          color: Colors.blue,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        FlatButton(
                          onPressed: () {
                            deleteUser(
                              userId: userId,
                            );
                            controllerName.clear();
                            controllerAge.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete User'),
                          color: Colors.blue,
                        )
                      ],
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future? updateUser(
      {required String updatedName,
      required int updatedAge,
      required String userId}) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users
        .doc(userId)
        .update({'name': updatedName, 'age': updatedAge})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}

Future? deleteUser({required String userId}) {
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);

  return docUser.delete();
}

Future<User> readUser(String userId) async {
  List<User> userList = [];
  return FirebaseFirestore.instance
      .collection('users')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      User newUser = User(
          id: doc['id'],
          name: doc['name'],
          age: doc['age'],
          birthday: doc['birthday'].toDate());
      //User newUser = User.fromJson(doc.data() as Map<String, dynamic>);
      //print(newUser);
      userList.add(newUser);
      //print(userList.toString());
    });
    //filter out the specific user we want and return them
    return userList.firstWhere((user) => user.id == userId);
  });
}
