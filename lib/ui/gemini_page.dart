import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/service/service.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final _controlerName = TextEditingController();
  final _controlerDuration = TextEditingController();
  String _selectedPriority = "High";
  DateTime? _fromDate;
  DateTime? _untilDate;
  String _result = "";
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _untilDate = picked;
        }
      });
    }
  }

  Future<void> generateSchedule() async {
    setState(() {
      isLoading = true;
    });

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        _fromDate != null ? formatter.format(_fromDate!) : "Select Schedule";
    String untilDate =
        _untilDate != null ? formatter.format(_untilDate!) : "Select Schedule";

    final result = await Service.generateSchedule(
      _controlerName.text,
      _controlerDuration.text,
      _selectedPriority,
      fromDate,
      untilDate,
    );

    setState(() {
      _result = result;
      isLoading = false;
    });
  }

  @override
  void initState() {
    dotenv.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule Generator")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _textField("Schedule Name", _controlerName),
              const SizedBox(height: 10),
              _dropdown(),
              const SizedBox(height: 10),
              _textField("Duration", _controlerDuration, isNumber: true),
              const SizedBox(height: 10),
              _datePicker(
                "From Date",
                _fromDate,
                () => _selectDate(context, true),
              ),
              const SizedBox(height: 10),
              _datePicker(
                "Until Date",
                _untilDate,
                () => _selectDate(context, false),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : generateSchedule,
                child: Text("Generate Schedule"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      items:
          [
            "High",
            "Medium",
            "Low",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedPriority = value!;
        });
      },
      decoration: InputDecoration(labelText: "Priority"),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return ListTile(
      title: Text(
        date == null
            ? '$label pilih tanggal'
            : '$label ${DateFormat('yyyy-MM-dd').format(date)}',
      ),
    );
  }

  Widget _buildResult() {
    return isLoading ? CircularProgressIndicator() : Text(_result);
  }
}
