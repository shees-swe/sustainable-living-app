import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router.dart';
import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/data/regions/region_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/user_data_deleter.dart';
import '../data/user_data_exporter.dart';
import '../data/user_data_file_picker.dart';
import '../data/user_data_file_sharer.dart';
import '../data/user_data_importer.dart';
import '../data/user_preferences_repository.dart';
import 'region_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.exporter,
    required this.deleter,
    required this.importer,
    required this.onGuestReturn,
    required this.onImportComplete,
    this.pickImportFile,
    this.shareExport,
    this.preferences,
    this.regionCatalog,
    super.key,
  });

  final UserDataExporter exporter;
  final UserDataDeleter deleter;
  final UserDataImporter importer;
  final Future<void> Function() onGuestReturn;
  final Future<void> Function() onImportComplete;
  final Future<Uint8List?> Function()? pickImportFile;
  final Future<ShareResult> Function(Map<String, Object?> export)? shareExport;
  final UserPreferencesRepository? preferences;
  final RegionCatalog? regionCatalog;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isDeleting = false;
  bool _isImporting = false;
  String? _status;
  bool _statusIsError = false;

  Future<void> _exportData() async {
    if (_isExporting || _isDeleting) return;
    setState(() {
      _isExporting = true;
      _status = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      final export = await widget.exporter.exportData();
      final share =
          widget.shareExport ?? const UserDataFileSharer().shareExport;
      final result = await share(export);
      if (!mounted) return;
      switch (result.status) {
        case ShareResultStatus.success:
          _setStatus(l10n.userDataExportShared);
        case ShareResultStatus.dismissed:
          _setStatus(l10n.userDataExportDismissed);
        case ShareResultStatus.unavailable:
          _setStatus(l10n.userDataExportUnavailable, isError: true);
      }
    } on FileSystemException {
      _setStatus(l10n.userDataExportFailure, isError: true);
    } on PlatformException {
      _setStatus(l10n.userDataExportFailure, isError: true);
    } on FormatException {
      _setStatus(l10n.userDataExportFailure, isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _requestDeletion() async {
    if (_isExporting || _isDeleting) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteLocalData),
        content: Text(l10n.deleteLocalDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmDeletion),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      if (mounted) _setStatus(l10n.deletionCancelled);
      return;
    }

    setState(() {
      _isDeleting = true;
      _status = null;
    });
    try {
      final result = await widget.deleter.deleteAllUserData(confirmed: true);
      if (!mounted) return;
      if (result != UserDataDeletionResult.deleted) {
        _setStatus(l10n.deletionCancelled);
        return;
      }
      _setStatus(l10n.userDataDeleted);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.userDataDeleted)));
      await widget.onGuestReturn();
    } on FileSystemException {
      _setStatus(l10n.userDataDeletionFailure, isError: true);
    } on PlatformException {
      _setStatus(l10n.userDataDeletionFailure, isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _importData() async {
    if (_isExporting || _isDeleting || _isImporting) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isImporting = true;
      _status = null;
    });
    try {
      final pickFile =
          widget.pickImportFile ?? const UserDataFilePicker().pickJsonFile;
      final bytes = await pickFile();
      if (!mounted) return;
      if (bytes == null) {
        _setStatus(l10n.userDataImportCancelled);
        return;
      }

      final prepared = widget.importer.prepareImport(utf8.decode(bytes));
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.replaceAllDataTitle),
          content: Text(l10n.replaceAllDataConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirmImport),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) {
        _setStatus(l10n.userDataImportCancelled);
        return;
      }

      await widget.importer.applyImport(prepared);
      if (!mounted) return;
      _setStatus(l10n.userDataImportSuccess);
      await widget.onImportComplete();
    } on FormatException {
      _setStatus(l10n.userDataImportFailure, isError: true);
    } on FileSystemException {
      _setStatus(l10n.userDataImportUnavailableFailure, isError: true);
    } on PlatformException {
      _setStatus(l10n.userDataImportUnavailableFailure, isError: true);
    } on MissingPluginException {
      _setStatus(l10n.userDataImportUnavailableFailure, isError: true);
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _setStatus(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busy = _isExporting || _isDeleting || _isImporting;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.settings, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space8,
        ),
        children: [
          if (widget.preferences != null && widget.regionCatalog != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: RegionPicker(
                  preferences: widget.preferences!,
                  catalog: widget.regionCatalog!,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
              child: Divider(height: 1),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space16,
            ),
            child: Text(
              l10n.privacyControls,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ClimateSpacing.space16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.file_download_outlined),
                    title: Text(l10n.importMyData),
                    subtitle: Text(l10n.importDataDescription),
                    trailing: _isImporting
                        ? MotionAwareProgressIndicator(
                            semanticsLabel: l10n.loading,
                            size: 24,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: busy ? null : _importData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.policy_outlined),
                    title: Text(l10n.privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: busy
                        ? null
                        : () => context.push(AppRoutes.privacyPolicy),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.file_upload_outlined),
                    title: Text(l10n.exportMyData),
                    subtitle: Text(l10n.exportDataDescription),
                    trailing: _isExporting
                        ? MotionAwareProgressIndicator(
                            semanticsLabel: l10n.loading,
                            size: 24,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: busy ? null : _exportData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline),
                    title: Text(l10n.deleteLocalData),
                    subtitle: Text(l10n.deleteDataDescription),
                    trailing: _isDeleting
                        ? MotionAwareProgressIndicator(
                            semanticsLabel: l10n.loading,
                            size: 24,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: busy ? null : _requestDeletion,
                  ),
                  if (_status case final status?) ...[
                    const SizedBox(height: ClimateSpacing.space16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusIsError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
