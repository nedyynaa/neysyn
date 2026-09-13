import 'package:flutter/material.dart';
import 'package:neysyn/services/article_storage.dart';
import 'package:neysyn/pages/article_detail_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
    ArticleStorage.loadSavedArticles().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedList = ArticleStorage.savedArticles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: savedList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada artikel yang disimpan',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: savedList.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Color(0xFFE0E0E0), height: 1),
              ),
              itemBuilder: (context, index) {
                final article = savedList[index];
                final title = article['title'] ?? 'Tanpa Judul';
                final author = article['author'] ?? 'Penulis';
                final content = article['content'] ?? '';
                final rawImageUrl = article['image_url'] ?? 'assets/images/cat.png';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(
                          authorName: author,
                          timeAgo: 'Baru saja',
                          imageUrl: rawImageUrl,
                          title: title,
                          content: content,
                          articleData: article,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$author · 4 min',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.black),
                        onPressed: () async {
                          await ArticleStorage.toggleSave(article);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}