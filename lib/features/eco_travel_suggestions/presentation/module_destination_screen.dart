import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/travel_guide_catalog.dart';
import '../data/travel_trip_repository.dart';

class EcoTravelSuggestionsScreen extends StatefulWidget {
  const EcoTravelSuggestionsScreen({
    required this.repository,
    this.catalog,
    super.key,
  });

  final TravelTripRepository repository;
  final TravelGuideCatalog? catalog;

  @override
  State<EcoTravelSuggestionsScreen> createState() =>
      _EcoTravelSuggestionsScreenState();
}

class _EcoTravelSuggestionsScreenState
    extends State<EcoTravelSuggestionsScreen> {
  late final Future<TravelGuideCatalog> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog == null
        ? TravelGuideCatalog.loadBundled()
        : Future.value(widget.catalog!);
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
          l10n.ecoTravelSuggestions,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<TravelGuideCatalog>(
        future: _catalog,
        builder: (context, catalogSnapshot) {
          if (catalogSnapshot.hasError) {
            return _LoadFailure(
              message:
                  '${l10n.travelGuideLoadFailure}\n${catalogSnapshot.error}',
            );
          }
          final catalog = catalogSnapshot.data;
          if (catalog == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          return StreamBuilder<List<PlannedTrip>>(
            stream: widget.repository.watchTrips(),
            builder: (context, tripSnapshot) {
              if (tripSnapshot.hasError) {
                return _LoadFailure(message: l10n.travelLoadFailure);
              }
              if (tripSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: MotionAwareProgressIndicator(
                    semanticsLabel: l10n.loading,
                  ),
                );
              }
              return _TravelPlannerBody(
                trips: tripSnapshot.data ?? const [],
                catalog: catalog,
                onAdd: () => _addTrip(context, catalog),
                onEdit: (trip) => _editTrip(context, catalog, trip),
                onDelete: _deleteTrip,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addTrip(
    BuildContext context,
    TravelGuideCatalog catalog,
  ) async {
    final result = await _showTripForm(context, catalog);
    if (result == null || !context.mounted) return;
    try {
      await widget.repository.addTrip(
        title: result.title,
        destination: result.destination,
        transportMode: result.transportMode,
        date: result.date,
        notes: result.notes,
      );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.travelSaveFailure),
          ),
        );
      }
    }
  }

  Future<void> _editTrip(
    BuildContext context,
    TravelGuideCatalog catalog,
    PlannedTrip trip,
  ) async {
    final result = await _showTripForm(context, catalog, trip: trip);
    if (result == null || !context.mounted) return;
    try {
      await widget.repository.editTrip(
        tripId: trip.tripId,
        title: result.title,
        destination: result.destination,
        transportMode: result.transportMode,
        date: result.date,
        notes: result.notes,
      );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.travelSaveFailure),
          ),
        );
      }
    }
  }

  Future<void> _deleteTrip(String tripId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.repository.deleteTrip(tripId);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.travelDeleteFailure)));
      }
    }
  }

  Future<_TravelTripFormResult?> _showTripForm(
    BuildContext context,
    TravelGuideCatalog catalog, {
    PlannedTrip? trip,
  }) => showGeneralDialog<_TravelTripFormResult>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: ReducedMotion.duration(
      context,
      MotionSpec.optionalFade,
    ),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _TravelTripDialog(catalog: catalog, trip: trip),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: MotionSpec.optionalFadeCurve),
          ),
          child: child,
        ),
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(ClimateSpacing.space16),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

