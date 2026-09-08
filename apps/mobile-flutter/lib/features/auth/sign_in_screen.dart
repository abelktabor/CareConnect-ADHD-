import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/cc_text_field.dart';
import '../../core/widgets/choice_group.dart';
import '../../models/session.dart';
import '../../models/user_role.dart';
import '../../state/session_provider.dart';

/// Plain-language email validation: says what is wrong and how to fix it.
String? validateEmailAddress(String value) {
  final email = value.trim();
  if (email.isEmpty) {
    return 'Enter your email address, like you@email.com';
  }
  final at = email.indexOf('@');
  if (at < 1 || at == email.length - 1 || !email.substring(at).contains('.')) {
    return 'That email is missing something. Check it looks like you@email.com';
  }
  return null;
}

/// Screen 01 — Sign In / Role Selection.
///
/// No password, ever (WCAG 2.2 SC 3.3.8 Accessible Authentication): a passkey
/// / Face ID path first, an email handoff second, and one question — "I am
/// a…" — that decides which experience opens.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  UserRole _role = UserRole.careRecipient;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continueWithPasskey() => ref
      .read(sessionProvider.notifier)
      .signIn(role: _role, method: SignInMethod.passkey);

  Future<void> _continueWithEmail() async {
    final error = validateEmailAddress(_emailController.text);
    setState(() => _emailError = error);
    if (error != null) return;
    await ref
        .read(sessionProvider.notifier)
        .signIn(
          role: _role,
          method: SignInMethod.email,
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ccColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.formMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Space.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      'CareConnect',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    'Medications and appointments, without the memory test.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  FilledButton.icon(
                    key: const Key('signin-passkey'),
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Continue with Face ID / Passkey'),
                    onPressed: _continueWithPasskey,
                  ),
                  const SizedBox(height: Space.lg),
                  CcTextField(
                    key: const Key('signin-email'),
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'you@email.com',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    onSubmitted: (_) => _continueWithEmail(),
                  ),
                  const SizedBox(height: Space.sm + 4),
                  OutlinedButton(
                    key: const Key('signin-email-button'),
                    onPressed: _continueWithEmail,
                    child: const Text('Continue with Email'),
                  ),
                  const SizedBox(height: Space.xl),
                  Text(
                    'I am a…',
                    style: AppTypography.bodyEmphasis.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  ChoiceGroup<UserRole>(
                    groupLabel: 'I am a',
                    selected: _role,
                    onSelected: (role) => setState(() => _role = role),
                    options: [
                      for (final role in UserRole.values)
                        ChoiceOption(value: role, label: role.label),
                    ],
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
