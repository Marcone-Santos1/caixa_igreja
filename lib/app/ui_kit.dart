import 'package:flutter/material.dart';

/// Estado vazio com ícone em destaque suave.
class CaixaEmptyHint extends StatelessWidget {
  const CaixaEmptyHint({
    super.key,
    required this.icon,
    required this.message,
    this.detail,
  });

  final IconData icon;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 40,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 10),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Linha de lista com leve borda e realce ao toque.
class CaixaListRow extends StatelessWidget {
  const CaixaListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shadowColor: scheme.shadow.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.55),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.15,
                            ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: isThreeLine ? 1.35 : 1.25,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                // ignore: use_null_aware_elements — Row precisa de Widget concreto; padrão do lint não aplica bem a trailing opcional.
                if (trailing case final w?) w,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
