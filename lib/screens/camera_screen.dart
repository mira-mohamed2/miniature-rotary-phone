import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../services/image_service.dart';
import '../screens/image_preview_screen.dart';
import '../widgets/loading_overlay.dart';

/// Camera screen for capturing bill images
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImageService _imageService = ImageService();
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isCapturing,
      message: 'Capturing image...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capture Bill'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _selectFromGallery,
              tooltip: 'Select from Gallery',
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Position your bill in the viewfinder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Make sure the bill is well-lit and all text is clearly visible for best results.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32),
              _CameraGuidelines(),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "gallery",
              onPressed: _selectFromGallery,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.photo_library, color: Colors.black),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.large(
              heroTag: "camera",
              onPressed: _captureImage,
              backgroundColor: Colors.white,
              child: const Icon(Icons.camera, color: Colors.black, size: 32),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final imageFile = await _imageService.captureFromCamera();
      
      if (imageFile != null) {
        // Update provider with captured image
        if (mounted) {
          context.read<BillProvider>().setCurrentImage(imageFile);
          
          // Navigate to image preview
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePreviewScreen(imageFile: imageFile),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _selectFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final imageFile = await _imageService.selectFromGallery();
      
      if (imageFile != null) {
        // Update provider with selected image
        if (mounted) {
          context.read<BillProvider>().setCurrentImage(imageFile);
          
          // Navigate to image preview
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePreviewScreen(imageFile: imageFile),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}

/// Guidelines widget to help with bill positioning
class _CameraGuidelines extends StatelessWidget {
  const _CameraGuidelines();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Corner markers
          ...List.generate(4, (index) {
            return Positioned(
              top: index < 2 ? 0 : null,
              bottom: index >= 2 ? 0 : null,
              left: index % 2 == 0 ? 0 : null,
              right: index % 2 == 1 ? 0 : null,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.yellow,
                      width: index < 2 ? 3 : 0,
                    ),
                    bottom: BorderSide(
                      color: Colors.yellow,
                      width: index >= 2 ? 3 : 0,
                    ),
                    left: BorderSide(
                      color: Colors.yellow,
                      width: index % 2 == 0 ? 3 : 0,
                    ),
                    right: BorderSide(
                      color: Colors.yellow,
                      width: index % 2 == 1 ? 3 : 0,
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Center text
          const Center(
            child: Text(
              'BILL',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
