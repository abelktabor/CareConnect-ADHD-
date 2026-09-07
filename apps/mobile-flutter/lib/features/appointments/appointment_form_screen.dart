import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/autosave_indicator.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/cc_text_field.dart';
import '../../core/widgets/step_indicator.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../../models/drafts.dart';
import '../../state/care_data_provider.dart';
import '../../state/care_selectors.dart';
import '../../state/clock_provider.dart';
import '../../state/draft_providers.dart';

/// Screen 08 — Manage Appointments (Step 2 of 2), plus step 1.
///
/// * Step 1 — What & where (title, location)
/// * Step 2 — Date, time & companion
class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({this.editingId, super.key});

  final String? editingId;

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _companion;
  final TextEditingController _when = TextEditingController();
  String? _titleError;
  String? _locationError;
  String? _whenError;

  static const _stepTitles = ['What & where', 'Date, time & companion'];
  static const _stepSubtitles = [
    'What the appointment is and where it is',
    'When it is and who is coming along',
  ];

  AppointmentDraftNotifier get _draft =>
      ref.read(appointmentDraftProvider.notifier);

  @override
  void initState() {
    super.initState();
    final draft = ref.read(appointmentDraftProvider);
    _title = TextEditingController(text: draft.title);
    _location = TextEditingController(text: draft.locationName);
    _companion = TextEditingController(text: draft.companionName);
    _when.text = _whenText(draft);
    Future<void>.microtask(_prepareDraft);
  }

  Future<void> _prepareDraft() async {
    final id = widget.editingId;
    if (id == null) {
      await _draft.startNew();
    } else {
      final appointment = ref.read(appointmentByIdProvider(id));
      if (appointment != null) await _draft.startEditing(appointment);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _companion.dispose();
    _when.dispose();
    super.dispose();
  }

  static String _whenText(AppointmentDraft draft) =>
      draft.startsAt == null ? '' : DateFormatting.dateAndTime(draft.startsAt!);

  void _syncControllers(AppointmentDraft draft) {
    if (_title.text != draft.title) {
      _title.text = draft.title;
    }
    if (_location.text != draft.locationName) {
      _location.text = draft.locationName;
    }
    if (_companion.text != draft.companionName) {
      _companion.text = draft.companionName;
    }
    final when = _whenText(draft);
    if (_when.text != when) {
      _when.text = when;
    }
  }

  bool _validateStep(AppointmentDraft draft) {
    setState(() {
      _titleError = _locationError = _whenError = null;
      if (draft.step == 1) {
        if (draft.title.trim().isEmpty) {
          _titleError =
              'Enter what the appointment is, like Dentist — cleaning';
        }
        if (draft.locationName.trim().isEmpty) {
          _locationError = 'Enter where it is, like Regional Medical';
        }
      } else if (draft.startsAt == null) {
        _whenError = 'Choose the date and time';
      }
    });
    return _titleError == null && _locationError == null && _whenError == null;
  }

  Future<void> _continue() async {
    final draft = ref.read(appointmentDraftProvider);
    if (!_validateStep(draft)) return;
    if (draft.step < AppointmentDraft.totalSteps) {
      _draft.update((d) => d.copyWith(step: d.step + 1));
      return;
    }
    await _save(draft);
  }

  void _back() {
    final draft = ref.read(appointmentDraftProvider);
    if (draft.step > 1) {
      _draft.update((d) => d.copyWith(step: d.step - 1));
    } else {
      context.pop();
    }
  }

  Future<void> _save(AppointmentDraft draft) async {
    final care = ref.read(careDataProvider.notifier);
    final editingId = draft.editingId;
    final existing = editingId == null
        ? null
        : ref.read(appointmentByIdProvider(editingId));
    final companion = draft.companionName.trim();
    if (existing != null) {
      await care.updateAppointment(
        existing.copyWith(
          title: draft.title.trim(),
          locationName: draft.locationName.trim(),
          startsAt: draft.startsAt,
          companionName: companion.isEmpty ? null : companion,
          clearCompanion: companion.isEmpty,
        ),
      );
    } else {
      await care.addAppointment(
        title: draft.title,
        locationName: draft.locationName,
        startsAt: draft.startsAt!,
        companionName: companion,
      );
    }
    await _draft.clear();
    if (!mounted) return;
    showConfirmationSnackBar(
      context,
      existing != null ? 'Appointment updated' : 'Appointment added',
    );
    context.pop();
  }

  Future<void> _pickDateTime() async {
    final now = ref.read(currentTimeProvider);
    final current = ref.read(appointmentDraftProvider).startsAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Which day is the appointment?',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'What time is the appointment?',
    );
    if (time == null) return;
    _draft.update(
      (d) => d.copyWith(startsAt: DateFormatting.combine(date, time)),
    );
    setState(() => _whenError = null);
  }

  Future<void> _confirmDelete(AppointmentDraft draft) async {
    final id = draft.editingId;
    if (id == null) return;
    final colors = context.ccColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this appointment?'),
        content: Text(
          'This removes ${draft.title.trim()} from the list. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(careDataProvider.notifier).deleteAppointment(id);
    await _draft.clear();
    if (!mounted) return;
    showConfirmationSnackBar(context, 'Appointment removed');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appointmentDraftProvider, (_, next) => _syncControllers(next));
    final draft = ref.watch(appointmentDraftProvider);
    final autosave = ref.watch(appointmentAutosaveProvider);
    final step = draft.step.clamp(1, AppointmentDraft.totalSteps);
    final isLast = step == AppointmentDraft.totalSteps;
    final colors = context.ccColors;

    return Scaffold(
      appBar: CcAppBar(
        title: draft.isEditing ? 'Edit Appointment' : 'Add Appointment',
        showBack: true,
        onBack: _back,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.formMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepIndicator(
                    step: step,
                    totalSteps: AppointmentDraft.totalSteps,
                    title: _stepTitles[step - 1],
                    subtitle: _stepSubtitles[step - 1],
                  ),
                  const SizedBox(height: Space.md),
                  if (step == 1) ...[
                    CcTextField(
                      key: const Key('appointment-title'),
                      label: 'Appointment',
                      controller: _title,
                      hintText: 'Dr. Alvarez — Cardiology follow-up',
                      errorText: _titleError,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        if (_titleError != null) {
                          setState(() => _titleError = null);
                        }
                        _draft.update((d) => d.copyWith(title: value));
                      },
                    ),
                    const SizedBox(height: Space.md),
                    CcTextField(
                      key: const Key('appointment-location'),
                      label: 'Where',
                      controller: _location,
                      hintText: 'Regional Medical',
                      errorText: _locationError,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        if (_locationError != null) {
                          setState(() => _locationError = null);
                        }
                        _draft.update((d) => d.copyWith(locationName: value));
                      },
                    ),
                  ] else ...[
                    CcTextField(
                      key: const Key('appointment-when'),
                      label: 'Date & time',
                      controller: _when,
                      hintText: 'Choose the date and time',
                      errorText: _whenError,
                      readOnly: true,
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: Space.md),
                    CcTextField(
                      key: const Key('appointment-companion'),
                      label: 'Who is taking me',
                      controller: _companion,
                      hintText: 'Renee — leave blank if going alone',
                      textInputAction: TextInputAction.done,
                      onChanged: (value) => _draft.update(
                        (d) => d.copyWith(companionName: value),
                      ),
                    ),
                  ],
                  const SizedBox(height: Space.sm),
                  AutosaveIndicator(status: autosave),
                  const SizedBox(height: Space.lg),
                  Row(
                    children: [
                      TextButton(
                        key: const Key('form-back'),
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: FilledButton(
                          key: const Key('form-continue'),
                          onPressed: _continue,
                          child: Text(
                            !isLast
                                ? 'Continue'
                                : draft.isEditing
                                ? 'Save changes'
                                : 'Save appointment',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (draft.isEditing) ...[
                    const SizedBox(height: Space.lg),
                    TextButton.icon(
                      key: const Key('delete-appointment'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete appointment'),
                      onPressed: () => _confirmDelete(draft),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
