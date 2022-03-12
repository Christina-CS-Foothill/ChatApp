import './create_user_screen.dart';
import './update_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../models/User.dart';

class FirebaseTutScreen extends StatefulWidget {
  const FirebaseTutScreen({Key? key}) : super(key: key);

  @override
  _FirebaseTutScreenState createState() => _FirebaseTutScreenState();
}

class _FirebaseTutScreenState extends State<FirebaseTutScreen> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: usersListTwo(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(CreateUserScreen.routeName);
        },
      ),
    );
  }

  Widget singleUser() {
    return FutureBuilder<User>(
      future: readUser('52PhbXDhJEWW0izq6pkV'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data as User;
          return user == null
              ? const Center(
                  child: Text('Failed'),
                )
              : buildUser(user);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget usersList() {
    return FutureBuilder(
      future: readUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong!');
        } else if (snapshot.hasData) {
          final users = snapshot.data! as List<User>;
          print('hello');
          return ListView(
            children: users.map(buildUser).toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget usersListTwo() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            User user = new User(
                id: data['id'],
                name: data['name'],
                age: data['age'],
                birthday: data['birthday'].toDate());
            return buildUser(user);
          }).toList(),
        );
      },
    );
  }

  Widget InputScreen() {
    return ListView(
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
          },
          child: const Text('Create User'),
          color: Colors.blue,
        )
      ],
    );
  }

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(
          child: Text('${user.age}'),
        ),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
        onTap: () {
          Navigator.of(context)
              .pushNamed(UpdateScreen.routeName, arguments: user.id);
        },
      );

  Future<User> readUser(String userId) async {
    /*return FirebaseFirestore.instance
        .collection('user')
        .doc('52PhbXDhJEWW0izq6pkV')
        .get()
        .then((value) {
      final doc = value.data() as Map<String, dynamic>;
      User newUser = User(
          id: doc['id'],
          name: doc['name'],
          age: doc['age'],
          birthday: doc['birthday'].toDate());
      return newUser;
    });*/

    //final snapshot = await docUser.get() as Map<String, dynamic>;

    //return snapshot;
    /*if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }*/

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

  Future<List<User>> readUsers() {
    final test = 42;
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
      return userList;
    });

    /*return FirebaseFirestore.instance.collection('users').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());*/

    //print('hello');
  }

  StreamBuilder<QuerySnapshot> readUsersTwo() {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return buildUser(User.fromJson(data));
          }).toList(),
        );
      },
    );
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
}
