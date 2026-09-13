import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neysyn/services/article_storage.dart';

class ArticleDetailPage extends StatefulWidget {
  final String authorName;
  final String timeAgo;
  final String imageUrl;
  final String title;
  final String content;
  final Map<String, dynamic> articleData;

  const ArticleDetailPage({
    super.key,
    required this.authorName,
    required this.timeAgo,
    required this.imageUrl,
    required this.title,
    required this.content,
    required this.articleData,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [
    'Keren banget tulisannya, sangat menginspirasi!',
    'Setuju banget sama pembahasan di artikel ini.',
  ];

  @override
  void initState() {
    super.initState();
    ArticleStorage.loadSavedArticles().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.add(text);
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showCommentOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.black87),
                title: const Text('Salin Komentar'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: _comments[index]));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar berhasil disalin!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Hapus Komentar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _comments.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar berhasil dihapus!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = ArticleStorage.isSaved(widget.articleData);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black87,
            ),
            onPressed: () async {
              await ArticleStorage.toggleSave(widget.articleData);
              setState(() {});
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ArticleStorage.isSaved(widget.articleData)
                        ? 'Artikel disimpan ke Bookmarks!'
                        : 'Artikel dihapus dari Bookmarks',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.timeAgo,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: widget.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/images/cat.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.network(
                              widget.imageUrl.startsWith('http')
                                  ? widget.imageUrl
                                  : 'http://localhost:3000${widget.imageUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/images/cat.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(height: 10),
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _comments[index],
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                              onPressed: () => _showCommentOptions(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis tanggapan...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}