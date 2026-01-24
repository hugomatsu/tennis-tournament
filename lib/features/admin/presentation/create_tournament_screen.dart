import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/locations/presentation/location_picker.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLocationId;
  String _tournamentType = 'mataMata'; // 'mataMata' or 'openTennis'
  int _groupCount = 0; // 0 = auto
  int _pointsPerWin = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.selectLocation),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: LocationPicker(
                onLocationSelected: (location) {
                  setState(() {
                    _locationController.text = location.name;
                    _selectedLocationId = location.id;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showMediaLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.selectImage),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: MediaLibraryPicker(
                onImageSelected: (asset) {
                  setState(() {
                    _imageUrlController.text = asset.url;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectDateRange)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final playerRepo = ref.read(playerRepositoryProvider);
      final tournamentRepo = ref.read(tournamentRepositoryProvider);
      final l10n = AppLocalizations.of(context)!;
      
      final currentUser = await playerRepo.getCurrentUser();
      if (currentUser == null) {
           if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pleaseLogIn)),
            );
           }
         return;
      }

      // Check limits
      if (!currentUser.isPremium) {
        final count = await tournamentRepo.getUserTournamentCount(currentUser.id);
        if (count >= 2) { // Configurable limit
          if (mounted) {
            _showUpsellDialog(context, l10n);
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      final dateFormat = DateFormat('MMMM d, y');
      final dateRangeString = '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';

      final tournament = Tournament(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        locationId: _selectedLocationId,
        ownerId: currentUser.id,
        adminIds: [currentUser.id],
        description: _descriptionController.text.trim(),
        dateRange: dateRangeString,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : 'https://via.placeholder.com/400x200',
        status: 'Upcoming',
        playersCount: 0,
        subscriptionTier: currentUser.isPremium ? 'Premium' : 'Free', // Set tier
        tournamentType: _tournamentType,
        groupCount: _groupCount,
        pointsPerWin: _pointsPerWin,
      );

      await tournamentRepo.createTournament(tournament);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tournamentCreated)),
        );
        // Refresh the tournament list to show the new item
        ref.invalidate(filteredTournamentsProvider(const TournamentFilterParams(mine: true)));
        ref.invalidate(filteredTournamentsProvider(const TournamentFilterParams())); // Invalidate default as well
        
        // Use push replacement or just go to ensure we land on details
        context.pushReplacement('/tournaments/${tournament.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred(e.toString())}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUpsellDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.freeLimitReached),
        content: Text(l10n.freeLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription'); // Assuming route exists or will be added
            },
            child: Text(l10n.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTournament)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.tournamentName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.emoji_events),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.enterName : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.location,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                onTap: _showLocationPicker,
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.pleaseSelectLocation : null,
              ),
              const SizedBox(height: 16),
              
              // Date Range Picker
              InkWell(
                onTap: () => _selectDateRange(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.dateRange,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.date_range),
                  ),
                  child: Text(
                    _startDate != null && _endDate != null
                        ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                        : l10n.selectDates,
                    style: TextStyle(
                      color: _startDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Tournament Type Selector
              DropdownButtonFormField<String>(
                value: _tournamentType,
                decoration: InputDecoration(
                  labelText: 'Tournament Mode',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.sports_tennis),
                  helperText: _tournamentType == 'mataMata' 
                      ? 'Direct elimination: lose once and you\'re out'
                      : 'Round-robin groups + playoff bracket',
                  helperMaxLines: 2,
                ),
                items: const [
                  DropdownMenuItem(value: 'mataMata', child: Text('Mata-Mata (Elimination)')),
                  DropdownMenuItem(value: 'openTennis', child: Text('Open Tennis (Groups)')),
                ],
                onChanged: (value) => setState(() => _tournamentType = value ?? 'mataMata'),
              ),
              
              // Open Tennis specific settings
              if (_tournamentType == 'openTennis') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Open Tennis Mode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Players are divided into groups. Each player plays against all others in their group. '
                        'Points are awarded for wins. Top players from each group advance to the playoff bracket.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _groupCount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Number of Groups',
                          helperText: '0 = automatic (half of players)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _groupCount = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _pointsPerWin.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Points per Win',
                          helperText: 'Points awarded for each victory',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.emoji_events),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _pointsPerWin = int.tryParse(v) ?? 3,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Image Picker
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: l10n.coverImageUrl,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.image),
                      ),
                      readOnly: true, // Make it read-only so user uses the picker
                      onTap: _showMediaLibrary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _showMediaLibrary,
                    icon: const Icon(Icons.photo_library),
                    tooltip: l10n.selectFromLibrary,
                  ),
                ],
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createTournament,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                       : Text(l10n.createTournament),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
