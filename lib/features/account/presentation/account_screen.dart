import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.account, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space8,
        ),
        children: [
          Text(
            l10n.accountOptionalGuest,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
            child: Divider(height: 1),
          ),
          Text(
            _isRegistering ? l10n.register : l10n.logIn,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ClimateSpacing.space8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('accountIdentifier'),
                controller: _identifierController,
                autofillHints: const [AutofillHints.username],
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.accountLoginIdentifier,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: ClimateSpacing.space16),
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
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: ClimateSpacing.space16),
              FilledButton(
                key: const ValueKey('accountSubmit'),
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.accountPleaseWait
                      : _isRegistering
                      ? l10n.createLocalAccount
                      : l10n.logIn,
                ),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : _toggleMode,
                child: Text(_isRegistering ? l10n.logIn : l10n.register),
              ),
            ],
          ),
          if (_message case final message?) ...[
            const SizedBox(height: ClimateSpacing.space16),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: TextStyle(
                  color: _isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
