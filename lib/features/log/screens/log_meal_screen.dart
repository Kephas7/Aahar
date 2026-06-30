import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../data/nepali_foods.dart';
import '../models/food_item.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _searchController = TextEditingController();
  bool _cameraMode = true;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get _recent =>
      kRecentFoodIds.map(findFoodById).whereType<FoodItem>().toList();

  List<FoodItem> get _popular =>
      kPopularFoodIds.map(findFoodById).whereType<FoodItem>().toList();

  List<FoodItem> get _searchResults => searchFoods(_query);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Log a meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Mode selector ─────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _ModeCard(
                              icon: Icons.camera_alt_outlined,
                              title: 'Take a photo',
                              subtitle: 'AI detects food',
                              selected: _cameraMode,
                              onTap: () {
                                setState(() => _cameraMode = true);
                                context.push('/log/camera');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModeCard(
                              icon: Icons.search,
                              title: 'Search food',
                              subtitle: '20+ Nepali foods',
                              selected: !_cameraMode,
                              onTap: () => setState(() => _cameraMode = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Search bar ────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: AaharTheme.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Search Nepali foods...',
                            hintStyle: TextStyle(color: Color(0xFF555555)),
                            prefixIcon: Icon(Icons.search,
                                color: Color(0xFF555555), size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (v) =>
                              setState(() => _query = v.trim()),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_query.isNotEmpty) ...[
                        // ── Search results ────────────────────────────────
                        if (_searchResults.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No foods found',
                                style: TextStyle(
                                    color: Color(0xFF555555), fontSize: 14),
                              ),
                            ),
                          )
                        else
                          ..._searchResults.map(
                            (f) => _FoodTile(
                              food: f,
                              onAdd: () => _goToPortionScreen(f),
                            ),
                          ),
                      ] else ...[
                        // ── Recent ────────────────────────────────────────
                        const _SectionLabel('RECENT'),
                        const SizedBox(height: 8),
                        ..._recent.map(
                          (f) => _FoodTile(
                            food: f,
                            onAdd: () => _goToPortionScreen(f),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Popular in Nepal ──────────────────────────────
                        const _SectionLabel('POPULAR IN NEPAL'),
                        const SizedBox(height: 8),
                        ..._popular.map(
                          (f) => _FoodTile(
                            food: f,
                            onAdd: () => _goToPortionScreen(f),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPortionScreen(FoodItem food) {
    context.push('/log/portion', extra: [food]);
  }
}

// ── Mode card ─────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A2E1A) : AaharTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AaharTheme.brandLime : const Color(0xFF2A2A2A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AaharTheme.brandLime : const Color(0xFF888888),
                size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF888888),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Food tile ─────────────────────────────────────────────────────────────────

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.onAdd});
  final FoodItem food;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final kcal = food
        .kcalFor(food.defaultQuantity, food.defaultUnit)
        .round();
    final portion =
        '${food.defaultQuantity == food.defaultQuantity.roundToDouble() ? food.defaultQuantity.toInt() : food.defaultQuantity} ${food.defaultUnit}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$kcal kcal · $portion',
                  style: const TextStyle(
                      color: Color(0xFF666666), fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A4A2A)),
              ),
              child: const Text(
                '+ Add',
                style: TextStyle(
                  color: AaharTheme.brandLime,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