class _TravelPlannerBody extends StatelessWidget {
  const _TravelPlannerBody({
    required this.trips,
    required this.catalog,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PlannedTrip> trips;
  final TravelGuideCatalog catalog;
  final VoidCallback onAdd;
  final ValueChanged<PlannedTrip> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return ListView(
      key: const ValueKey('travelPlannerList'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Trips Section Header & Card
        Container(
          decoration: DesignTokens.sectionCard(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.travelTripSection,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: verdant.forestGreen,
                    ),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('travelAddTripButton'),
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: verdant.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.travelAddTrip),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (trips.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      l10n.travelNoTrips,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ClimateColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                for (var i = 0; i < trips.length; i++) ...[
                  _TravelTripRow(
                    trip: trips[i],
                    guidance: _guidanceFor(catalog, trips[i].transportMode).guidance,
                    onEdit: () => onEdit(trips[i]),
                    onDelete: () => onDelete(trips[i].tripId),
                  ),
                  if (i < trips.length - 1)
                    const Divider(height: 1),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Eco Travel Tips Section
        Container(
          decoration: DesignTokens.sectionCard(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.travelTipsSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: verdant.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < catalog.tips.length; i++) ...[
                _TravelTipRow(tip: catalog.tips[i]),
                if (i < catalog.tips.length - 1)
                  const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TravelTripRow extends StatelessWidget {
  const _TravelTripRow({
    required this.trip,
    required this.guidance,
    required this.onEdit,
    required this.onDelete,
  });

  final PlannedTrip trip;
  final String guidance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return Padding(
      key: ValueKey('travelTrip-${trip.tripId}'),
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(trip.title, style: theme.textTheme.titleSmall),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.travelEditTripTooltip,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: l10n.travelDeleteTrip,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: ClimateColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                trip.destination,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: ClimateSpacing.space12,
            runSpacing: ClimateSpacing.space4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: verdant.tagBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trip.transportMode,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
              ),
              if (trip.tripDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: ClimateColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.yMMMd(l10n.localeName).format(trip.tripDate!),
                      style: numberStyle,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: verdant.cream,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: Border.all(color: verdant.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.travelTransportGuidance,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  guidance,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trip.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ClimateColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TravelTipRow extends StatelessWidget {
  const _TravelTipRow({required this.tip});

  final TravelTip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            tip.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ClimateColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelTripDialog extends StatefulWidget {
  const _TravelTripDialog({required this.catalog, this.trip});

  final TravelGuideCatalog catalog;
  final PlannedTrip? trip;

  @override
  State<_TravelTripDialog> createState() => _TravelTripDialogState();
}

class _TravelTripDialogState extends State<_TravelTripDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _notesController;
  late String _transportMode;
  DateTime? _date;

  TravelModeGuidance get _selectedMode =>
      widget.catalog.modes.firstWhere((mode) => mode.mode == _transportMode);

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _titleController = TextEditingController(text: trip?.title ?? '');
    _destinationController = TextEditingController(
      text: trip?.destination ?? '',
    );
    _notesController = TextEditingController(text: trip?.notes ?? '');
    _date = trip?.tripDate;
    _transportMode =
        trip == null ||
            !widget.catalog.modes.any((mode) => mode.mode == trip.transportMode)
        ? widget.catalog.modes.first.mode
        : trip.transportMode;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    final isEditing = widget.trip != null;
    final dateText = _date == null
        ? l10n.travelNoDate
        : DateFormat.yMMMd(l10n.localeName).format(_date!);

    return AlertDialog(
      scrollable: true,
      title: Text(isEditing ? l10n.travelEditTrip : l10n.travelAddTrip),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const ValueKey('travelTitleField'),
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.travelTitleLabel),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.travelTitleRequired
                  : null,
            ),
            const SizedBox(height: ClimateSpacing.space16),
            TextFormField(
              key: const ValueKey('travelDestinationField'),
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: l10n.travelDestinationLabel,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.travelDestinationRequired
                  : null,
            ),
            const SizedBox(height: ClimateSpacing.space16),
            Text(
              l10n.travelModeLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ClimateColors.textSecondary,
              ),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            DropdownButtonFormField<String>(
              key: const ValueKey('travelModePicker'),
              initialValue: _transportMode,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: [
                for (final mode in widget.catalog.modes)
                  DropdownMenuItem(
                    value: mode.mode,
                    child: Text(mode.mode, maxLines: 2),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _transportMode = value);
              },
            ),
            const SizedBox(height: ClimateSpacing.space8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: verdant.forestLight,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.travelTransportGuidance,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: verdant.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_selectedMode.guidance, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: ClimateSpacing.space16),
            Text(
              l10n.travelDateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ClimateColors.textSecondary,
              ),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            Wrap(
              spacing: ClimateSpacing.space8,
              runSpacing: ClimateSpacing.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  key: const ValueKey('travelChooseDateButton'),
                  onPressed: _pickDate,
                  child: Text(dateText, style: numberStyle),
                ),
                if (_date != null)
                  TextButton(
                    key: const ValueKey('travelClearDateButton'),
                    onPressed: () => setState(() => _date = null),
                    child: Text(l10n.travelClearDate),
                  ),
              ],
            ),
            const SizedBox(height: ClimateSpacing.space16),
            TextFormField(
              key: const ValueKey('travelNotesField'),
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.travelNotesLabel),
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const ValueKey('travelSaveTripButton'),
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: verdant.forestGreen,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? l10n.travelUpdateTrip : l10n.travelSaveTrip),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _TravelTripFormResult(
        title: _titleController.text,
        destination: _destinationController.text,
        transportMode: _transportMode,
        date: _date,
        notes: _notesController.text,
      ),
    );
  }
}

class _TravelTripFormResult {
  const _TravelTripFormResult({
    required this.title,
    required this.destination,
    required this.transportMode,
    required this.date,
    required this.notes,
  });

  final String title;
  final String destination;
  final String transportMode;
  final DateTime? date;
  final String? notes;
}

TravelModeGuidance _guidanceFor(TravelGuideCatalog catalog, String mode) =>
    catalog.modes.firstWhere((item) => item.mode == mode);
