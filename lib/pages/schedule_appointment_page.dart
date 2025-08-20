import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({Key? key}) : super(key: key);

  @override
  State<ScheduleAppointmentPage> createState() => _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _odSphereController = TextEditingController();
  final TextEditingController _odCylinderController = TextEditingController();
  final TextEditingController _odAxisController = TextEditingController();
  final TextEditingController _odPrismController = TextEditingController();
  final TextEditingController _odAddController = TextEditingController();

  final TextEditingController _osSphereController = TextEditingController();
  final TextEditingController _osCylinderController = TextEditingController();
  final TextEditingController _osAxisController = TextEditingController();
  final TextEditingController _osPrismController = TextEditingController();
  final TextEditingController _osAddController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isSubmitting = false;
  List<String> _bookedSlots = [];

  final List<String> _timeSlots = [
    "9:00 AM", "10:00 AM", "11:00 AM", "2:00 PM", "3:00 PM", "4:00 PM",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _nameController.text = data?['full_name'] ?? '';
          _phoneController.text = data?['contact'] ?? '';
          _emailController.text = data?['email'] ?? user.email ?? '';
        });
      } else {
        // If user document doesn't exist, fallback to FirebaseAuth data
        setState(() {
          _emailController.text = user.email ?? '';
        });
      }
    }
  }
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
        _bookedSlots.clear();
      });
      await _fetchBookedSlots(picked);
    }
  }

  Future<void> _fetchBookedSlots(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('scheduledAt', isGreaterThanOrEqualTo: start)
        .where('scheduledAt', isLessThan: end)
        .get();

    final booked = <String>[];

    for (var doc in snapshot.docs) {
      final timestamp = doc['scheduledAt'] as Timestamp;
      final dateTime = timestamp.toDate();
      final timeString = _formatTime(dateTime);
      booked.add(timeString);
    }

    setState(() {
      _bookedSlots = booked;
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute $suffix";
  }

  DateTime? get _finalScheduledDateTime {
    if (_selectedDate == null || _selectedTimeSlot == null) return null;

    final timeParts = _selectedTimeSlot!.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final int minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';

    if (hour == 12) {
      hour = isPM ? 12 : 0;
    } else if (isPM) {
      hour += 12;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      minute,
    );
  }

  Future<void> _submitAppointment() async {
    final scheduledAt = _finalScheduledDateTime;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both a date and time slot.")),
      );
      return;
    }

    final now = DateTime.now();
    if (scheduledAt!.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot schedule in the past.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'prescription': {
          'OD': {
            'sphere': _odSphereController.text,
            'cylinder': _odCylinderController.text,
            'axis': _odAxisController.text,
            'prism': _odPrismController.text,
            'add': _odAddController.text,
          },
          'OS': {
            'sphere': _osSphereController.text,
            'cylinder': _osCylinderController.text,
            'axis': _osAxisController.text,
            'prism': _osPrismController.text,
            'add': _osAddController.text,
          },
        },
        'scheduledAt': scheduledAt,
        'createdAt': Timestamp.now(),
        'status': 'approved',
        'state': 'upcoming',
        'showStatus': 'no',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment scheduled successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: \${e.toString()}")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _isSlotDisabled(String slot) {
    if (_selectedDate == null) return true;
    if (_bookedSlots.contains(slot)) return true;

    final now = DateTime.now();
    final slotDateTime = _getDateTimeFromSlot(slot);

    final isToday = _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    return isToday && slotDateTime.isBefore(now);
  }

  DateTime _getDateTimeFromSlot(String slot) {
    final timeParts = slot.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final int minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      minute,
    );
  }

  Widget _buildPrescriptionCell(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 44, 52),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Schedule Appointment",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Select Date & Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? "dd/mm/yyyy"
                          : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),

                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.date_range_outlined, color: Colors.grey),
            ]),
            const SizedBox(height: 24),
            const Row(children: [
              Icon(Icons.access_time),
              SizedBox(width: 10),
              Text("Available Times",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                final isDisabled = _isSlotDisabled(slot);
                return ChoiceChip(
                  label: Text(
                    slot,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey.shade500
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isDisabled ? null : (_) => setState(() => _selectedTimeSlot = slot),
                  selectedColor: const Color(0xFF3B5B8F),
                  backgroundColor: isDisabled ? Colors.grey.shade300 : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: isDisabled ? Colors.grey.shade400 : Colors.black26),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text("Your Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                hintText: "Full Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? "Enter your name" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: "Contact Number",
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? "Enter your contact number" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                hintText: "Email Address",
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? "Enter your email" : null,
            ),
            const SizedBox(height: 16),
            const Text("Prescription (optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.black26),
              columnWidths: const {0: FixedColumnWidth(80)},
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(""),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Sphere", textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Cylinder", textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Axis", textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Prism", textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Add", textAlign: TextAlign.center),
                    ),
                  ],
                ),
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Right (OD)", textAlign: TextAlign.center),
                  ),
                  _buildPrescriptionCell(_odSphereController),
                  _buildPrescriptionCell(_odCylinderController),
                  _buildPrescriptionCell(_odAxisController),
                  _buildPrescriptionCell(_odPrismController),
                  _buildPrescriptionCell(_odAddController),
                ]),
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Left (OS)", textAlign: TextAlign.center),
                  ),
                  _buildPrescriptionCell(_osSphereController),
                  _buildPrescriptionCell(_osCylinderController),
                  _buildPrescriptionCell(_osAxisController),
                  _buildPrescriptionCell(_osPrismController),
                  _buildPrescriptionCell(_osAddController),
                ]),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 44, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Schedule Appointment", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}