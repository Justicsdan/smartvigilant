// vigilant_camera.dart - Camera service with real-time AI overlay processing
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'vigilant_api.dart';

class VigilantCameraService {
  static Timer? _processingTimer;
  static Function(Map<String, dynamic> result)? _onDetectionCallback;

  // Start streaming frames to backend for AI analysis
  static void startStream(CameraController controller, Function(Map<String, dynamic>) onDetection) {
    _onDetectionCallback = onDetection;

    _processingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (!controller.value.isInitialized || !controller.value.isStreamingImages) return;

      try {
        final image = await controller.takePicture();
        final bytes = await image.readAsBytes();

        var request = http.MultipartRequest('POST', Uri.parse('${VigilantApi.baseUrl}/vision/analyze'));
        request.files.add(http.MultipartFile.fromBytes('frame', bytes, filename: 'frame.jpg'));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          _onDetectionCallback!(result); // Send detections back to UI
        }
      } catch (e) {
        print("Camera processing error: $e");
      }
    });
  }

  static void stopStream() {
    _processingTimer?.cancel();
    _processingTimer = null;
  }
}
