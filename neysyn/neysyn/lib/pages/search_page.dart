import 'package:flutter/material.dart';
import 'package:neysyn/services/api_services.dart';
import 'package:neysyn/pages/article_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allArticles = [];
  List<dynamic> _filteredArticles = [];
  bool _isLoading = true;

  final List<String> _trendingTags = [
    '#CircadianRhythm',
    '#GutMicrobiome',
    '#BlueLightFilter',
    '#ActiveHeartRate',
    '#VitaminDAbsorption',
  ];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final posts = await ApiService.fetchPosts();
      setState(() {
        _allArticles = posts;
        _filteredArticles = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSearch(String query) {
    final searchQuery = query.toLowerCase().trim();
    setState(() {
      _filteredArticles = _allArticles.where((article) {
        final title = (article['title'] ?? '').toLowerCase();
        final content = (article['content'] ?? '').toLowerCase();
        final author = (article['author'] ?? '').toLowerCase();

        return title.contains(searchQuery) ||
            content.contains(searchQuery) ||
            author.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Fungsional Reaktif
                  TextField(
                    controller: _searchController,
                    onChanged: _filterSearch,
                    decoration: InputDecoration(
                      hintText: 'Search symptoms, myths, facts...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _filterSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trending Searches
                  const Text(
                    'TRENDING SEARCHES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _trendingTags.map((tag) {
                      return ActionChip(
                        label: Text(tag, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        onPressed: () {
                          final keyword = tag.replaceAll('#', '');
                          _searchController.text = keyword;
                          _filterSearch(keyword);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Hasil Pencarian atau Daftar Artikel
                  const Text(
                    'HASIL PENCARIAN & ARTIKEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _filteredArticles.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              'Tidak ada artikel yang cocok dengan pencarian.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredArticles.length,
                          separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEEEEEE)),
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            final title = article['title'] ?? 'Tanpa Judul';
                            final author = article['author'] ?? 'Penulis';
                            final content = article['content'] ?? '';
                            final rawImageUrl = article['image_url'] ?? 'assets/images/cat.png';
                            final imageUrl = rawImageUrl.startsWith('http')
                                ? rawImageUrl
                                : 'http://localhost:3000$rawImageUrl';

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
                                      content: content,
                                      articleData: article,
                                    ),
                                  ),
                                );
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
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Oleh $author',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 75,
                                      height: 60,
                                      child: rawImageUrl.startsWith('assets/')
                                          ? Image.asset(rawImageUrl, fit: BoxFit.cover)
                                          : Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Image.asset(
                                                'assets/images/cat.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}