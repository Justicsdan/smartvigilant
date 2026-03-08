import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../utils/vigilant_constants.dart';
import '../utils/vigilant_theme.dart';
import '../services/vigilant_api.dart'; // For future deepfake backend call

class VigilantCamera extends StatefulWidget {
  const VigilantCamera({super.key});

  @override
  State<VigilantCamera> createState() => _VigilantCameraState();
}

class _VigilantCameraState extends State<VigilantCamera> with WidgetsBindingObserver {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _detections = [];
  String _statusMessage = "Initializing guardian...";
  bool _threatDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _statusMessage = "No camera found on device";
      });
      return;
    }

    _controller = CameraController(
      cameras[0], // Front camera — change to cameras[1] for rear if preferred
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _controller.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _statusMessage = "AI Guardian Active — Monitoring";
      });

      // Start real-time processing loop
      _startAIProcessing();
    } catch (e) {
      setState(() {
        _statusMessage = "Camera error: $e";
      });
    }
  }

  Future<void> _startAIProcessing() async {
    while (mounted && _isInitialized) {
      if (_isProcessing || !_controller.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      _isProcessing = true;

      try {
        final image = await _controller.takePicture();

        // Process frame with AI (YOLO + Deepfake)
        final result = await _runAIDetection(image.path);

        setState(() {
          _detections = result['detections'];
          _threatDetected = result['threat_detected'];
          _statusMessage = _threatDetected
              ? "${_detections.length} threat(s) detected!"
              : "All clear — monitoring securely";

          if (_threatDetected) {
            Vibration.vibrate(pattern: [0, 200, 100, 200]);
          }
        });
      } catch (e) {
        debugPrint("AI processing error: $e");
      }

      _isProcessing = false;

      // Control frame rate (~1-2 FPS for battery + performance)
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  // Replace this with real YOLO + Deepfake model inference
  Future<Map<String, dynamic>> _runAIDetection(String imagePath) async {
    // Simulate detection for demo
    await Future.delayed(const Duration(milliseconds: 400));

    final random = DateTime.now().millisecond % 100;

    if (random > 80) {
      return {
        "threat_detected": true,
        "detections": [
          {
            "label": "Unknown Person",
            "confidence": 0.94,
            "type": "person",
            "box": {
              "x": 100.0,
              "y": 150.0,
              "width": 300.0,
              "height": 500.0
            }
          }
        ]
      };
    } else if (random > 60) {
      return {
        "threat_detected": true,
        "detections": [
          {
            "label": "DEEPFAKE DETECTED",
            "confidence": 0.88,
            "type": "deepfake",
            "box": null
          }
        ]
      };
    }

    return {
      "threat_detected": false,
      "detections": []
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: vigilantBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: vigilantAccent, strokeWidth: 6),
              const SizedBox(height: 30),
              Text(
                _statusMessage,
                style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Live Guardian",
          style: GoogleFonts.orbitron(fontSize: 26, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _threatDetected ? Icons.warning_amber_rounded : Icons.security,
              color: _threatDetected ? vigilantDanger : vigilantSuccess,
              size: 32,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_controller),

          // AI Bounding Boxes & Labels
          CustomPaint(
            painter: AIDetectionPainter(_detections),
            child: Container(),
          ),

          // Top Status Bar
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _threatDetected ? vigilantDanger : vigilantAccent,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _threatDetected ? Icons.shield_outlined : Icons.shield,
                    color: _threatDetected ? vigilantDanger : vigilantSuccess,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _statusMessage,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panic Button
          Positioned(
            bottom: 40,
            right: 40,
            child: FloatingActionButton(
              heroTag: "panic",
              backgroundColor: vigilantDanger,
              elevation: 12,
              child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: vigilantCard,
                    title: Text(
                      "EMERGENCY ACTIVATED",
                      style: GoogleFonts.orbitron(color: vigilantDanger, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    content: const Text(
                      "Calling +234 708 030 4822\nAlerting trusted contacts\nLocation shared",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel", style: TextStyle(color: vigilantAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for bounding boxes and deepfake overlay
class AIDetectionPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;

  AIDetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final det in detections) {
      if (det['type'] == 'person' || det['type'] == 'motion') {
        boxPaint.color = vigilantSuccess;
        final box = det['box'] as Map<String, dynamic>;
        final rect = Rect.fromLTWH(
          box['x'] as double,
          box['y'] as double,
          box['width'] as double,
          box['height'] as double,
        );
        canvas.drawRect(rect, boxPaint);

        final label = "${det['label']} ${(det['confidence'] * 100).toStringAsFixed(0)}%";
        textPainter.text = TextSpan(
          text: label,
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            backgroundColor: vigilantSuccess,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(rect.left + 8, rect.top - 32));
      } else if (det['type'] == 'deepfake') {
        // Full screen red overlay
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = vigilantDanger.withOpacity(0.4),
        );

        textPainter.text = TextSpan(
          text: "DEEPFAKE DETECTED",
          style: GoogleFonts.orbitron(
            color: vigilantDanger,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: textPainter.width + 40,
            height: textPainter.height + 20,
          ),
          Paint()..color = Colors.black.withOpacity(0.7),
        );
        textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
