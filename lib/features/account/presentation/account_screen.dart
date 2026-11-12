import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/account_repository.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({required this.repository, super.key});

  final AccountRepository repository;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = true;
  bool _isSubmitting = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      if (_isRegistering) {
        await widget.repository.register(
          loginIdentifier: _identifierController.text,
          password: _passwordController.text,
        );
        _setMessage(l10n.accountCreatedOnDevice);
      } else {
        final identity = await widget.repository.login(
          loginIdentifier: _identifierController.text,
          password: _passwordController.text,
        );
        _setMessage(l10n.accountSignedIn(identity.loginIdentifier));
      }
    } on AccountAlreadyExists {
      _setMessage(l10n.accountAlreadyExists, isError: true);
    } on InvalidAccountCredentials {
      _setMessage(l10n.accountInvalidCredentials, isError: true);
    } on AccountLoginThrottled {
      _setMessage(l10n.accountLoginThrottled, isError: true);
    } on InvalidAccountIdentifier {
      _setMessage(l10n.accountInvalidIdentifier, isError: true);
    } on InvalidAccountPassword {
      _setMessage(l10n.accountInvalidPassword, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _setMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = isError;
    });
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;

    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.account,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Info banner
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.person_pin_circle_outlined,
                    size: 24,
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.accountOptionalGuest,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Form card
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isRegistering ? l10n.register : l10n.logIn,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: verdant.forestGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('accountIdentifier'),
                  controller: _identifierController,
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.accountLoginIdentifier,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('accountPassword'),
                  controller: _passwordController,
                  autofillHints: _isRegistering
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.accountPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const ValueKey('accountSubmit'),
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: verdant.forestGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isSubmitting
                        ? l10n.accountPleaseWait
                        : _isRegistering
                        ? l10n.createLocalAccount
                        : l10n.logIn,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isSubmitting ? null : _toggleMode,
                  style: TextButton.styleFrom(
                    foregroundColor: verdant.forestGreen,
                  ),
                  child: Text(_isRegistering ? l10n.logIn : l10n.register),
                ),
              ],
            ),
          ),
          if (_message case final message?) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _isError ? const Color(0xFFFFEBEE) : verdant.forestLight,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                border: Border.all(
                  color: _isError
                      ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                      : verdant.forestGreen.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  style: TextStyle(
                    color: _isError
                        ? Theme.of(context).colorScheme.error
                        : verdant.forestDeep,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
