import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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

      // Drawer with a button to block or unblock all bookings
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            // Block/Unblock Button
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('booking_block')
                  .doc('block_status')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }

                var blockStatus = snapshot.data!['block_all_bookings'] ?? false;

                return TextButton(
                  child: Text(blockStatus
                      ? 'Unblock All Bookings'
                      : 'Block All Bookings'),
                  onPressed: () async {
                    // Toggle block status
                    await FirebaseFirestore.instance
                        .collection('booking_block')
                        .doc('block_status')
                        .set({
                      'block_all_bookings': !blockStatus,
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
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
              String formattedDate =
                  DateFormat('dd MMMM yyyy, hh:mm a').format(bookingDate);

              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10), // Add spacing between details

                      // Display User Name instead of User ID
                      Text(
                        'Name: ${booking['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Additional Booking Details
                      Text(
                        'Booking Time: ${booking['time'] ?? 'Not Specified'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      //booking status
                      Text(
                        'Status: ${booking['booking_status'] ?? 'Not Specified'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Add spacing before the button

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
                          child: const Text('More Info'),
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
  void _showBookingDetailsDialog(
      BuildContext context, DocumentSnapshot booking) {
    String currentStatus = booking['booking_status'] ?? 'Pending';
    String selectedStatus = currentStatus;

    // Convert Firestore Timestamp to DateTime and format it for dialog display
    DateTime bookingDate = (booking['date'] as Timestamp).toDate();
    String formattedDate =
        DateFormat('dd MMMM yyyy, hh:mm a').format(bookingDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text(
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
                    const SizedBox(height: 20),

                    // Dropdown to change the status
                    const Text(
                      'Update Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        underline: const SizedBox(), // Remove default underline
                        items: <String>['Pending', 'Confirmed', 'Rejected']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: value == 'Pending'
                                    ? Colors.yellow[700]
                                    : value == 'Confirmed'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Update Status',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(booking.id)
                        .update({'booking_status': selectedStatus});
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Status updated to $selectedStatus')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
