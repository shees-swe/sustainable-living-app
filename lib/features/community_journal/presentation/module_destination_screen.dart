import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/community_post_repository.dart';

class CommunityJournalScreen extends StatefulWidget {
  const CommunityJournalScreen({required this.repository, super.key});

  final CommunityPostRepository repository;

  @override
  State<CommunityJournalScreen> createState() => _CommunityJournalScreenState();
}

class _CommunityJournalScreenState extends State<CommunityJournalScreen> {
  late Stream<List<CommunityJournalPost>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = widget.repository.watchPosts();
  }

  @override
  void didUpdateWidget(covariant CommunityJournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _posts = widget.repository.watchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.communityJournal, maxLines: 2),
      ),
      body: StreamBuilder<List<CommunityJournalPost>>(
        stream: _posts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadFailure(
              message: '${l10n.communityLoadFailure}\n${snapshot.error}',
            );
          }
          final posts = snapshot.data;
          if (posts == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          return _CommunityJournalBody(
            posts: posts,
            onAdd: () => _addPost(context),
            onEdit: (post) => _editPost(context, post),
            onDelete: _deletePost,
          );
        },
      ),
    );
  }

  Future<void> _addPost(BuildContext context) async {
    final result = await _showPostForm(context);
    if (result == null || !context.mounted) return;
    try {
      await widget.repository.addPost(title: result.title, body: result.body);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.communitySaveFailure),
          ),
        );
      }
    }
  }

  Future<void> _editPost(
    BuildContext context,
    CommunityJournalPost post,
  ) async {
    final result = await _showPostForm(context, post: post);
    if (result == null || !context.mounted) return;
    try {
      await widget.repository.editPost(
        postId: post.postId,
        title: result.title,
        body: result.body,
      );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.communityUpdateFailure),
          ),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await widget.repository.deletePost(postId);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.communityDeleteFailure),
          ),
        );
      }
    }
  }

  Future<_PostFormResult?> _showPostForm(
    BuildContext context, {
    CommunityJournalPost? post,
  }) => showGeneralDialog<_PostFormResult>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: ReducedMotion.duration(
      context,
      MotionSpec.optionalFade,
    ),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _CommunityPostDialog(post: post),
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

class _CommunityJournalBody extends StatelessWidget {
  const _CommunityJournalBody({
    required this.posts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CommunityJournalPost> posts;
  final VoidCallback onAdd;
  final ValueChanged<CommunityJournalPost> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('communityJournalList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        Text(
          l10n.communityLocalOnly,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ClimateColors.textSecondary,
          ),
        ),
        const SizedBox(height: ClimateSpacing.space16),
        Text(l10n.communityFeedHeading, style: theme.textTheme.titleMedium),
        const SizedBox(height: ClimateSpacing.space8),
        FilledButton.icon(
          key: const ValueKey('communityAddPostButton'),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(l10n.communityAddPost),
        ),
        if (posts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space16,
            ),
            child: Text(l10n.communityNoPosts),
          )
        else
          for (final post in posts) ...[
            _CommunityPostRow(
              post: post,
              onEdit: () => onEdit(post),
              onDelete: () => onDelete(post.postId),
            ),
            const Divider(height: 1),
          ],
        const Divider(height: 1),
        const SizedBox(height: ClimateSpacing.space24),
        Text(
          l10n.communityGuidelinesHeading,
          style: theme.textTheme.titleMedium,
        ),
        for (final guideline in _guidelines(l10n)) ...[
          const Divider(height: 1),
          _GuidelineRow(guideline: guideline),
        ],
        const Divider(height: 1),
      ],
    );
  }
}

class _CommunityPostRow extends StatelessWidget {
  const _CommunityPostRow({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  final CommunityJournalPost post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return Container(
      key: ValueKey('communityPost-${post.postId}'),
      padding: const EdgeInsets.all(ClimateSpacing.space16),
      decoration: BoxDecoration(
        color: ClimateColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(ClimateSpacing.radiusLarge),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: ClimateSpacing.space8),
          Text(post.body),
          const SizedBox(height: ClimateSpacing.space8),
          Wrap(
            spacing: ClimateSpacing.space8,
            runSpacing: ClimateSpacing.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateFormat.yMMMd(l10n.localeName).format(post.createdAt),
                style: numberStyle,
              ),
              IconButton(
                tooltip: l10n.communityEditPostTooltip,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.communityDeletePostTooltip,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidelineRow extends StatelessWidget {
  const _GuidelineRow({required this.guideline});

  final _Guideline guideline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(guideline.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: ClimateSpacing.space8),
          Text(guideline.text),
        ],
      ),
    );
  }
}

class _CommunityPostDialog extends StatefulWidget {
  const _CommunityPostDialog({this.post});

  final CommunityJournalPost? post;

  @override
  State<_CommunityPostDialog> createState() => _CommunityPostDialogState();
}

class _CommunityPostDialogState extends State<_CommunityPostDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.post != null;
    return AlertDialog(
      scrollable: true,
      title: Text(
        isEditing ? l10n.communityEditPostTitle : l10n.communityNewPostTitle,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const ValueKey('communityPostTitleField'),
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.communityPostTitleLabel,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.communityTitleRequired
                  : null,
            ),
            const SizedBox(height: ClimateSpacing.space16),
            TextFormField(
              key: const ValueKey('communityPostBodyField'),
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: l10n.communityPostBodyLabel,
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              minLines: 4,
              maxLines: 8,
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.communityBodyRequired
                  : null,
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
          key: const ValueKey('communitySavePostButton'),
          onPressed: _save,
          child: Text(
            isEditing ? l10n.communityUpdatePost : l10n.communitySavePost,
          ),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _PostFormResult(title: _titleController.text, body: _bodyController.text),
    );
  }
}

class _PostFormResult {
  const _PostFormResult({required this.title, required this.body});

  final String title;
  final String body;
}

class _Guideline {
  const _Guideline({required this.title, required this.text});

  final String title;
  final String text;
}

List<_Guideline> _guidelines(AppLocalizations l10n) => [
  _Guideline(
    title: l10n.communityGuidelineShareTitle,
    text: l10n.communityGuidelineShareText,
  ),
  _Guideline(
    title: l10n.communityGuidelineSpecificTitle,
    text: l10n.communityGuidelineSpecificText,
  ),
  _Guideline(
    title: l10n.communityGuidelineHonestTitle,
    text: l10n.communityGuidelineHonestText,
  ),
  _Guideline(
    title: l10n.communityGuidelineDeviceTitle,
    text: l10n.communityGuidelineDeviceText,
  ),
];
