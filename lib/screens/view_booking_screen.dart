import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewBookingsScreen extends StatelessWidget {
  const ViewBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(
              child: Text('An error occurred!'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No bookings found or data is empty.');
            return const Center(
              child: Text('No bookings found.'),
            );
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>?;

              if (booking == null) {
                return const Center(
                  child: Text('Booking data is not available.'),
                );
              }

              DateTime date = (booking['date'] as Timestamp).toDate();
              String formattedDate = DateFormat('dd/MM/yyyy').format(date);
              String formattedTime = booking['time'] ??
                  'Unknown Time'; // Default value if not present

              // Safely get fields with default values
              String name = booking.containsKey('name')
                  ? booking['name']
                  : 'Unknown Name';
              String numberOfTeams = booking.containsKey('number_of_teams')
                  ? booking['number_of_teams'].toString()
                  : 'Unknown Number';
              String dayOfWeek =
                  booking.containsKey('day') ? booking['day'] : 'Unknown Day';
              String status = booking.containsKey('booking_status')
                  ? booking['booking_status']
                  : 'Unknown Status';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Date: $formattedDate',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name of Booker: $name',
                          style: const TextStyle(fontSize: 16)),
                      Text('Time: $formattedTime',
                          style: const TextStyle(fontSize: 16)),
                      Text('Number of Teams: $numberOfTeams',
                          style: const TextStyle(fontSize: 16)),
                      Text('Day: $dayOfWeek',
                          style: const TextStyle(fontSize: 16)),
                      Text('Status: $status',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  trailing:
                      const Icon(Icons.book_online, color: Colors.deepOrange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
