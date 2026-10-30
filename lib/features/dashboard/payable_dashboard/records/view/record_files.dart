import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/files/file_links.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/payable_record.dart';

/// Opens a file the phone's way: a PDF or other document in its viewer app (or the browser).
/// The Upload tree is public on the Java server (`/uploads/**`), so no sign-in is needed for the link.
Future<void> openRecordFile(BuildContext context, RecordFile file) async {
  final url = fileUrl(file.path);
  final ok = url.isNotEmpty && await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open ${file.name}')));
  }
}

Future<void> shareRecordFile(RecordFile file) =>
    SharePlus.instance.share(ShareParams(text: fileUrl(file.path), subject: file.name));

/// The files of a record: photos as thumbnails (tap → full screen, swipe between them), other files as rows.
class RecordFilesGrid extends StatelessWidget {
  const RecordFilesGrid({super.key, required this.files});

  final List<RecordFile> files;

  @override
  Widget build(BuildContext context) {
    final images = files.where((f) => f.isImage).toList();
    final others = files.where((f) => !f.isImage).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (images.isNotEmpty)
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < images.length; i++)
            GestureDetector(
              key: ValueKey('file-thumb-$i'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => RecordPhotoViewer(photos: images, start: i))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 92,
                  height: 92,
                  color: AppTokens.surfaceChip,
                  child: CachedNetworkImage(
                    imageUrl: fileUrl(images[i].path),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppTokens.textMuted),
                  ),
                ),
              ),
            ),
        ]),
      if (images.isNotEmpty && others.isNotEmpty) const SizedBox(height: 10),
      for (final f in others)
        Material(
          color: AppTokens.surfacePage,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => openRecordFile(context, f),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(children: [
                Icon(f.isPdf ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
                    color: f.isPdf ? Palette.redDanger : AppTokens.brandPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
                    Text(_size(f.size), style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  ]),
                ),
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () => shareRecordFile(f),
                ),
                const Icon(Icons.open_in_new, size: 18, color: AppTokens.textMuted),
              ]),
            ),
          ),
        ),
    ]);
  }
}

String _size(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Photos full screen: pinch to zoom, swipe between them, share or open in the browser.
class RecordPhotoViewer extends StatefulWidget {
  const RecordPhotoViewer({super.key, required this.photos, this.start = 0});

  final List<RecordFile> photos;
  final int start;

  @override
  State<RecordPhotoViewer> createState() => _RecordPhotoViewerState();
}

class _RecordPhotoViewerState extends State<RecordPhotoViewer> {
  late final PageController _pages = PageController(initialPage: widget.start);
  late int _index = widget.start;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.photos[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.photos.length > 1 ? '${_index + 1} / ${widget.photos.length}' : f.name,
            style: AppTypography.bodyLarge(color: Colors.white)),
        actions: [
          IconButton(tooltip: 'Share', icon: const Icon(Icons.share_outlined), onPressed: () => shareRecordFile(f)),
          IconButton(
              tooltip: 'Open', icon: const Icon(Icons.open_in_new), onPressed: () => openRecordFile(context, f)),
        ],
      ),
      body: PageView.builder(
        controller: _pages,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: fileUrl(widget.photos[i].path),
              fit: BoxFit.contain,
              placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
