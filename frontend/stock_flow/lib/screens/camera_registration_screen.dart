import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stock_flow/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraRegistrationScreen extends StatefulWidget {
  const CameraRegistrationScreen({super.key});

  @override
  State<CameraRegistrationScreen> createState() => _CameraRegistrationScreenState();
}

class _CameraRegistrationScreenState extends State<CameraRegistrationScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // 2. Viewfinder Overlay
          const Positioned.fill(
            child: ViewfinderOverlay(),
          ),

          // 3. Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  Text(
                    'Captura de Activo',
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Center Label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Encuadra tu factura aquí',
                style: GoogleFonts.notoSerif(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 5. Bottom Instructions & Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Asegúrate de que el documento esté bien\niluminado y sea legible.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildControlButton(Icons.photo_library_rounded, () {}),
                        _buildCaptureButton(),
                        _buildControlButton(
                          _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          _toggleFlash,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        // Capture logic
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ViewfinderPainter(),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Define the scanning area
    double cardWidth = size.width * 0.8;
    double cardHeight = size.height * 0.6;
    double left = (size.width - cardWidth) / 2;
    double top = (size.height - cardHeight) / 2;
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cardWidth, cardHeight),
      const Radius.circular(24),
    );

    // 1. Draw mask (dark overlay outside the viewfinder)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // 2. Draw dashed border
    final borderPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    _drawDashedRRect(canvas, rect, borderPaint);
    
    // 3. Draw solid corners for emphasis
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    double cornerLength = 30;
    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + 15)
        ..quadraticBezierTo(left, top, left + 15, top)
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(left + cardWidth - cornerLength, top)
        ..lineTo(left + cardWidth - 15, top)
        ..quadraticBezierTo(left + cardWidth, top, left + cardWidth, top + 15)
        ..lineTo(left + cardWidth, top + cornerLength),
      cornerPaint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cardHeight - cornerLength)
        ..lineTo(left, top + cardHeight - 15)
        ..quadraticBezierTo(left, top + cardHeight, left + 15, top + cardHeight)
        ..lineTo(left + cornerLength, top + cardHeight),
      cornerPaint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(left + cardWidth - cornerLength, top + cardHeight)
        ..lineTo(left + cardWidth - 15, top + cardHeight)
        ..quadraticBezierTo(left + cardWidth, top + cardHeight, left + cardWidth, top + cardHeight - 15)
        ..lineTo(left + cardWidth, top + cardHeight - cornerLength),
      cornerPaint,
    );
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    const double dashWidth = 8;
    const double dashSpace = 8;
    final path = Path()..addRRect(rrect);
    
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
