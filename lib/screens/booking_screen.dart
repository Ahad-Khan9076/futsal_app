import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/local_notification_services.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _bookingNameController = TextEditingController();
  final _numOfTeamsController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool isBookingBlocked = false; // Track if booking is blocked
  bool isLoading = true; // Track if data is still loading

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
  }

  Future<void> _checkBookingStatus() async {
    try {
      // Fetch booking block status from Firestore
      DocumentSnapshot bookingBlockStatus = await _firestore
          .collection('booking_block')
          .doc('block_status') // Assuming the document ID is 'status'
          .get();
      setState(() {
        isBookingBlocked = bookingBlockStatus['block_all_bookings'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching booking status: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_bookingNameController.text.isEmpty ||
        _numOfTeamsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    DateTime bookingDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (bookingDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a date and time in the future')),
      );
      return;
    }

    // Check if there is an existing booking at the same time
    bool isExistingBooking = await _checkExistingBooking(bookingDateTime);

    if (isExistingBooking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'This time slot is already booked. Please choose another time.')),
      );
      return;
    }

    try {
      await _firestore.collection('bookings').add({
        'name': _bookingNameController.text,
        'date': selectedDate,
        'time': selectedTime.format(context),
        'number_of_teams': int.parse(_numOfTeamsController.text),
        'day': _getDayOfWeek(selectedDate),
        'booking_status': 'Pending',
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      await LocalNotificationService.scheduleNotification(
        id: 1,
        scheduledTime: bookingDateTime,
        title: 'Booking Reminder',
        body:
            'Reminder for your booking with ${_bookingNameController.text} at ${selectedTime.format(context)}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Confirmed')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm booking')),
      );
    }
  }

  Future<bool> _checkExistingBooking(DateTime bookingDateTime) async {
    try {
      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('date',
              isEqualTo: DateTime(bookingDateTime.year, bookingDateTime.month,
                  bookingDateTime.day))
          .where('time',
              isEqualTo: TimeOfDay(
                      hour: bookingDateTime.hour,
                      minute: bookingDateTime.minute)
                  .format(context))
          .get();

      // If any booking already exists for the same date and time
      if (bookingSnapshot.docs.isNotEmpty) {
        return true; // A booking already exists
      }
      return false; // No existing booking found
    } catch (e) {
      print('Error checking existing booking: $e');
      return false;
    }
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isBookingBlocked
              ? const Center(
                  child: Text(
                    'Bookings are currently blocked. Please try again later.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Name
                    TextField(
                      controller: _bookingNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name of Booking Person',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
                    TextButton(
                      onPressed: () => _selectDate(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Select Date: ${selectedDate.toShortDateString()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time Picker
                    TextButton(
                      onPressed: () => _selectTime(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Select Time: ${selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Number of Teams
                    TextField(
                      controller: _numOfTeamsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Teams',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Booking Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Confirm Booking'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

extension on DateTime {
  String toShortDateString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}
