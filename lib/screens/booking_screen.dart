import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/local_notification_services.dart';


class CreateBookingScreen extends StatefulWidget {
  @override
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _bookingNameController = TextEditingController();
  final _numOfTeamsController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  Future<void> _confirmBooking() async {
    if (_bookingNameController.text.isEmpty ||
        _numOfTeamsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Add booking to Firestore
      await _firestore.collection('bookings').add({
        'name': _bookingNameController.text,
        'date': selectedDate,
        'time': selectedTime.format(context),
        'number_of_teams': int.parse(_numOfTeamsController.text),
        'day': _getDayOfWeek(selectedDate),
        'userId': FirebaseAuth.instance.currentUser?.uid, // Include userId
      });

      // Schedule notification
      DateTime bookingDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Schedule the notification
      await LocalNotificationService.scheduleNotification(
        id: 1, // You can generate a unique ID for each booking
        scheduledTime: bookingDateTime,
        title: 'Booking Reminder',
        body: 'Reminder for your booking with ${_bookingNameController.text} at ${selectedTime.format(context)}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Confirmed')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Booking'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Name
              TextField(
                controller: _bookingNameController,
                decoration: InputDecoration(
                  labelText: 'Name of Booking Person',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Date Picker
              TextButton(
                onPressed: () => _selectDate(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Select Date: ${selectedDate.toShortDateString()}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              // Time Picker
              TextButton(
                onPressed: () => _selectTime(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Select Time: ${selectedTime.format(context)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              // Number of Teams
              TextField(
                controller: _numOfTeamsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Teams',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Confirm Booking Button
              Center(
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Confirm Booking'),
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
    return '${this.day.toString().padLeft(2, '0')}/${this.month.toString().padLeft(2, '0')}/${this.year}';
  }
}
