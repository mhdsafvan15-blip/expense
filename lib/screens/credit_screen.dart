import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController toController = TextEditingController();

  String selectedCreditType = 'Subscriptions';
  String selectedPlanType = 'Monthly';
  DateTime selectedDate = DateTime(2026, 2, 22);

  final List<String> creditTypes = [
    'Subscriptions',
    'Loan',
    'Rent',
    'EMI',
    'Other',
  ];

  final List<String> planTypes = ['Monthly', 'Weekly', 'Yearly', 'One-time'];

  @override
  void dispose() {
    toController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveCredit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Credit saved: $selectedCreditType - ${toController.text.trim()}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Credit',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 48,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(5, 14, 5, 16),
            children: [
              _buildLabel('CREDIT TYPE'),
              const SizedBox(height: 5),
              _buildDropdown(
                value: selectedCreditType,
                items: creditTypes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCreditType = value);
                  }
                },
              ),

              const SizedBox(height: 9),

              _buildLabel('TO'),
              const SizedBox(height: 5),
              TextFormField(
                controller: toController,
                decoration: _inputDecoration(hint: 'Enter name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 9),

              _buildLabel('DATE'),
              const SizedBox(height: 5),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(7),
                child: InputDecorator(
                  decoration: _inputDecoration(
                    suffixIcon: const Icon(
                      Icons.calendar_month,
                      size: 17,
                      color: Colors.grey,
                    ),
                  ),
                  child: Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 9),

              _buildLabel('PLAN TYPE'),
              const SizedBox(height: 5),
              _buildDropdown(
                value: selectedPlanType,
                items: planTypes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPlanType = value);
                  }
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 37,
                child: ElevatedButton(
                  onPressed: _saveCredit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 8,
        color: Color(0xFF666666),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
      decoration: _inputDecoration(),
      style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}
