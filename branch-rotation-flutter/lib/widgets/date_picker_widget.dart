import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_constants.dart';

class DatePickerWidget extends StatelessWidget {
  final String selectedDate;
  final Function(String) onDateChanged;

  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      onDateChanged(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(selectedDate);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 12),
              const Text(
                '${AppConstants.asOnDateTitle}: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.edit),
                tooltip: 'Change Date',
              ),
            ],
          ),
        ),
      ),
    );
  }
}