import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/presentation/widgets/user_search_dialog.dart';
import 'package:tennis_tournament/core/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.profileNotFound),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/profile/edit'),
                    child: Text(loc.createProfile),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Clickable avatar with edit overlay
                GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                        foregroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                        onForegroundImageError: user.avatarUrl.isNotEmpty ? (_, __) {} : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (user.isPremium) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          loc.premium,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  user.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                // Stats Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.stats,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              label: loc.wins,
                              value: user.wins.toString(),
                              icon: Icons.emoji_events,
                              iconColor: Colors.amber,
                            ),
                            VerticalDivider(
                              width: 32,
                              thickness: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            FutureBuilder<int>(
                              future: ref.read(playerRepositoryProvider).getTournamentsParticipatedCount(user.id),
                              builder: (context, snapshot) {
                                return _StatItem(
                                  label: loc.tournaments,
                                  value: snapshot.data?.toString() ?? '0',
                                  icon: Icons.sports_tennis,
                                  iconColor: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.about,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _ProfileRow(
                        icon: Icons.category_outlined,
                        label: loc.category,
                        value: user.category,
                      ),
                      const Divider(height: 24),
                      _ProfileRow(
                        icon: Icons.calendar_today_outlined,
                        label: loc.playingSince,
                        value: user.playingSince,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Friends Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.following,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_search),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const UserSearchDialog(),
                              );
                            },
                            tooltip: loc.findPlayers,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, _) {
                           final friendsAsync = ref.watch(friendsProvider);
                           return friendsAsync.when(
                             data: (friends) {
                               if (friends.isEmpty) return Text(loc.notFollowingAnyone);
                               
                               return SizedBox(
                                 height: 90,
                                 child: ListView.separated(
                                   scrollDirection: Axis.horizontal,
                                   itemCount: friends.length,
                                   separatorBuilder: (_, __) => const SizedBox(width: 12),
                                   itemBuilder: (context, index) {
                                     final friend = friends[index];
                                     return InkWell(
                                       onTap: () => context.push('/players/${friend.id}'),
                                       borderRadius: BorderRadius.circular(8),
                                       child: Padding(
                                         padding: const EdgeInsets.all(4.0),
                                         child: Column(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                                                foregroundImage: friend.avatarUrl.isNotEmpty ? NetworkImage(friend.avatarUrl) : null,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                friend.name.split(' ').first,
                                                style: const TextStyle(fontSize: 11),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                           ],
                                         ),
                                       ),
                                     );
                                   },
                                 ),
                               );
                             },
                             loading: () => const LinearProgressIndicator(),
                             error: (e,s) => Text(loc.errorOccurred(e.toString())), 
                           );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  // My Plan Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.myPlan,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        if (!user.isPremium) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => context.push('/subscription'),
                              icon: const Icon(Icons.star),
                              label: Text(loc.upgradeToPremium),
                            ),
                          ),
                        ] else ...[
                           SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(loc.confirmCancelSubscription),
                                    content: Text(loc.cancelSubscriptionWarning), 
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.close)),
                                      FilledButton(
                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(loc.confirm),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true) {
                                  await ref.read(playerRepositoryProvider).cancelSubscription(user.id);
                                  ref.invalidate(currentUserProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.subscriptionCancelled)));
                                  }
                                }
                              },
                              child: Text(loc.cancelSubscription),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Content Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.content,
                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                         const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.photo_library),
                          title: Text(loc.myMediaLibrary),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/media-library'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // App & Settings Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.appAndSettings,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: Text(loc.theme),
                          trailing: Consumer(
                            builder: (context, ref, _) {
                              final currentMode = ref.watch(themeModeProvider);
                              return DropdownButton<ThemeMode>(
                                value: currentMode,
                                underline: const SizedBox.shrink(),
                                items: [
                                  DropdownMenuItem(value: ThemeMode.system, child: Text(loc.system)),
                                  DropdownMenuItem(value: ThemeMode.light, child: Text(loc.light)),
                                  DropdownMenuItem(value: ThemeMode.dark, child: Text(loc.dark)),
                                ],
                                onChanged: (ThemeMode? newMode) {
                                  if (newMode != null) {
                                    ref.read(themeModeProvider.notifier).setTheme(newMode);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const Divider(),
                         ListTile(
                          leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                          title: Text(loc.evaluateApp),
                          onTap: () async {
                              // TODO: Replace with actual store URLs
                             final url = Uri.parse('https://apps.apple.com/');
                             if (await canLaunchUrl(url)) {
                               await launchUrl(url);
                             }
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text(loc.privacyPolicy),
                          onTap: () async {
                             // TODO: Replace with actual Privacy Policy URL
                             final url = Uri.parse('https://entresets.com/privacy');
                             await launchUrl(url);
                          },
                        ),
                         ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(loc.termsOfUse),
                          onTap: () async {
                             // TODO: Replace with actual Terms URL
                             final url = Uri.parse('https://entresets.com/terms');
                             await launchUrl(url);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  if (user.userType == 'admin') ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.adminControls,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.dashboard_outlined),
                            title: Text(loc.adminDashboard),
                            onTap: () => context.push('/admin'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.bug_report_outlined),
                            title: Text(loc.simulationDebug),
                            onTap: () => context.push('/admin/simulation'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${loc.madeBy} ',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const TextSpan(
                            text: 'Hugomatsu', // Brand name, likely kept as is or localized if needed
                            style: TextStyle(
                              // Using primary color or a specific highlight color
                              color: Colors.blue, 
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _StatItem({
    required this.label, 
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28, color: iconColor ?? Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
