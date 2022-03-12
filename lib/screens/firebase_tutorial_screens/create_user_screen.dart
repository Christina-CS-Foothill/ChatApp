import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/User.dart';

class CreateUserScreen extends StatelessWidget {
  static const routeName = '/create-user';
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controllerName = TextEditingController();
    final controllerAge = TextEditingController();
    final controllerDate = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New User'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: const InputDecoration(hintText: 'Name'),
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
              createUser(
                name: controllerName.text,
                age: int.parse(controllerAge.text),
              );
              controllerName.clear();
              controllerAge.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Create User'),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}

Future createUser({required String name, required int age}) async {
  //Reference to document
  final docUser = FirebaseFirestore.instance.collection('users').doc();

  /*final json = {
      'name': name,
      'age': 21,
      'birthday': DateTime(2001, 7, 28),
    };*/

  final user = User(
    id: docUser.id,
    name: name,
    age: age,
    birthday: DateTime(2001, 7, 28),
  );

  final json = user.toJson();

  //Create document and write data to Firebase
  await docUser.set(json);
}
