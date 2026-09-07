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
import '../../state/draft_providers.dart';

/// Screen 07 — Manage Medications (Step 1 of 3), plus steps 2 and 3.
///
/// * Step 1 — Medication details (name, dosage)
/// * Step 2 — Schedule (times, instructions)
/// * Step 3 — Review and save
///
/// The draft autosaves on every change and is restored when the form
/// reopens, so leaving mid-way never costs progress.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({this.editingId, super.key});

  /// Null when adding a new medication.
  final String? editingId;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _dosage;
  late final TextEditingController _instructions;
  String? _nameError;
  String? _dosageError;
  String? _timesError;

  static const _stepTitles = ['Medication details', 'Schedule', 'Review'];
  static const _stepSubtitles = [
    'Add medication details',
    'When each dose is due',
    'Check everything before saving',
  ];

  MedicationDraftNotifier get _draft =>
      ref.read(medicationDraftProvider.notifier);

  @override
  void initState() {
    super.initState();
    final draft = ref.read(medicationDraftProvider);
    _name = TextEditingController(text: draft.name);
    _dosage = TextEditingController(text: draft.dosage);
    _instructions = TextEditingController(text: draft.instructions);
    // Providers may not be modified during build, so the draft is prepared
    // one microtask later. The notifier methods are idempotent.
    Future<void>.microtask(_prepareDraft);
  }

  Future<void> _prepareDraft() async {
    final id = widget.editingId;
    if (id == null) {
      await _draft.startNew();
    } else {
      final medication = ref.read(medicationByIdProvider(id));
      if (medication != null) await _draft.startEditing(medication);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _syncControllers(MedicationDraft draft) {
    if (_name.text != draft.name) _name.text = draft.name;
    if (_dosage.text != draft.dosage) _dosage.text = draft.dosage;
    if (_instructions.text != draft.instructions) {
      _instructions.text = draft.instructions;
    }
  }

  // ── Navigation between steps ─────────────────────────────────────────────

  bool _validateStep(MedicationDraft draft) {
    setState(() {
      _nameError = _dosageError = _timesError = null;
      if (draft.step == 1) {
        if (draft.name.trim().isEmpty) {
          _nameError = 'Enter the medication name, like Metformin';
        }
        if (draft.dosage.trim().isEmpty) {
          _dosageError = 'Enter the dose, like 25 mg';
        }
      } else if (draft.step == 2 && draft.scheduleTimes.isEmpty) {
        _timesError = 'Add at least one time, like 8:00 AM';
      }
    });
    return _nameError == null && _dosageError == null && _timesError == null;
  }

  Future<void> _continue() async {
    final draft = ref.read(medicationDraftProvider);
    if (!_validateStep(draft)) return;
    if (draft.step < MedicationDraft.totalSteps) {
      _draft.update((d) => d.copyWith(step: d.step + 1));
      return;
    }
    await _save(draft);
  }

  void _back() {
    final draft = ref.read(medicationDraftProvider);
    if (draft.step > 1) {
      _draft.update((d) => d.copyWith(step: d.step - 1));
    } else {
      context.pop();
    }
  }

  Future<void> _save(MedicationDraft draft) async {
    final care = ref.read(careDataProvider.notifier);
    final editingId = draft.editingId;
    final existing = editingId == null
        ? null
        : ref.read(medicationByIdProvider(editingId));
    if (existing != null) {
      await care.updateMedication(
        existing.copyWith(
          name: draft.name.trim(),
          dosage: draft.dosage.trim(),
          scheduleTimes: draft.scheduleTimes,
          instructions: draft.instructions.trim().isEmpty
              ? null
              : draft.instructions.trim(),
          clearInstructions: draft.instructions.trim().isEmpty,
        ),
      );
    } else {
      await care.addMedication(
        name: draft.name,
        dosage: draft.dosage,
        scheduleTimes: draft.scheduleTimes,
        instructions: draft.instructions,
      );
    }
    await _draft.clear();
    if (!mounted) return;
    showConfirmationSnackBar(
      context,
      existing != null
          ? '${draft.name.trim()} updated'
          : '${draft.name.trim()} added',
    );
    context.pop();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'When is this dose due?',
    );
    if (picked == null) return;
    final value = DateFormatting.toLocalTime(picked);
    _draft.update((d) {
      if (d.scheduleTimes.contains(value)) return d;
      final times = [...d.scheduleTimes, value]..sort();
      return d.copyWith(scheduleTimes: times);
    });
    setState(() => _timesError = null);
  }

  void _removeTime(String time) {
    _draft.update(
      (d) => d.copyWith(
        scheduleTimes: d.scheduleTimes.where((t) => t != time).toList(),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(medicationDraftProvider, (_, next) => _syncControllers(next));
    final draft = ref.watch(medicationDraftProvider);
    final autosave = ref.watch(medicationAutosaveProvider);
    final step = draft.step.clamp(1, MedicationDraft.totalSteps);
    final isLast = step == MedicationDraft.totalSteps;

    return Scaffold(
      appBar: CcAppBar(
        title: draft.isEditing ? 'Edit Medication' : 'Add Medication',
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
                    totalSteps: MedicationDraft.totalSteps,
                    title: _stepTitles[step - 1],
                    subtitle: _stepSubtitles[step - 1],
                  ),
                  const SizedBox(height: Space.md),
                  if (step == 1) ..._detailsFields(draft),
                  if (step == 2) ..._scheduleFields(draft),
                  if (step == 3) _review(draft),
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
                                : 'Save medication',
                          ),
                        ),
                      ),
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

  List<Widget> _detailsFields(MedicationDraft draft) => [
    CcTextField(
      key: const Key('medication-name'),
      label: 'Medication name',
      controller: _name,
      hintText: 'Metformin',
      errorText: _nameError,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        if (_nameError != null) setState(() => _nameError = null);
        _draft.update((d) => d.copyWith(name: value));
      },
    ),
    const SizedBox(height: Space.md),
    CcTextField(
      key: const Key('medication-dosage'),
      label: 'Dosage',
      controller: _dosage,
      hintText: '25 mg',
      errorText: _dosageError,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        if (_dosageError != null) setState(() => _dosageError = null);
        _draft.update((d) => d.copyWith(dosage: value));
      },
    ),
  ];

  List<Widget> _scheduleFields(MedicationDraft draft) {
    final colors = context.ccColors;
    final theme = Theme.of(context);
    return [
      Text('Times each day', style: theme.textTheme.titleSmall),
      const SizedBox(height: Space.sm),
      if (draft.scheduleTimes.isEmpty)
        Text(
          'No times yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      for (final time in draft.scheduleTimes)
        Card(
          key: Key('time-$time'),
          margin: const EdgeInsets.only(bottom: Space.sm),
          child: ListTile(
            leading: Icon(Icons.schedule, color: colors.textSecondary),
            title: Text(DateFormatting.localTimeLabel(time)),
            trailing: IconButton(
              tooltip: 'Remove ${DateFormatting.localTimeLabel(time)}',
              icon: const Icon(Icons.close),
              onPressed: () => _removeTime(time),
            ),
          ),
        ),
      if (_timesError != null)
        Padding(
          padding: const EdgeInsets.only(top: Space.sm),
          child: Semantics(
            liveRegion: true,
            child: Text(
              _timesError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      const SizedBox(height: Space.sm),
      OutlinedButton.icon(
        key: const Key('add-time'),
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add a time'),
        onPressed: _addTime,
      ),
      const SizedBox(height: Space.md),
      CcTextField(
        key: const Key('medication-instructions'),
        label: 'Instructions (optional)',
        controller: _instructions,
        hintText: 'Take with food',
        onChanged: (value) =>
            _draft.update((d) => d.copyWith(instructions: value)),
      ),
    ];
  }

  Widget _review(MedicationDraft draft) {
    final theme = Theme.of(context);
    final times = draft.scheduleTimes
        .map(DateFormatting.localTimeLabel)
        .join(', ');
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: theme.textTheme.titleSmall),
            ),
            Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('Name', draft.name.trim()),
            row('Dosage', draft.dosage.trim()),
            row('Times', times.isEmpty ? '—' : times),
            row(
              'Instructions',
              draft.instructions.trim().isEmpty
                  ? 'None'
                  : draft.instructions.trim(),
            ),
          ],
        ),
      ),
    );
  }
}
