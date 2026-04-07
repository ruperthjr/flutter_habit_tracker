import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers.dart';
import '../../domain/models.dart';
import '../../../../core/theme/app_theme.dart';

class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key, this.editHabit});
  final Habit? editHabit;
  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _goalCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController(text: 'times');

  String    _icon      = '💧';
  Color     _color     = AppTheme.habitColors[0];
  HabitTime _time      = HabitTime.allDay;
  GoalType  _goalType  = GoalType.count;

  @override
  void initState() {
    super.initState();
    final h = widget.editHabit;
    if (h != null) {
      _nameCtrl.text = h.name;
      _goalCtrl.text = h.goalValue.toString();
      _unitCtrl.text = h.unit;
      _icon     = h.icon;
      _color    = h.color;
      _time     = h.timeOfDay;
      _goalType = h.goalType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _goalCtrl.dispose(); _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editHabit != null;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(isEdit ? 'Edit Habit' : 'New Habit',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),

            // ── Icon picker ──────────────────────────────────────────────────
            const _Label('Icon'),
            const SizedBox(height: 8),
            _IconPicker(selected: _icon, onPick: (v) => setState(() => _icon = v)),
            const SizedBox(height: 16),

            // ── Color picker ─────────────────────────────────────────────────
            const _Label('Color'),
            const SizedBox(height: 8),
            _ColorPicker(
              selected: _color,
              onPick: (v) => setState(() => _color = v),
            ),
            const SizedBox(height: 16),

            // ── Name ─────────────────────────────────────────────────────────
            const _Label('Habit Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textHigh),
              decoration: InputDecoration(
                hintText: 'e.g. Drink water',
                filled: true, fillColor: AppTheme.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // ── Time of day ───────────────────────────────────────────────────
            const _Label('Time of Day'),
            const SizedBox(height: 8),
            _TimeSegment(selected: _time, onPick: (v) => setState(() => _time = v)),
            const SizedBox(height: 16),

            // ── Goal type ─────────────────────────────────────────────────────
            const _Label('Goal Type'),
            const SizedBox(height: 8),
            _GoalTypeSegment(
              selected: _goalType,
              onPick: (v) => setState(() {
                _goalType = v;
                if (v == GoalType.check) {
                  _goalCtrl.text = '1'; _unitCtrl.text = 'times';
                } else if (v == GoalType.timer) {
                  _unitCtrl.text = 'min';
                }
              }),
            ),
            const SizedBox(height: 16),

            // ── Goal value + unit ─────────────────────────────────────────────
            if (_goalType != GoalType.check) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Target'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _goalCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.textHigh),
                          decoration: InputDecoration(
                            filled: true, fillColor: AppTheme.card,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Unit'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _unitCtrl,
                          style: const TextStyle(color: AppTheme.textHigh),
                          decoration: InputDecoration(
                            hintText: 'glasses, pages…',
                            filled: true, fillColor: AppTheme.card,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 8),

            // ── Save button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    final goalVal = int.tryParse(_goalCtrl.text) ?? 1;
    final unit    = _goalType == GoalType.check ? 'times' : _unitCtrl.text.trim();

    if (widget.editHabit != null) {
      ref.read(habitsProvider.notifier).edit(
        widget.editHabit!.copyWith(
          name: name, icon: _icon, color: _color,
          timeOfDay: _time, goalType: _goalType,
          goalValue: goalVal, unit: unit,
        ),
      );
    } else {
      ref.read(habitsProvider.notifier).add(Habit(
        id:        const Uuid().v4(),
        name:      name, icon: _icon, color: _color,
        timeOfDay: _time, goalType: _goalType,
        goalValue: goalVal, unit: unit,
        createdAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: AppTheme.textMid,
        fontSize: 12, fontWeight: FontWeight.w600,
        letterSpacing: 0.5));
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({required this.selected, required this.onPick});
  final String selected; final ValueChanged<String> onPick;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: AppTheme.habitIcons.map((ic) => GestureDetector(
      onTap: () => onPick(ic),
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: selected == ic ? AppTheme.accent.withOpacity(0.2) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected == ic ? AppTheme.accent : AppTheme.divider,
            width: selected == ic ? 2 : 1,
          ),
        ),
        child: Center(child: Text(ic, style: const TextStyle(fontSize: 20))),
      ),
    )).toList(),
  );
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onPick});
  final Color selected; final ValueChanged<Color> onPick;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10, runSpacing: 8,
    children: AppTheme.habitColors.map((c) => GestureDetector(
      onTap: () => onPick(c),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: c, shape: BoxShape.circle,
          border: c == selected
              ? Border.all(color: Colors.white, width: 2.5) : null,
          boxShadow: c == selected
              ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
        ),
      ),
    )).toList(),
  );
}

class _TimeSegment extends StatelessWidget {
  const _TimeSegment({required this.selected, required this.onPick});
  final HabitTime selected; final ValueChanged<HabitTime> onPick;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: HabitTime.values.map((t) {
      final sel = t == selected;
      return GestureDetector(
        onTap: () => onPick(t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppTheme.accent : AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: sel ? null : Border.all(color: AppTheme.divider),
          ),
          child: Text(t.label,
            style: TextStyle(
              color: sel ? Colors.white : AppTheme.textMid,
              fontWeight: FontWeight.w600, fontSize: 13,
            )),
        ),
      );
    }).toList(),
  );
}

class _GoalTypeSegment extends StatelessWidget {
  const _GoalTypeSegment({required this.selected, required this.onPick});
  final GoalType selected; final ValueChanged<GoalType> onPick;

  static const _labels = {
    GoalType.count: ('🔢', 'Count'),
    GoalType.timer: ('⏱️', 'Timer'),
    GoalType.check: ('✅', 'Checkbox'),
  };

  @override
  Widget build(BuildContext context) => Row(
    children: GoalType.values.map((t) {
      final sel = t == selected;
      final (emoji, label) = _labels[t]!;
      return Expanded(
        child: GestureDetector(
          onTap: () => onPick(t),
          child: Container(
            margin: EdgeInsets.only(right: t != GoalType.check ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppTheme.accent.withOpacity(0.2) : AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? AppTheme.accent : AppTheme.divider,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(label,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: sel ? AppTheme.accent : AppTheme.textMid,
                  )),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}