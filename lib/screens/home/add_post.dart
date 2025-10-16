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
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: provider.categories.map((cat) {
                          final catId = cat.id;
                          final isSelected = selectedIds.contains(catId);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(cat.name),
                            onChanged: (val) {
                              setStateDialog(() {
                                if (val == true) {
                                  if (!selectedIds.contains(catId)) {
                                    selectedIds.add(catId);
                                  }
                                } else {
                                  selectedIds.remove(catId);
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
      appBar: AppBar(title: const Text('Add Feed')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// --- Video / Image Preview ---
            GestureDetector(
              onTap: () async {
                try {
                  await provider.pickVideo();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: SizedBox(
                height: 200,
                child: UploadPreview(
                  imagePath: provider.upload.imagePath,
                  videoPath: provider.upload.videoPath,
                  videoController: provider.uploadVideoController,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async => await provider.pickImage(),
                    icon: const Icon(Icons.photo),
                    label: const Text('Select Thumbnail'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await provider.pickVideo();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    icon: const Icon(Icons.video_library),
                    label: const Text('Select Video'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// --- Description ---
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: provider.setDescription,
            ),
            const SizedBox(height: 16),

            /// --- Category Selector ---
            provider.isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (provider.categories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Categories not loaded yet'),
                          ),
                        );
                        return;
                      }
                      await _showCategorySelector(context);
                    },
                    child: Text(
                      provider.upload.categoryIds.isEmpty
                          ? 'Select Categories'
                          : 'Selected (${provider.upload.categoryIds.length})',
                    ),
                  ),
            const SizedBox(height: 16),

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
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await provider.uploadFeed();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feed uploaded successfully!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Upload Feed'),
                  ),
          ],
        ),
      ),
    );
  }
}
