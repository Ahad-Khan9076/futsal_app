import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Bookings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var bookings = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];

              // Convert Firestore Timestamp to DateTime and format it
              DateTime bookingDate = (booking['date'] as Timestamp).toDate();
              String formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(bookingDate);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display booking date
                      Text(
                        'Booking Date: $formattedDate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10), // Add spacing between details

                      // Display User Name instead of User ID
                      Text(
                        'Name: ${booking['name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Additional Booking Details
                      Text(
                        'Booking Time: ${booking['time'] ?? 'Not Specified'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20), // Add spacing before the button

                      // 'More Info' Button to display more details
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _showBookingDetailsDialog(context, booking);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('More Info'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to show booking details in a dialog box
  void _showBookingDetailsDialog(BuildContext context, DocumentSnapshot booking) {
    // Convert Firestore Timestamp to DateTime and format it for dialog display
    DateTime bookingDate = (booking['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(bookingDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 22,
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Booking Date: $formattedDate'),
                const SizedBox(height: 5),
                Text('Booking Time: ${booking['time'] ?? 'Not Specified'}'),
                const SizedBox(height: 5),
                Text('Name: ${booking['name']}'),
                const SizedBox(height: 5),
                Text('Additional Info: ${booking['additionalInfo'] ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
