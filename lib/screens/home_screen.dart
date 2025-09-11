import 'package:flutter/material.dart';
import '../screens/camera_screen.dart';
import '../screens/image_preview_screen.dart';
import '../services/image_service.dart';
import '../widgets/loading_overlay.dart';

/// Home screen of the bill validator app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageService _imageService = ImageService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Validator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Selecting image...',
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      // App logo/icon placeholder
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 24),
                      // Welcome text
                      Text(
                        'Bill Validator',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Capture or select a bill image to validate calculations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48),
                      _ActionButtons(),
                      SizedBox(height: 32),
                      _RecentValidations(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectFromGallery() async {
    setState(() => _isLoading = true);
    
    try {
      final imageFile = await _imageService.selectFromGallery();
      
      if (imageFile != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

/// Action buttons for camera and gallery
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    // Get access to the parent state
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    
    return Column(
      children: [
        // Take Photo button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Select from Gallery button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: homeState?._selectFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select from Gallery'),
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

/// Recent validations section
class _RecentValidations extends StatelessWidget {
  const _RecentValidations();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Validations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No recent validations',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
