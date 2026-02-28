import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/utils/app_theme.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({super.key, this.initialDate, this.onDateChanged});

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime newdate;
  late DateTime _startDate;
  final DatePickerController _datePickerController = DatePickerController();

  @override
  void initState() {
    super.initState();
    newdate = widget.initialDate ?? DateTime.now();
    _startDate = DateTime(newdate.year, newdate.month, 1);
  }

  void _goToPreviousMonth() {
    setState(() {
      final prevMonth = DateTime(_startDate.year, _startDate.month - 1, 1);
      final now = DateTime.now();
      // Don't go before the current month
      if (prevMonth.year > now.year ||
          (prevMonth.year == now.year && prevMonth.month >= now.month)) {
        _startDate = prevMonth;
        newdate = prevMonth;
        widget.onDateChanged?.call(newdate);
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      _startDate = DateTime(_startDate.year, _startDate.month + 1, 1);
      newdate = _startDate;
      widget.onDateChanged?.call(newdate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _goToPreviousMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_ios, color: Colors.white60, size: 20),
                ),
              ),
              const Spacer(),
              Text(
                "${setMonth(newdate.month)}, ${newdate.year}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _goToNextMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white60,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: DatePicker(
            _startDate.isBefore(DateTime.now()) ? DateTime.now() : _startDate,
            controller: _datePickerController,
            deactivatedColor: Colors.white,
            initialSelectedDate: newdate,
            selectionColor: Colors.white,
            selectedTextColor: AppTheme.primaryColor,
            daysCount: _daysRemainingInMonth(),
            onDateChange: (date) {
              setState(() {
                newdate = date;
              });

              widget.onDateChanged?.call(date);
            },
          ),
        ),
      ],
    );
  }

  int _daysRemainingInMonth() {
    final lastDay = DateTime(_startDate.year, _startDate.month + 1, 0).day;
    final now = DateTime.now();
    if (_startDate.year == now.year && _startDate.month == now.month) {
      return lastDay - now.day + 1;
    }
    return lastDay;
  }

  String setMonth(monthNo) {
    switch (monthNo) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";

      default:
        return "";
    }
  }
}
