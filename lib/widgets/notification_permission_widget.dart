import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'syntra_button.dart';
import '../generated/l10n.dart';
import '../services/syntra_notification_service.dart';

/// Professional-grade Permission UI Widget.
class NotificationPermissionWidget extends StatefulWidget {
  final Function(bool hasAllPermissions)? onPermissionResult;
  final bool showAsDialog;
  final String? customTitle;
  final String? customDescription;

  const NotificationPermissionWidget({
    super.key,
    this.onPermissionResult,
    this.showAsDialog = false,
    this.customTitle,
    this.customDescription,
  });

  @override
  State<NotificationPermissionWidget> createState() => _NotificationPermissionWidgetState();

  /// Static method to show permission dialog like professional apps
  static Future<bool> showPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NotificationPermissionWidget(showAsDialog: true),
    );
    return result ?? false;
  }
}

class _NotificationPermissionWidgetState extends State<NotificationPermissionWidget>
    with TickerProviderStateMixin {
  NotificationPermissionStatus? _permissionStatus;
  bool _isLoading = false;
  bool _isRequestingPermission = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkCurrentPermissions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentPermissions() async {
    setState(() => _isLoading = true);

    try {
      final status = await SyntraNotificationService.instance.requestPermissions();
      setState(() {
        _permissionStatus = status;
        _isLoading = false;
      });

      if (status.hasAllPermissions) {
        widget.onPermissionResult?.call(true);
        if (widget.showAsDialog && mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to check permissions: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (_isRequestingPermission) return;

    setState(() => _isRequestingPermission = true);

    try {
      final status = await SyntraNotificationService.instance.requestPermissions();
      if (!mounted) return;
      setState(() {
        _permissionStatus = status;
        _isRequestingPermission = false;
      });

      widget.onPermissionResult?.call(status.hasAllPermissions);

      if (status.hasAllPermissions) {
        _showSuccessSnackBar(S.of(context).allPermissionsGranted);
        if (widget.showAsDialog) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.of(context).pop(true);
        }
      } else {
        _showWarningSnackBar(S.of(context).somePermissionsMissing);
      }
    } catch (e) {
      if (mounted) setState(() => _isRequestingPermission = false);
      _showErrorSnackBar('Failed to request permissions: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPermissionList(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customTitle ?? S.of(context).enableNotifications,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).forBestExperience,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.customDescription ??
          S.of(context).notificationPermissionDesc,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildPermissionList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_permissionStatus == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildPermissionItem(
          icon: Icons.notifications,
          title: S.of(context).basicNotifications,
          description: S.of(context).showReminderNotifications,
          isGranted: _permissionStatus!.hasBasicPermission,
          isRequired: true,
        ),
        const SizedBox(height: 12),
        _buildPermissionItem(
          icon: Icons.schedule,
          title: S.of(context).exactTiming,
          description: S.of(context).deliverAtPreciseTimes,
          isGranted: _permissionStatus!.hasExactAlarmPermission,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isGranted ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: isGranted
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isGranted ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          S.of(context).required,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isGranted ? Icons.check_circle : Icons.circle_outlined,
            color: isGranted ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasAllPermissions = _permissionStatus?.hasAllPermissions ?? false;

    return Column(
      children: [
        SyntraButton.icon(
          onPressed: hasAllPermissions ? null : (_isRequestingPermission ? null : _requestPermissions),
          color: hasAllPermissions ? Colors.green : Theme.of(context).primaryColor,
          icon: hasAllPermissions ? Icons.check_circle : Icons.notifications_active,
          label: _isRequestingPermission
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  hasAllPermissions ? S.of(context).allSet : S.of(context).enableNotifications,
                ),
        ),
        if (widget.showAsDialog) ...[
          const SizedBox(height: 12),
          SyntraButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Text(
              S.of(context).skipForNow,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildContent(),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildContent(),
    );
  }
}
