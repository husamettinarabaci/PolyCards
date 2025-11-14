import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for managing word images with fallback support
/// Handles loading images from assets with graceful fallback to placeholder
class ImageAssetService {
  // Private constructor for singleton pattern
  ImageAssetService._();
  
  static final ImageAssetService _instance = ImageAssetService._();
  
  /// Get singleton instance
  static ImageAssetService get instance => _instance;
  
  /// Base path for word images
  static const String _basePath = 'assets/images/words';
  
  /// Cache of available images to avoid repeated lookups
  final Map<String, bool> _imageCache = {};
  
  /// Get the image path for a word ID
  /// Returns the full asset path if image exists, null otherwise
  Future<String?> getImagePath(String wordId) async {
    // Check cache first
    if (_imageCache.containsKey(wordId)) {
      return _imageCache[wordId]! ? '$_basePath/$wordId.png' : null;
    }
    
    // Try PNG first
    bool pngExists = await _checkImageExists('$_basePath/$wordId.png');
    if (pngExists) {
      _imageCache[wordId] = true;
      return '$_basePath/$wordId.png';
    }
    
    // Try JPG
    bool jpgExists = await _checkImageExists('$_basePath/$wordId.jpg');
    if (jpgExists) {
      _imageCache[wordId] = true;
      return '$_basePath/$wordId.jpg';
    }
    
    // Try JPEG
    bool jpegExists = await _checkImageExists('$_basePath/$wordId.jpeg');
    if (jpegExists) {
      _imageCache[wordId] = true;
      return '$_basePath/$wordId.jpeg';
    }
    
    // No image found
    _imageCache[wordId] = false;
    return null;
  }
  
  /// Check if an image asset exists
  Future<bool> _checkImageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear the image cache
  void clearCache() {
    _imageCache.clear();
  }
  
  /// Preload images for a list of word IDs
  /// Useful for improving performance by caching availability
  Future<void> preloadImageAvailability(List<String> wordIds) async {
    for (String wordId in wordIds) {
      await getImagePath(wordId);
    }
  }
}

/// Widget that displays a word image with automatic fallback
class WordImage extends StatelessWidget {
  final String wordId;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const WordImage({
    super.key,
    required this.wordId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ImageAssetService.instance.getImagePath(wordId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return _buildPlaceholder(context, isLoading: true);
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // Image found - display it
          return Image.asset(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              // Error loading image - show placeholder
              return _buildPlaceholder(context);
            },
          );
        }
        
        // No image found - show placeholder
        return _buildPlaceholder(context);
      },
    );
  }
  
  /// Build placeholder widget when image is not available
  Widget _buildPlaceholder(BuildContext context, {bool isLoading = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(
                color: colorScheme.primary,
              )
            : Icon(
                Icons.image_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

/// Circular word image widget (for avatars, icons, etc.)
class CircularWordImage extends StatelessWidget {
  final String wordId;
  final double radius;
  
  const CircularWordImage({
    super.key,
    required this.wordId,
    this.radius = 40,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: WordImage(
        wordId: wordId,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
      ),
    );
  }
}
