import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neysyn/services/api_services.dart';
import 'package:neysyn/pages/article_detail_page.dart';
import 'package:neysyn/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _myArticlesFuture;

  String _name = 'nedyna';
  String _username = '@ney_research';
  String _bio = 'Clinical researcher in chronobiology and sleep mechanics. Simplifying medical facts for daily performance optimization.';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyArticles();
    _loadProfileData();
  }

  void _loadMyArticles() {
    setState(() {
      _myArticlesFuture = ApiService.fetchPosts();
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? 'nedyna';
      _username = prefs.getString('profile_username') ?? '@ney_research';
      _bio = prefs.getString('profile_bio') ?? 'Clinical researcher in chronobiology and sleep mechanics. Simplifying medical facts for daily performance optimization.';
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _myArticlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }

          final articles = snapshot.hasData ? snapshot.data! : [];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black12,
                    backgroundImage: _profileImagePath != null
                        ? (kIsWeb
                            ? NetworkImage(_profileImagePath!) as ImageProvider
                            : FileImage(File(_profileImagePath!)) as ImageProvider)
                        : null,
                    child: _profileImagePath == null
                        ? const Icon(Icons.person, size: 40, color: Colors.black54)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _username.startsWith('@') ? _username : '@$_username',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfilePage()),
                            );
                            if (result == true) {
                              _loadProfileData();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Edit profile', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _bio,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('1.4K ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Followers  ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const Text('312 ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Following  ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  Text('${articles.length} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Articles', style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 20),
              // Tab Bar (Published & Likes)
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                tabs: [
                  Tab(text: 'Published (${articles.length})'),
                  const Tab(text: 'Likes (149)'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Published
                    articles.isEmpty
                        ? const Center(child: Text('Belum ada artikel dipublish', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final item = articles[index];
                              final title = item['title'] ?? 'Tanpa Judul';
                              final author = item['author'] ?? _name;
                              final content = item['content'] ?? '';
                              final rawImageUrl = item['image_url'] ?? 'assets/images/cat.png';
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
                                        articleData: item,
                                      ),
                                    ),
                                  ).then((_) => _loadMyArticles());
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 160,
                                          child: rawImageUrl.startsWith('assets/')
                                              ? Image.asset(rawImageUrl, fit: BoxFit.cover)
                                              : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/cat.png', fit: BoxFit.cover)),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'IMMUNE SCIENCE',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '6 MIN READ',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    // Tab 2: Likes
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: const [
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red, size: 20),
                          title: Text(
                            'Shattering the 8 Glasses Myth: A Hydration Study',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text('Disukai dari Prof. Keith Vance · 4 min', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        Divider(color: Color(0xFFE0E0E0), height: 1),
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red, size: 20),
                          title: Text(
                            'The 90-Minute Brain Protocol: Cognitive Alignment',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text('Disukai dari Dr. Clara Vance · 5 min', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}