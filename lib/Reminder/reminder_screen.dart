import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:reminders_app/Reminder/services.dart';
import 'details_screen.dart';
import 'widgets/action_buttons.dart';
import 'widgets/custom_day_picker.dart';
import 'widgets/date_field.dart';
import 'widgets/header.dart';
import 'widgets/time_field.dart';

class ReminderScreen extends StatefulWidget {
  static const String pageRoute = "/ReminderScreen";

  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  NotificationService notificationService = NotificationService();

  final int maxTitleLength = 50;
  TextEditingController _textEditingController = TextEditingController();

  int segmentedControlGroupValue = 0;

  DateTime currentDate = DateTime.now();
  DateTime? eventDate;
  TimeOfDay currentTime = TimeOfDay.now();
  TimeOfDay? eventTime;

  Future<void> onCreate() async {
    await notificationService.showNotification(
      0,
      _textEditingController.text,
      'A new event has been created.',
      jsonEncode({
        'title': _textEditingController.text,
        'eventDate': DateFormat('EEEE, d MMM y').format(eventDate!),
        'eventTime': eventTime!.format(context),
      }),
    );

    await notificationService.scheduleNotification(
      1,
      _textEditingController.text,
      'Reminder for your scheduled event at ${eventTime!.format(context)}',
      eventDate!,
      eventTime!,
      jsonEncode({
        'title': _textEditingController.text,
        'eventDate': DateFormat('EEEE, d MMM y').format(eventDate!),
        'eventTime': eventTime!.format(context),
      }),
      getDateTimeComponents(),
    );
    resetForm();
  }

  Future<void> cancelAllNotifications() async {
    await notificationService.cancelAllNotifications();
  }

  void resetForm() {
    segmentedControlGroupValue = 0;
    eventDate = null;
    eventTime = null;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _buildCancelAllButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.indigo[100],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Cancel all the reminders',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Icon(Icons.clear),
        ],
      ),
    );
  }

  DateTimeComponents? getDateTimeComponents() {
    if (segmentedControlGroupValue == 1) {
      return DateTimeComponents.time;
    } else if (segmentedControlGroupValue == 2) {
      return DateTimeComponents.dayOfWeekAndTime;
    }
  }

  void selectEventDate() async {
    final today =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    if (segmentedControlGroupValue == 0) {
      eventDate = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: today,
        lastDate: DateTime(currentDate.year + 10),
      );
      setState(() {});
    } else if (segmentedControlGroupValue == 1) {
      eventDate = today;
    } else if (segmentedControlGroupValue == 2) {
      CustomDayPicker(
        onDaySelect: (val) {
          debugPrint('$val: ${CustomDayPicker.weekdays[val]}');
          eventDate = today.add(
              Duration(days: (val - today.weekday + 1) % DateTime.daysPerWeek));
        },
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminder App"),
      //  centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 67, 67),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const DetailsScreen(payload: null)),
              );
            },
            icon: const Icon(
              Icons.library_books_rounded,
           //   color: Colors.black,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                spreadRadius: 5,
                blurRadius: 5,
                color: Colors.grey.withOpacity(0.4),
                offset: Offset(0, 0),
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const Header(),
                  TextFormField(
                    controller: _textEditingController,
                    maxLength: maxTitleLength,
                    decoration: const InputDecoration(
                      hintText: "Add event",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoSlidingSegmentedControl<int>(
                    onValueChanged: (value) {
                      if (value == 1) eventDate = null;
                      setState(() => segmentedControlGroupValue = value!);
                    },
                    groupValue: segmentedControlGroupValue,
                    padding: const EdgeInsets.all(4.0),
                    children: <int, Widget>{
                      0: const Text('One time'),
                      1: const Text('Daily'),
                      2: const Text('Weekly')
                    },
                  ),
                  const SizedBox(height: 24.0),
                  const Text('Date & Time'),
                  const SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: selectEventDate,
                    child: DateField(eventDate: eventDate),
                  ),
                  const SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () async {
                      eventTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: currentTime.hour,
                          minute: currentTime.minute + 1,
                        ),
                      );
                      setState(() {});
                    },
                    child: TimeField(eventTime: eventTime),
                  ),
                  const SizedBox(height: 20.0),
                  ActionButtons(
                    onCreate: onCreate,
                    onCancel: resetForm,
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () async {
                      await cancelAllNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notfications cancelled'),
                        ),
                      );
                    },
                    child: _buildCancelAllButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
