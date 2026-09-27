// Forms & inputs: validation, text fields, checkboxes, switches, sliders,
// dropdowns, pickers.
import 'package:flutter/material.dart';

import '../../widgets/demo_scaffold.dart';

enum Plan { free, pro, team }

class FormsDemo extends StatefulWidget {
  const FormsDemo({super.key});
  @override
  State<FormsDemo> createState() => _FormsDemoState();
}

class _FormsDemoState extends State<FormsDemo> {
  // GlobalKey<FormState> lets us call validate() ≈ checking each
  // TextInputLayout.error manually in Android.
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(); // ≈ EditText.text
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _agree = false;
  bool _notifications = true;
  Plan _plan = Plan.free;
  double _experience = 2;
  String _country = 'India';
  DateTime? _dob;
  TimeOfDay? _reminder;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // ≈ MaterialDatePicker / DatePickerDialog
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  void _submit() {
    FocusScope.of(context).unfocus(); // ≈ hide soft keyboard
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submitted ✅'),
        content: Text(
          'Name: ${_name.text}\nEmail: ${_email.text}\nPlan: ${_plan.name}\n'
          'Experience: ${_experience.round()} yrs\nCountry: $_country\n'
          'DOB: ${_dob == null ? '-' : MaterialLocalizations.of(context).formatShortDate(_dob!)}\n'
          'Reminder: ${_reminder?.format(context) ?? '-'}\n'
          'Notifications: $_notifications',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Forms & Inputs',
      android: 'EditText + TextInputLayout, CheckBox, Switch, RadioGroup, '
          'SeekBar, Spinner, DatePickerDialog',
      flutter: 'Form + TextFormField(validator), Checkbox, Switch, '
          'SegmentedButton, Slider, DropdownButton, showDatePicker',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next, // ≈ imeOptions
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress, // ≈ inputType
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v ?? '');
                  return ok ? null : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscure, // ≈ inputType="textPassword"
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  helperText: 'Min 8 chars',
                  suffixIcon: IconButton(
                    // ≈ endIconMode="password_toggle"
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v ?? '').length < 8 ? 'At least 8 characters' : null,
              ),
            ],
          ),
        ),
        const SectionTitle('Plan (≈ RadioGroup)'),
        SegmentedButton<Plan>(
          segments: const [
            ButtonSegment(value: Plan.free, label: Text('Free')),
            ButtonSegment(value: Plan.pro, label: Text('Pro')),
            ButtonSegment(value: Plan.team, label: Text('Team')),
          ],
          selected: {_plan},
          onSelectionChanged: (s) => setState(() => _plan = s.first),
        ),
        const SectionTitle('Experience (≈ SeekBar / Slider)'),
        Slider(
          value: _experience,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${_experience.round()} yrs',
          onChanged: (v) => setState(() => _experience = v),
        ),
        const SectionTitle('Country (≈ Spinner)'),
        DropdownButton<String>(
          value: _country,
          isExpanded: true,
          items: const ['India', 'USA', 'Germany', 'Japan', 'Brazil']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _country = v!),
        ),
        const SectionTitle('Pickers'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.cake_outlined),
                label: Text(_dob == null
                    ? 'Date of birth'
                    : MaterialLocalizations.of(context).formatShortDate(_dob!)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.alarm),
                label: Text(_reminder?.format(context) ?? 'Reminder'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Notifications (≈ SwitchMaterial)'),
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        CheckboxListTile(
          title: const Text('I agree to the terms (≈ CheckBox)'),
          value: _agree,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) => setState(() => _agree = v ?? false),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _submit, child: const Text('Submit')),
      ],
    );
  }
}
