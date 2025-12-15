import 'package:flutter/material.dart';

import 'meeting_form_fields.dart';

class MeetingClientsSection extends StatelessWidget {
  final TextEditingController headingController;
  final TextEditingController client1NameController;
  final TextEditingController client1EmailController;
  final TextEditingController client2NameController;
  final TextEditingController client2EmailController;
  final TextEditingController client3NameController;
  final TextEditingController client3EmailController;
  final bool isSaving;

  /// Called so parent can call setState() to refresh visibility
  final VoidCallback onDynamicFieldsChanged;

  const MeetingClientsSection({
    super.key,
    required this.headingController,
    required this.client1NameController,
    required this.client1EmailController,
    required this.client2NameController,
    required this.client2EmailController,
    required this.client3NameController,
    required this.client3EmailController,
    required this.isSaving,
    required this.onDynamicFieldsChanged,
  });

  bool get _showSecondEmail =>
      client2NameController.text.trim().isNotEmpty;

  bool get _showThirdName =>
      client2NameController.text.trim().isNotEmpty &&
      client2EmailController.text.trim().isNotEmpty;

  bool get _showThirdEmail =>
      client3NameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meeting heading
        const RequiredLabel(label:'Meeting heading'),
        const SizedBox(height: 6),
        DarkTextField(
          controller: headingController,
          enabled: !isSaving,
          hintText: 'Eg. Follow-up with ABC Holdings',
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Meeting heading is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        // Client 1
        const RequiredLabel(label:'Client name'),
        const SizedBox(height: 6),
        DarkTextField(
          controller: client1NameController,
          enabled: !isSaving,
          hintText: 'Primary contact person',
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Client name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        const RequiredLabel(label:'Client email'),
        const SizedBox(height: 6),
        DarkTextField(
          controller: client1EmailController,
          enabled: !isSaving,
          hintText: 'name@company.com',
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Client email is required';
            }
            if (!val.contains('@')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),

        const SizedBox(height: 18),

        // 2nd client
        Text(
          '2nd client (optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[200],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        DarkTextField(
          controller: client2NameController,
          enabled: !isSaving,
          hintText: 'Name',
          onChanged: (_) => onDynamicFieldsChanged(),
        ),
        const SizedBox(height: 10),

        if (_showSecondEmail) ...[
          Text(
            '2nd client email',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[300],
                ),
          ),
          const SizedBox(height: 6),
          DarkTextField(
            controller: client2EmailController,
            enabled: !isSaving,
            hintText: 'email@company.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => onDynamicFieldsChanged(),
            validator: (val) {
              if (client2NameController.text.trim().isEmpty) {
                return null;
              }
              if (val == null || val.trim().isEmpty) {
                return 'Please enter 2nd client email';
              }
              if (!val.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        if (_showThirdName) ...[
          Text(
            '3rd client (optional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[200],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          DarkTextField(
            controller: client3NameController,
            enabled: !isSaving,
            hintText: 'Name',
            onChanged: (_) => onDynamicFieldsChanged(),
          ),
          const SizedBox(height: 10),
        ],

        if (_showThirdEmail) ...[
          Text(
            '3rd client email',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[300],
                ),
          ),
          const SizedBox(height: 6),
          DarkTextField(
            controller: client3EmailController,
            enabled: !isSaving,
            hintText: 'email@company.com',
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (client3NameController.text.trim().isEmpty) {
                return null;
              }
              if (val == null || val.trim().isEmpty) {
                return 'Please enter 3rd client email';
              }
              if (!val.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
