import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/bill_provider.dart';
import '../services/image_service.dart';
import '../screens/validation_result_screen.dart';
import '../widgets/loading_overlay.dart';

/// Screen for previewing and editing captured images
class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  
  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final ImageService _imageService = ImageService();
  File? _currentImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return LoadingOverlay(
          isLoading: _isProcessing || billProvider.isProcessing,
          message: _isProcessing 
            ? 'Processing image...' 
            : 'Analyzing bill...',
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Preview Image'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.crop),
                  onPressed: _isProcessing ? null : _cropImage,
                  tooltip: 'Crop Image',
                ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _isProcessing ? null : _enhanceImage,
                  tooltip: 'Enhance Image',
                ),
              ],
            ),
            body: Column(
              children: [
                // Image display
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: _currentImage != null
                        ? InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Image.file(
                              _currentImage!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ),
                
                // Image info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: FutureBuilder<Map<String, int>?>(
                    future: _imageService.getImageDimensions(_currentImage!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final dimensions = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _InfoChip(
                              icon: Icons.photo_size_select_actual,
                              label: '${dimensions['width']} × ${dimensions['height']}',
                            ),
                            _InfoChip(
                              icon: Icons.folder,
                              label: _getFileSizeString(_currentImage!),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Tips for better results
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'For best results, ensure the bill is well-lit and text is clearly visible.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Analyze Bill button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _analyzeBill,
                          icon: const Icon(Icons.analytics),
                          label: const Text('Analyze Bill'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Secondary actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _retakePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Retake'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _selectDifferent,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Select Different'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cropImage() async {
    if (_currentImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final croppedFile = await _imageService.cropImage(_currentImage!);
      
      if (croppedFile != null) {
        setState(() {
          _currentImage = croppedFile;
        });
        
        // Update provider
        if (mounted) {
          context.read<BillProvider>().setCurrentImage(croppedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _enhanceImage() async {
    if (_currentImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final enhancedFile = await _imageService.preprocessImage(_currentImage!);
      
      setState(() {
        _currentImage = enhancedFile;
      });
      
      // Update provider
      if (mounted) {
        context.read<BillProvider>().setCurrentImage(enhancedFile);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image enhanced for better OCR accuracy'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enhance image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _analyzeBill() async {
    if (_currentImage == null) return;

    try {
      await context.read<BillProvider>().validateCurrentImage();
      
      final validationResult = context.read<BillProvider>().validationResult;
      
      if (validationResult != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ValidationResultScreen(result: validationResult),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    Navigator.pop(context);
  }

  Future<void> _selectDifferent() async {
    try {
      final imageFile = await _imageService.selectFromGallery();
      
      if (imageFile != null) {
        setState(() {
          _currentImage = imageFile;
        });
        
        // Update provider
        if (mounted) {
          context.read<BillProvider>().setCurrentImage(imageFile);
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
    }
  }

  String _getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
