import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/services/local_file_opener.dart';
import '../../services/download_helper.dart';

/// İndirilen dosyaları listeleyen ve yöneten sayfa.
class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // 'date' veya 'name'
  bool _sortAsc = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// Uygulama içi zaman çizelgesi veritabanı; kullanıcıya gösterilmez.
  static bool _isHiddenInternalFile(File file) =>
      p.basename(file.path).toLowerCase() == 'timetable.db';

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);

    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final entities = dir.listSync();
      final files = entities
          .whereType<File>()
          .where((f) => !_isHiddenInternalFile(f))
          .toList();

      // Sıralama
      if (_sortBy == 'date') {
        files.sort((a, b) {
          final aTime = a.statSync().modified;
          final bTime = b.statSync().modified;
          return _sortAsc
              ? aTime.compareTo(bTime)
              : bTime.compareTo(aTime);
        });
      } else {
        files.sort((a, b) {
          final aName = a.path.split('/').last.toLowerCase();
          final bName = b.path.split('/').last.toLowerCase();
          return _sortAsc
              ? aName.compareTo(bName)
              : bName.compareTo(aName);
        });
      }

      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DownloadsPage] Dosya listesi hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours < 1) return '${diff.inMinutes} dk önce';
    if (diff.inDays < 1) return '${diff.inHours} saat önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';

    return DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(date);
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.doc':
      case '.docx':
      case '.odt':
      case '.rtf':
        return Icons.description_rounded;
      case '.xls':
      case '.xlsx':
      case '.csv':
        return Icons.table_chart_rounded;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow_rounded;
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        return Icons.folder_zip_rounded;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.svg':
        return Icons.image_rounded;
      case '.mp4':
      case '.avi':
      case '.mkv':
      case '.mov':
        return Icons.videocam_rounded;
      case '.mp3':
        return Icons.audiotrack_rounded;
      case '.txt':
        return Icons.text_snippet_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return const Color(0xFFE53935);
      case '.doc':
      case '.docx':
      case '.odt':
      case '.rtf':
        return const Color(0xFF1565C0);
      case '.xls':
      case '.xlsx':
      case '.csv':
        return const Color(0xFF2E7D32);
      case '.ppt':
      case '.pptx':
        return const Color(0xFFE65100);
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        return const Color(0xFF6D4C41);
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.svg':
        return const Color(0xFF7B1FA2);
      case '.mp4':
      case '.avi':
      case '.mkv':
      case '.mov':
        return const Color(0xFF00838F);
      case '.mp3':
        return const Color(0xFFAD1457);
      default:
        return const Color(0xFF546E7A);
    }
  }

  Future<void> _openFile(File file) async {
    final ok = await LocalFileOpener.open(file.path);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Dosya açılamadı. Uygun bir uygulama yok veya dosya erişilemiyor.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteFile(File file) async {
    final fileName = file.path.split('/').last;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dosyayı Sil'),
        content: Text('"$fileName" silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // App-private kopyayı sil
        await file.delete();
        // Public Downloads kopyasını da sil
        await DownloadHelper.deleteFromPublicDownloads(fileName);
        _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white,
                      size: 20),
                  const SizedBox(width: 10),
                  Text('"$fileName" silindi.'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  void _showFileOptions(File file) {
    final fileName = file.path.split('/').last;
    final stat = file.statSync();
    final ext =
        fileName.contains('.') ? '.${fileName.split('.').last}' : '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Dosya bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getFileColor(ext).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileIcon(ext),
                      color: _getFileColor(ext),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatFileSize(stat.size)}  •  ${_formatDate(stat.modified)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Dosyayı Aç'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Paylaş'),
              onTap: () {
                Navigator.of(ctx).pop();
                Share.shareXFiles(
                  [XFile(file.path)],
                  text: fileName,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400),
              title: Text('Sil', style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.of(ctx).pop();
                _deleteFile(file);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İndirilenler'),
        centerTitle: true,
        actions: [
          // Sıralama menüsü
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sırala',
            onSelected: (value) {
              if (value == _sortBy) {
                _sortAsc = !_sortAsc;
              } else {
                _sortBy = value;
                _sortAsc = value == 'name';
              }
              _loadFiles();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'date'
                          ? (_sortAsc
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.access_time_rounded,
                      size: 18,
                      color: _sortBy == 'date' ? Colors.indigo : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tarihe Göre',
                      style: TextStyle(
                        fontWeight: _sortBy == 'date'
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _sortBy == 'date' ? Colors.indigo : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name'
                          ? (_sortAsc
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.sort_by_alpha_rounded,
                      size: 18,
                      color: _sortBy == 'name' ? Colors.indigo : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'İsme Göre',
                      style: TextStyle(
                        fontWeight: _sortBy == 'name'
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _sortBy == 'name' ? Colors.indigo : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFiles,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index] as File;
                      return _buildFileCard(file);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz indirilen dosya yok',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Canvas veya SIS üzerinden indirdiğiniz\ndosyalar burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(File file) {
    final fileName = file.path.split('/').last;
    final stat = file.statSync();
    final ext =
        fileName.contains('.') ? '.${fileName.split('.').last}' : '';
    final color = _getFileColor(ext);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openFile(file),
          onLongPress: () => _showFileOptions(file),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(0.04),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Dosya ikonu
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _getFileIcon(ext),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Dosya bilgisi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatFileSize(stat.size)}  •  ${_formatDate(stat.modified)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Seçenekler butonu
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => _showFileOptions(file),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
