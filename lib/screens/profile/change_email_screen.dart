// SmartChat - Change Email Screen
//
// Allows users to update their email securely.
// Requires current password verification before changing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../core/utils.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  bool _obscureCurrentPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter a new email';

    // Minimal email validation (kept simple on purpose).
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isValid) return 'Please enter a valid email address';

    final currentEmail = ref.read(authServiceProvider).currentUser?.email;
    if (currentEmail != null &&
        email.toLowerCase() == currentEmail.toLowerCase()) {
      return 'New email must be different from current email';
    }

    return null;
  }

  String? _validateConfirmEmail(String? value) {
    final confirmEmail = value?.trim() ?? '';
    if (confirmEmail.isEmpty) return 'Please confirm your new email';
    if (confirmEmail.toLowerCase() !=
        _newEmailController.text.trim().toLowerCase()) {
      return 'Emails do not match';
    }
    return null;
  }

  Future<void> _changeEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateEmail(
          currentPassword: _currentPasswordController.text,
          newEmail: _newEmailController.text,
        );

    if (!mounted) return;

    if (success) {
      AppUtils.showSnackBar(
        context,
        'Verification email sent. Confirm it to finish updating your login email.',
      );
      context.pop();
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      AppUtils.showSnackBar(
        context,
        error ?? 'Failed to update email',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final currentEmail = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.email, orElse: () => null);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentEmail == null
                            ? 'For security, enter your current password before updating your email.'
                            : 'Current email: $currentEmail\nFor security, enter your current password before updating your email.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // New Email
              TextFormField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm New Email
              TextFormField(
                controller: _confirmEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateConfirmEmail,
                decoration: InputDecoration(
                  labelText: 'Confirm New Email',
                  prefixIcon: const Icon(Icons.mark_email_read_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              FilledButton(
                onPressed: authState.isLoading ? null : _changeEmail,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
