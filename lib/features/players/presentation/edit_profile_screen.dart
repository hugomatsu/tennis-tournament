import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _categoryController;
  late TextEditingController _playingSinceController;
  bool _isLoading = false;
  String? _avatarUrl;
  
  final List<String> _titleSuggestions = [
    'Beginner', 'Novice', 'Intermediate', 'Club Player', 
    'Advanced', 'Semi-Pro', 'Pro', 'Coach', 'Enthusiast', 'Weekend Warrior'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _bioController = TextEditingController();
    _categoryController = TextEditingController();
    _playingSinceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _categoryController.dispose();
    _playingSinceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          appBar: AppBar(title: const Text('Select Image')),
          body: MediaLibraryPicker(
            onImageSelected: (asset) {
              setState(() => _avatarUrl = asset.url);
              context.pop();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      // User wants Month and Year. DatePicker gives full date.
      // We can format it.
      setState(() {
        _playingSinceController.text = DateFormat('MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: userAsync.when(
        data: (user) {
          // Initialize controllers if not already done (and if user exists)
          if (user != null && _nameController.text.isEmpty) {
            _nameController.text = user.name;
            _titleController.text = user.title;
            _bioController.text = user.bio;
            _categoryController.text = user.category;
            _playingSinceController.text = user.playingSince;
             _avatarUrl ??= user.avatarUrl;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null ? const Icon(Icons.camera_alt, size: 30) : null,
                    ),
                  ),
                  TextButton(onPressed: _pickImage, child: const Text('Change Photo')),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _titleSuggestions.contains(_titleController.text) ? _titleController.text : null,
                    decoration: const InputDecoration(labelText: 'Title'),
                    hint: const Text('Select Title'),
                    items: [
                      ..._titleSuggestions.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                      if (_titleController.text.isNotEmpty && !_titleSuggestions.contains(_titleController.text))
                        DropdownMenuItem(value: _titleController.text, child: Text(_titleController.text)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                         _titleController.text = val;
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category (e.g. A, B, C)'),
                  ),
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _playingSinceController,
                        decoration: const InputDecoration(
                          labelText: 'Playing Since',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isLoading ? null : () => _saveProfile(user),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _saveProfile(Player? existingUser) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedPlayer = existingUser?.copyWith(
            name: _nameController.text.trim(),
            title: _titleController.text.trim(),
            bio: _bioController.text.trim(),
            category: _categoryController.text.trim(),
            playingSince: _playingSinceController.text.trim(),
            avatarUrl: _avatarUrl ?? existingUser.avatarUrl,
          ) ??
          Player(
            id: '', // ID will be handled by repo/auth
            name: _nameController.text.trim(),
            title: _titleController.text.trim(),
            bio: _bioController.text.trim(),
            category: _categoryController.text.trim(),
            playingSince: _playingSinceController.text.trim(),
            wins: 0,
            losses: 0,
            rank: 0,
            avatarUrl: _avatarUrl ?? 'https://via.placeholder.com/150',
          );

      await ref.read(playerRepositoryProvider).updateUser(updatedPlayer);
      
      if (mounted) {
        context.pop();
        ref.invalidate(currentUserProvider); // Refresh profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

