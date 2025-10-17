// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/core/providers/auth_provider.dart';
import 'package:feedly/widgets/upload_preview.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedProvider>();
      provider.token = context.read<AuthProviderCompact>().accessToken;
      provider.fetchCategories();
    });
  }

  Future<void> _showCategorySelector(BuildContext context) async {
    final provider = context.read<FeedProvider>();
    final selectedIds = List<String>.from(provider.upload.categoryIds);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Categories'),
              content: provider.isLoadingCategories
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: provider.categories.map((cat) {
                          final isSelected = selectedIds.contains(cat.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(cat.name),
                            onChanged: (val) {
                              setStateDialog(() {
                                if (val == true) {
                                  selectedIds.add(cat.id);
                                } else {
                                  selectedIds.remove(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    provider.setCategories(selectedIds);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Feed'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// --- Video / Image Preview ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () async {
                  try {
                    await provider.pickVideo();
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: UploadPreview(
                  imagePath: provider.upload.imagePath,
                  videoPath: provider.upload.videoPath,
                  videoController: provider.uploadVideoController,
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// --- Thumbnail & Video Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async => await provider.pickImage(),
                    icon: const Icon(Icons.photo),
                    label: const Text('Thumbnail'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await provider.pickVideo();
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    icon: const Icon(Icons.video_library),
                    label: const Text('Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// --- Description ---
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: provider.setDescription,
            ),
            const SizedBox(height: 24),

            /// --- Category Selector ---
            ElevatedButton.icon(
              onPressed: () async {
                if (provider.categories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Categories not loaded yet')),
                  );
                  return;
                }
                await _showCategorySelector(context);
              },
              icon: const Icon(Icons.category),
              label: Text(
                provider.upload.categoryIds.isEmpty
                    ? 'Select Categories'
                    : 'Selected (${provider.upload.categoryIds.length})',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            /// --- Upload Button / Progress ---
            provider.isUploading
                ? Column(
                    children: [
                      LinearProgressIndicator(value: provider.uploadProgress),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading ${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await provider.uploadFeed();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Feed uploaded successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Upload Feed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
