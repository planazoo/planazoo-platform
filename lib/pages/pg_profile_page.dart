import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:unp_calendario/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/language/presentation/providers/language_providers.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/features/security/widgets/password_rules_checklist.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final appLocalizations = AppLocalizations.of(context)!;

    // Método para formatear fechas
    String _formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    final systemTimezone = TimezoneService.getSystemTimezone();
    final currentUserTimezone = currentUser?.defaultTimezone ?? systemTimezone;
    final currentTimezoneDisplay = TimezoneService.getTimezoneDisplayName(currentUserTimezone);

    return Scaffold(
      backgroundColor: AppColorScheme.color0,
      body: currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Top bar con logo y botón de cerrar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: AppColorScheme.color2,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (onClose != null) {
                            onClose!();
                            return;
                          }
                          final navigator = Navigator.of(context);
                          if (navigator.canPop()) {
                            navigator.pop();
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currentUser.username != null && currentUser.username!.isNotEmpty
                            ? '@${currentUser.username!}'
                            : currentUser.displayIdentifier,
                        style: AppTypography.largeTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenido principal
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header compacto con foto y datos
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColorScheme.color2.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppColorScheme.color2,
                                  width: 2,
                                ),
                              ),
                              child: currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        currentUser.photoURL!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColorScheme.color2,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColorScheme.color2,
                                    ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (currentUser.displayName ?? currentUser.displayIdentifier),
                                    style: AppTypography.mediumTitle.copyWith(
                                      color: AppColorScheme.color4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentUser.email,
                                    style: AppTypography.bodyStyle.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appLocalizations.profileMemberSince(_formatDate(currentUser.createdAt)),
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appLocalizations.profileCurrentTimezone(currentTimezoneDisplay),
                                    style: AppTypography.bodyStyle.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        _buildSectionCard(
                          title: appLocalizations.profilePersonalDataTitle,
                          subtitle: appLocalizations.profilePersonalDataSubtitle,
                          options: [
                            _buildTextOption(
                              appLocalizations.profileEditPersonalInformation,
                              () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) => const EditProfilePage(),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSectionCard(
                          title: appLocalizations.profileSecurityAndAccessTitle,
                          subtitle: appLocalizations.profileSecurityAndAccessSubtitle,
                          options: [
                              _buildTextOption(
                                appLocalizations.profileTimezoneOption,
                                () => _showTimezonePreferenceDialog(context, ref),
                              ),
                              _buildTextOption(
                              appLocalizations.changePasswordTitle,
                              () => _showChangePasswordDialog(context, ref),
                            ),
                            _buildTextOption(
                              appLocalizations.profilePrivacyAndSecurityOption,
                              () => _showPrivacyDialog(context),
                            ),
                            _buildTextOption(
                              appLocalizations.profileLanguageOption,
                              () => _showLanguageDialog(context, ref),
                            ),
                            _buildTextOption(
                              appLocalizations.profileSignOutOption,
                              () async {
                                await authNotifier.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed('/');
                                }
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSectionCard(
                          title: appLocalizations.profileAdvancedActionsTitle,
                          subtitle: appLocalizations.profileAdvancedActionsSubtitle,
                          options: [
                            _buildTextOption(
                              appLocalizations.profileDeleteAccountOption,
                              () => _showDeleteAccountDialog(context, ref, authNotifier),
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextOption(
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : AppColorScheme.color2.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppColorScheme.color4,
                fontSize: 14,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> options,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColorScheme.color2.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.mediumTitle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < options.length; i++) ...[
              options[i],
              if (i != options.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showTimezonePreferenceDialog(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final systemTimezone = TimezoneService.getSystemTimezone();
    final userTimezone = authState.user?.defaultTimezone ?? systemTimezone;

    final allTimezones = <String>{systemTimezone, userTimezone, ...TimezoneService.getCommonTimezones()}.toList()
      ..sort((a, b) => a.compareTo(b));

    String selectedTimezone = userTimezone;
    String searchQuery = '';
    bool isLoading = false;
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          List<String> filteredTimezones = allTimezones
              .where((tz) => tz.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          if (!filteredTimezones.contains(selectedTimezone)) {
            filteredTimezones.insert(0, selectedTimezone);
          }

          final systemDisplay = TimezoneService.getTimezoneDisplayName(systemTimezone);
          final selectedDisplay = TimezoneService.getTimezoneDisplayName(selectedTimezone);

          return AlertDialog(
            title: Text(loc.profileTimezoneDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.profileTimezoneDialogDescription(selectedDisplay),
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                if (systemTimezone != selectedTimezone) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedTimezone = systemTimezone;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.profileTimezoneDialogDeviceSuggestion(systemDisplay),
                                  style: AppTypography.bodyStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  loc.profileTimezoneDialogDeviceHint,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: loc.profileTimezoneDialogSearchHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  width: double.maxFinite,
                  child: filteredTimezones.isEmpty
                      ? Center(
                          child: Text(
                            loc.profileTimezoneDialogNoResults,
                            style: AppTypography.bodyStyle.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredTimezones.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final timezone = filteredTimezones[index];
                            final displayName = TimezoneService.getTimezoneDisplayName(timezone);
                            return RadioListTile<String>(
                              value: timezone,
                              groupValue: selectedTimezone,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedTimezone = value;
                                  });
                                }
                              },
                              title: Text(displayName),
                              subtitle: timezone == systemTimezone
                                  ? Text(
                                      loc.profileTimezoneDialogSystemTag,
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.blueGrey.shade700,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          await authNotifier.updateDefaultTimezone(selectedTimezone);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.profileTimezoneUpdateSuccess),
                                backgroundColor: Colors.green.shade600,
                              ),
                            );
                          }
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          final message = e.toString().contains('invalid-timezone')
                              ? loc.profileTimezoneInvalidError
                              : loc.profileTimezoneUpdateError;
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(loc.saveChanges),
              ),
            ],
          );
        },
      ),
    );

    searchController.dispose();
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    bool canSubmit() {
      final current = currentPasswordController.text.trim();
      final newPwd = newPasswordController.text.trim();
      final confirm = confirmPasswordController.text.trim();
      final passwordValidation = Validator.validatePassword(newPwd);

      final isCurrentFilled = current.isNotEmpty;
      final isNewValid = passwordValidation.isValid && newPwd != current;
      final isConfirmValid = confirm.isNotEmpty && confirm == newPwd;

      return isCurrentFilled && isNewValid && isConfirmValid && !isLoading;
    }

    String? mapPasswordError(String? errorCode) {
      switch (errorCode) {
        case 'passwordRequired':
          return loc.passwordRequired;
        case 'passwordMinLength':
          return loc.passwordMinLength;
        case 'passwordNeedsLowercase':
          return loc.passwordNeedsLowercase;
        case 'passwordNeedsUppercase':
          return loc.passwordNeedsUppercase;
        case 'passwordNeedsNumber':
          return loc.passwordNeedsNumber;
        case 'passwordNeedsSpecialChar':
          return loc.passwordNeedsSpecialChar;
        default:
          return loc.passwordMinLength;
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(loc.changePasswordTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.changePasswordSubtitle,
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: loc.currentPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: loc.newPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    validator: (value) {
                      final result = Validator.validatePassword(value);
                      if (!result.isValid) {
                        return mapPasswordError(result.errorCode);
                      }
                      if (value == currentPasswordController.text) {
                        return loc.passwordMustBeDifferent;
                      }
                      return null;
                    },
                  ),
                  PasswordRulesChecklist(
                    password: newPasswordController.text,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: loc.confirmNewPasswordLabel,
                      prefixIcon: const Icon(Icons.check_circle_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.passwordRequired;
                      }
                      if (value != newPasswordController.text) {
                        return loc.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: !canSubmit()
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        setState(() => isLoading = true);

                        await authNotifier.changePassword(
                          currentPasswordController.text.trim(),
                          newPasswordController.text.trim(),
                        );

                        final authState = ref.read(authNotifierProvider);
                        if (authState.errorMessage != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${loc.passwordChangeError}: ${authState.errorMessage}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() => isLoading = false);
                          return;
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.passwordChangedSuccess),
                              backgroundColor: Colors.green.shade600,
                            ),
                          );
                        }

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.color2,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(loc.saveChanges),
              ),
            ],
          ),
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _showPrivacyDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.profilePrivacyDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.profilePrivacyDialogIntro),
            const SizedBox(height: 12),
            Text('• ${loc.profilePrivacyDialogEncryption}'),
            Text('• ${loc.profilePrivacyDialogEmailVerification}'),
            Text('• ${loc.profilePrivacyDialogRateLimiting}'),
            Text('• ${loc.profilePrivacyDialogAccessControl}'),
            const SizedBox(height: 16),
            Text(loc.profilePrivacyDialogMoreInfo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final languageNotifier = ref.read(languageNotifierProvider);
    String selectedLanguageCode = ref.read(currentLanguageSyncProvider).languageCode;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.profileLanguageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'es',
                groupValue: selectedLanguageCode,
                title: Text(loc.profileLanguageOptionSpanish),
                onChanged: (value) => setState(() => selectedLanguageCode = value ?? selectedLanguageCode),
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: selectedLanguageCode,
                title: Text(loc.profileLanguageOptionEnglish),
                onChanged: (value) => setState(() => selectedLanguageCode = value ?? selectedLanguageCode),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await languageNotifier.changeLanguage(Locale(selectedLanguageCode));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(loc.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AuthNotifier authNotifier,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    String _mapDeleteAccountError(String rawMessage) {
      final code = rawMessage.replaceFirst('Exception: ', '');
      switch (code) {
        case 'wrong-password':
        case 'invalid-credential':
          return loc.profileDeleteAccountWrongPasswordError;
        case 'too-many-requests':
          return loc.profileDeleteAccountTooManyAttemptsError;
        case 'requires-recent-login':
          return loc.profileDeleteAccountRecentLoginError;
        default:
          return loc.profileDeleteAccountGenericError;
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(loc.profileDeleteAccountOption),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.profileDeleteAccountDescription),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.red.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          setState(() {
                            errorMessage = loc.profileDeleteAccountEmptyPasswordError;
                          });
                          return;
                        }

                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          await authNotifier.deleteAccount(password);
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                            errorMessage = _mapDeleteAccountError(e.toString());
                          });
                          return;
                        }

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(loc.profileDeleteAccountOption),
              ),
            ],
          ),
        );
      },
    );

    passwordController.dispose();
  }
}
