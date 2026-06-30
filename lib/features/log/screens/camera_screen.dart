import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/aahar_theme.dart';
import '../data/nepali_foods.dart';
import '../models/detected_food.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _analyzing = false;

  Future<void> _capturePhoto({bool fromGallery = false}) async {
    final picker = ImagePicker();
    final source = fromGallery ? ImageSource.gallery : ImageSource.camera;
    final image = await picker.pickImage(source: source);
    if (image == null || !mounted) return;

    setState(() => _analyzing = true);

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _analyzing = false);

    // Mock detected foods — in production this calls a Vision/Claude API
    final detected = _mockDetection();
    context.push('/log/detected', extra: detected);
  }

  List<DetectedFood> _mockDetection() {
    final dalBhat = findFoodById('dal_bhat');
    final achar = findFoodById('achar');
    final papad = findFoodById('papad');

    return [
      if (dalBhat != null)
        DetectedFood(
          foodItem: dalBhat,
          confidencePercent: 97,
          defaultQuantity: 2,
          isSelected: true,
        ),
      if (achar != null)
        DetectedFood(
          foodItem: achar,
          confidencePercent: 81,
          defaultQuantity: 2,
          isSelected: true,
        ),
      if (papad != null)
        DetectedFood(
          foodItem: papad,
          confidencePercent: 64,
          defaultQuantity: 1,
          isSelected: false,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'TAKE A PHOTO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.flash_off_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Viewfinder ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      // Corner brackets
                      const _CornerBrackets(),
                      // Center content
                      Center(
                        child: _analyzing
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AaharTheme.nutrientProtein,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Analyzing food...',
                                    style: TextStyle(
                                      color: AaharTheme.nutrientProtein,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.rice_bowl_outlined,
                                      color: Color(0xFF444444), size: 44),
                                  SizedBox(height: 10),
                                  Text(
                                    'Point at your food',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Place the whole plate within the frame',
                style: TextStyle(color: Color(0xFF666666), fontSize: 13),
              ),

              const Spacer(),

              // ── Controls ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _analyzing
                          ? null
                          : () => _capturePhoto(fromGallery: true),
                      icon: const Icon(Icons.photo_outlined,
                          color: Colors.white, size: 28),
                    ),
                    GestureDetector(
                      onTap: _analyzing ? null : () => _capturePhoto(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 3),
                        ),
                        child: _analyzing
                            ? const SizedBox.shrink()
                            : const Center(
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.flip_camera_ios_outlined,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              // ── Search manually ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            color: Color(0xFF888888), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Search manually instead',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Corner bracket painter ────────────────────────────────────────────────────

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(color: AaharTheme.nutrientProtein),
      child: const SizedBox.expand(),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const margin = 16.0;

    // Top-left
    canvas.drawLine(Offset(margin, margin + len), Offset(margin, margin),
        paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + len, margin),
        paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - margin, margin + len),
        Offset(size.width - margin, margin),
        paint);
    canvas.drawLine(
        Offset(size.width - margin, margin),
        Offset(size.width - margin - len, margin),
        paint);

    // Bottom-left
    canvas.drawLine(
        Offset(margin, size.height - margin - len),
        Offset(margin, size.height - margin),
        paint);
    canvas.drawLine(
        Offset(margin, size.height - margin),
        Offset(margin + len, size.height - margin),
        paint);

    // Bottom-right
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin - len),
        Offset(size.width - margin, size.height - margin),
        paint);
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin - len, size.height - margin),
        paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}
