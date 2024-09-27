import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Bookings')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              return ListTile(
                title: Text('Date: ${booking['date']}'),
                subtitle: Text('User: ${booking['userId']}'),
              );
            },
          );
        },
      ),
    );
  }
}

