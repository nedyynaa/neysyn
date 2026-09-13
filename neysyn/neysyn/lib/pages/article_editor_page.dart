import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neysyn/services/api_services.dart';

class ArticleEditorPage extends StatefulWidget {
  final Map<String, dynamic>? articleData;

  const ArticleEditorPage({super.key, this.articleData});

  @override
  State<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends State<ArticleEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  XFile? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.articleData != null) {
      _titleController.text = widget.articleData!['title'] ?? '';
      _contentController.text = widget.articleData!['content'] ?? '';
      _existingImageUrl = widget.articleData!['image_url'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _submitArticle() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan konten tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.articleData == null) {
        await ApiService.createPost(
          title,
          content,
          _imageFile,
        );
      } else {
        final postId = widget.articleData!['post_id'];
        await ApiService.updatePost(
          postId,
          title,
          content,
          _imageFile,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan artikel: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.articleData != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Artikel' : 'Tulis Artikel',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? 'Update' : 'Publish', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      )
                    : (_existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _existingImageUrl!.startsWith('http')
                                  ? _existingImageUrl!
                                  : 'http://localhost:3000$_existingImageUrl',
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tambah Cover Artikel', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          )),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Judul Artikel...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 12,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Tulis isi artikel kamu di sini...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}