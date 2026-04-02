import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../providers/statistics_providers.dart' show refreshStatistics;
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

class LogbookDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> entry;

  const LogbookDetailPage({super.key, required this.entry});

  @override
  ConsumerState<LogbookDetailPage> createState() => _LogbookDetailPageState();
}

class _LogbookDetailPageState extends ConsumerState<LogbookDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<String> _getChallengeTitle(
    BuildContext context,
    String challengeId,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final challenges =
        await ChallengeRepository.instance.loadChallenges(locale);
    try {
      return challenges.firstWhere((c) => c.id == challengeId).title;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.of(context).logbookEntry),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FutureBuilder<String>(
              future: _getChallengeTitle(
                context,
                widget.entry['challenge_id']?.toString() ?? '',
              ),
              builder: (context, snapshot) {
                final challengeTitle = snapshot.data ?? '';
                final isCustom = widget.entry['status'] == 'custom';
                final displayTitle = isCustom && widget.entry['custom_title'] != null
                    ? widget.entry['custom_title']
                    : challengeTitle;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroHeader(displayTitle),
                      const SizedBox(height: AppSpacing.md),
                      _buildDetailsCard(),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeelingsCard(),
                      if (widget.entry['notes'] != null &&
                          widget.entry['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildNotesCard(),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _buildDeleteButton(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(String displayTitle) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final earned = widget.entry['earned'] ?? 0;
    final statusColor = _getStatusColor(earned);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.emoji_events, color: cs.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              displayTitle,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${earned >= 0 ? '+' : ''}$earned XP',
                    style: tt.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).details,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(
              Icons.calendar_today,
              S.of(context).date,
              _formatDate(widget.entry['timestamp']?.toString()),
            ),
            _buildDetailRow(
              Icons.info_outline,
              S.of(context).status,
              _localizedStatus(widget.entry['status']?.toString()),
            ),
            if (widget.entry['reward_factor'] != null)
              _buildDetailRow(
                Icons.trending_up,
                S.of(context).rewardFactor,
                '${(widget.entry['reward_factor'] * 100).toInt()}%',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingsCard() {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).feeling,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFeelingRow(
              S.of(context).howDidYouFeelQuestion,
              widget.entry['feeling'],
            ),
            _buildFeelingRow(
              S.of(context).howPerceivedByOthers,
              widget.entry['perception'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).notes,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.entry['notes']?.toString() ?? '',
                style: tt.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.delete_outline),
        label: Text(S.of(context).deleteEntry),
        style: TextButton.styleFrom(
          foregroundColor: cs.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showDeleteDialog(),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: cs.outline, size: 20),
          const SizedBox(width: 12),
          Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeelingRow(String label, dynamic value) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final feeling = value as int?;
    final emotColor = _emotionColor(feeling);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(_emotionIcon(feeling), color: emotColor, size: 24),
              const SizedBox(width: 8),
              Text(
                _emotionText(feeling),
                style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: emotColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final l = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteEntry),
        content: Text(l.deleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          SyntraButton(
            onPressed: () => _deleteEntry(),
            color: Theme.of(context).colorScheme.error,
            height: 40,
            depth: 3,
            child: Text(
              l.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry() async {
    try {
      await LogbookRepository.instance
          .deleteEntry(widget.entry['id'] as int);
      if (mounted) {
        refreshStatistics(ref);
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
    }
  }

  String _localizedStatus(String? status) {
    final l = S.of(context);
    switch (status) {
      case 'success': return l.statusSuccess;
      case 'tried': return l.statusTried;
      default: return status ?? l.unknown;
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return S.of(context).unknown;
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) { return timestamp; }
  }

  Color _getStatusColor(dynamic earned) {
    final xp = earned as int? ?? 0;
    if (xp > 0) return Colors.green;
    if (xp < 0) return Colors.red;
    return Colors.amber;
  }

  IconData _emotionIcon(int? feeling) {
    switch (feeling) {
      case 0: return Icons.sentiment_very_dissatisfied;
      case 1: return Icons.sentiment_dissatisfied;
      case 2: return Icons.sentiment_neutral;
      case 3: return Icons.sentiment_satisfied;
      case 4: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _emotionColor(int? feeling) {
    switch (feeling) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return Colors.amber;
      case 3: return Colors.lightGreen;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _emotionText(int? feeling) {
    final l = S.of(context);
    switch (feeling) {
      case 0: return l.veryBad;
      case 1: return l.bad;
      case 2: return l.neutral;
      case 3: return l.good;
      case 4: return l.veryGood;
      default: return l.unknown;
    }
  }
}
