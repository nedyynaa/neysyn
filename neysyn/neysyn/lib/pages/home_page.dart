import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neysyn/services/api_services.dart';
import 'package:neysyn/pages/article_detail_page.dart';
import 'package:neysyn/pages/article_editor_page.dart';
import 'package:neysyn/pages/saved_page.dart';
import 'package:neysyn/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _articlesFuture;
  final int _currentIndex = 0;
  String _activeAuthorName = 'nedyna';
  
  // State untuk menyimpan status like per artikel (berdasarkan post_id atau index)
  final Map<dynamic, bool> _likedStatus = {};
  final Map<dynamic, int> _likeCounts = {};

  @override
  void initState() {
    super.initState();
    _loadProfileName();
    _loadArticles();
  }

  Future<void> _loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeAuthorName = prefs.getString('profile_name') ?? 'nedyna';
    });
  }

  void _loadArticles() {
    setState(() {
      _articlesFuture = ApiService.fetchPosts();
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      return;
    } else if (index == 1) {
      Navigator.pushNamed(context, '/search');
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ArticleEditorPage()),
      ).then((_) {
        _loadArticles();
        _loadProfileName();
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedPage()),
      ).then((_) => setState(() {}));
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) {
        _loadArticles();
        _loadProfileName();
      });
    }
  }

  // Fungsi memunculkan Bottom Sheet untuk menu titik tiga (Edit & Delete)
  void _showArticleOptions(BuildContext context, dynamic article, dynamic articleId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.blueAccent),
                title: const Text('Edit Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleEditorPage(articleData: article),
                    ),
                  );
                  _loadArticles();
                  _loadProfileName();
                },
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Hapus Artikel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ApiService.deletePost(articleId);
                    _loadArticles();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Artikel berhasil dihapus')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus: $e')),
                    );
                  }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'neysyn',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArticleEditorPage(),
                ),
              );
              _loadArticles();
              _loadProfileName();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat: ${snapshot.error}',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada artikel ditemukan',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final articles = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: articles.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Color(0xFFE0E0E0), height: 1),
            ),
            itemBuilder: (context, index) {
              final article = articles[index];
              final articleId = article['post_id'] ?? index;

              final rawAuthor = article['author'];
              final author = (rawAuthor == null || rawAuthor == 'Penulis' || rawAuthor == 'Tim Redaksi')
                  ? _activeAuthorName
                  : rawAuthor;

              final title = article['title'] ?? 'Tanpa Judul';
              final snippet = article['content'] ?? '';

              final rawImageUrl = article['image_url'] ?? 'assets/images/cat.png';
              final imageUrl = rawImageUrl.startsWith('http')
                  ? rawImageUrl
                  : 'http://localhost:3000$rawImageUrl';

              // Inisialisasi state like
              final isLiked = _likedStatus[articleId] ?? false;
              final likeCount = (_likeCounts[articleId] ?? 149) + (isLiked ? 1 : 0);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailPage(
                        authorName: author,
                        timeAgo: 'Baru saja',
                        imageUrl: rawImageUrl.startsWith('assets/') ? rawImageUrl : imageUrl,
                        title: title,
                        content: snippet,
                        articleData: article,
                      ),
                    ),
                  ).then((_) {
                    _loadArticles();
                    _loadProfileName();
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          author,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snippet,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 95,
                            height: 75,
                            child: rawImageUrl.startsWith('assets/')
                                ? Image.asset(
                                    rawImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Image.asset(
                                      'assets/images/cat.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/cat.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Like Interaktif
                        InkWell(
                          onTap: () {
                            setState(() {
                              _likedStatus[articleId] = !isLiked;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.black45,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  color: isLiked ? Colors.red : Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu Titik Tiga (Edit & Delete tersembunyi di sini)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () => _showArticleOptions(context, article, articleId),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}