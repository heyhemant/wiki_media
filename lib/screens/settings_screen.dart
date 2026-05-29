import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../services/profile_service.dart';
import '../utils/design_system.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onDataReset;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onDataReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(S.of(context).settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: colors.appBarBackground,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Data Setting
            SwitchListTile(
              title: Text(S.of(context).storeData, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(S.of(context).storeDataDesc),
              value: _profileService.storeData,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) async {
                setState(() {
                  _profileService.storeData = val;
                });
                await _profileService.saveSettings();
              },
            ),
            const Divider(),

            // Open in English Wiki
            SwitchListTile(
              title: Text(S.of(context).openInEnglishWiki, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(S.of(context).openInEnglishWikiDesc),
              value: _profileService.openMainWiki,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) async {
                setState(() {
                  _profileService.openMainWiki = val;
                });
                await _profileService.saveSettings();
              },
            ),
            const Divider(),

            // Theme Setting
            Text(
              S.of(context).theme,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildThemeButton(S.of(context).auto, 'auto'),
                const SizedBox(width: 8),
                _buildThemeButton(S.of(context).light, 'light'),
                const SizedBox(width: 8),
                _buildThemeButton(S.of(context).dark, 'dark'),
              ],
            ),
            const SizedBox(height: 40),

            // Reset Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmResetAlgorithm(context),
                child: Text(S.of(context).resetAlgorithm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () => _confirmResetEverything(context),
                child: Text(S.of(context).deleteAllData, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(String label, String value) {
    final colors = AppColors.of(context);
    final isSelected = _profileService.theme == value;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _profileService.theme = value;
          });
          await _profileService.saveSettings();
          widget.onThemeChanged();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : colors.chipBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmResetAlgorithm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).resetAlgorithmConfirm),
        content: Text(S.of(context).resetAlgorithmDesc(_profileService.profileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _profileService.resetAlgorithm();
              widget.onDataReset();
            },
            child: Text(S.of(context).reset, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmResetEverything(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).deleteAllDataConfirm),
        content: Text(S.of(context).deleteAllDataDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              await _profileService.resetEverything();
              if (ctx.mounted) Navigator.pop(ctx);
              widget.onDataReset();
            },
            child: Text(S.of(context).deleteEverything, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
