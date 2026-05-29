import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../services/profile_service.dart';
import '../utils/design_system.dart';

class ProfilesScreen extends StatefulWidget {
  final VoidCallback onProfileChanged;

  const ProfilesScreen({
    super.key,
    required this.onProfileChanged,
  });

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(S.of(context).profiles, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: colors.appBarBackground,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_profileService.storeData)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context).storeDataDesc,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _profileService.profiles.length,
                itemBuilder: (context, index) {
                  final profileId = _profileService.profiles[index];
                  final isCurrent = profileId == _profileService.currentProfileId;
                  final String name = _profileService.getProfileName(profileId);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : colors.divider,
                        width: isCurrent ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : colors.surfaceBackground,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? AppColors.primary : null,
                          fontSize: 16,
                        ),
                      ),
                      trailing: profileId != 'default'
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDeleteProfile(context, profileId, name),
                            )
                          : null,
                      onTap: isCurrent
                          ? null
                          : () async {
                              await _profileService.loadProfile(profileId);
                              widget.onProfileChanged();
                              setState(() {});
                            },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () => _showAddProfileDialog(context),
                icon: const Icon(Icons.add),
                label: Text(S.of(context).addProfile, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).createProfile),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: S.of(context).profileNameHint,
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                await _profileService.createProfile(name);
                widget.onProfileChanged();
                setState(() {});
              }
            },
            child: Text(S.of(context).create, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(BuildContext context, String profileId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).deleteProfileConfirm),
        content: Text(S.of(context).deleteProfileDesc(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _profileService.deleteProfile(profileId);
              widget.onProfileChanged();
              setState(() {});
            },
            child: Text(S.of(context).delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
