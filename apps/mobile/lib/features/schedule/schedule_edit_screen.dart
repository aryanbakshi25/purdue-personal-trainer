import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/schedule_block.dart';
import '../../providers/schedule_provider.dart';

class ScheduleEditScreen extends ConsumerStatefulWidget {
  const ScheduleEditScreen({super.key, required this.blockId});

  /// null means creating a new block.
  final String? blockId;

  @override
  ConsumerState<ScheduleEditScreen> createState() =>
      _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends ConsumerState<ScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  String _dayOfWeek = 'monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _category = 'class';
  bool _isRecurring = true;
  bool _isSaving = false;

  bool get _isNew => widget.blockId == null;

  static const _days = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];

  static const _categories = [
    'class', 'work', 'gym', 'meal', 'study', 'other',
  ];

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      // Load existing block data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingBlock();
      });
    }
  }

  void _loadExistingBlock() {
    final blocks = ref.read(scheduleBlocksProvider).valueOrNull ?? [];
    final existing = blocks.where((b) => b.id == widget.blockId).firstOrNull;
    if (existing != null) {
      _titleController.text = existing.title;
      _locationController.text = existing.location ?? '';
      setState(() {
        _dayOfWeek = existing.dayOfWeek;
        _startTime = _parseTime(existing.startTime);
        _endTime = _parseTime(existing.endTime);
        _category = existing.category;
        _isRecurring = existing.isRecurring;
      });
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final block = ScheduleBlock(
      id: widget.blockId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      dayOfWeek: _dayOfWeek,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      category: _category,
      isRecurring: _isRecurring,
    );

    try {
      final service = ref.read(scheduleServiceProvider);
      if (_isNew) {
        await service.addBlock(block);
      } else {
        await service.updateBlock(block);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (_isNew) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Block?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(scheduleServiceProvider);
      await service.deleteBlock(widget.blockId!);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Schedule Block' : 'Edit Schedule Block'),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., CS 252 Lecture',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(labelText: 'Day'),
              items: _days
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d[0].toUpperCase() + d.substring(1)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _dayOfWeek = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start'),
                    subtitle: Text(
                      _formatTime(_startTime),
                      style: theme.textTheme.titleLarge,
                    ),
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End'),
                    subtitle: Text(
                      _formatTime(_endTime),
                      style: theme.textTheme.titleLarge,
                    ),
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g., LWSN B134',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0].toUpperCase() + c.substring(1)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring weekly'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isNew ? 'Add Block' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
