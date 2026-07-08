import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../models/plan_type.dart';
import '../providers/plan_provider.dart';

class PlanSelectorScreen extends ConsumerStatefulWidget {
  const PlanSelectorScreen({super.key});

  @override
  ConsumerState<PlanSelectorScreen> createState() =>
      _PlanSelectorScreenState();
}

class _PlanSelectorScreenState extends ConsumerState<PlanSelectorScreen> {
  bool _switching = false;

  Future<void> _handleSelect(PlanTypeInfo plan) async {
    final activePlan = ref.read(activePlanTypeProvider);
    if (plan.id == activePlan.id) {
      context.pop();
      return;
    }
    setState(() => _switching = true);
    try {
      await switchActivePlan(plan.goalKey, ref);
    } finally {
      if (mounted) setState(() => _switching = false);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = ref.watch(activePlanTypeProvider);
    final previews = ref.watch(allPlanPreviewsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'My plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 20),
                child: Text(
                  'Pick a plan built around your goal. We\'ll set your calorie & macro targets automatically.',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
              ),

              // ── Plan list ────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: kPlanTypes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final plan = kPlanTypes[i];
                    final isActive = plan.id == activePlan.id;
                    final kcal =
                        previews[plan.id]?['kcal'];

                    return _PlanRow(
                      plan: plan,
                      kcal: kcal,
                      isActive: isActive,
                      isLoading: _switching,
                      onTap: _switching
                          ? null
                          : () => _handleSelect(plan),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Plan row ──────────────────────────────────────────────────────────────────

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.kcal,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  final PlanTypeInfo plan;
  final double? kcal;
  final bool isActive;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final kcalText = kcal != null ? '${_fmtKcal(kcal!)} kcal · ' : '';
    final previewLine = '$kcalText${plan.description}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1E2800)
                : AaharTheme.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? Border.all(
                    color:
                        AaharTheme.brandLime.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: plan.iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(plan.icon,
                    color: plan.iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      previewLine,
                      style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isActive)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AaharTheme.brandLime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: AaharTheme.darkBg, size: 14),
                )
              else
                const Icon(Icons.chevron_right,
                    color: Color(0xFF444444), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmtKcal(double kcal) {
  final n = kcal.round();
  if (n >= 1000) {
    return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
  }
  return n.toString();
}
