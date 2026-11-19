import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  static const Map<String, String> _topics = {
    '("voice cloning" OR "voice clone") NOT scam NOT fraud': 'AI Kloning Suara',
    '(deepfake AND (voice OR audio)) NOT "voice cloning" NOT scam':
        'Deepfake Suara',
    'AI AND (scam OR fraud) AND (voice OR call OR phone)': 'Kasus Penipuan',
    'ElevenLabs OR "text to speech" OR "voice synthesis" OR "voice generator"':
        'Teknologi TTS',
    'AI AND voice AND (lawsuit OR copyright OR regulation OR ethics)':
        'Etika & Regulasi',
  };

  late String _selectedQuery;
  final Map<String, Future<List<ArticleModel>>> _cache = {};
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _selectedQuery = _topics.keys.first;
    _futureNews = _ambilAtauDariCache(_selectedQuery);
  }

  Future<List<ArticleModel>> _ambilAtauDariCache(String query) {
    return _cache.putIfAbsent(query, () => _service.searchNews(query));
  }

  void _muatUlang() {
    setState(() {
      _cache[_selectedQuery] = _service.searchNews(_selectedQuery);
      _futureNews = _cache[_selectedQuery]!;
    });
  }

  void _gantiTopik(String query) {
    if (query == _selectedQuery) return;
    setState(() {
      _selectedQuery = query;
      _futureNews = _ambilAtauDariCache(_selectedQuery);
    });
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {}
  }

  void _bukaDialogCari() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.primaryPurple),
            SizedBox(width: 8),
            Text('Cari Berita AI Suara'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contoh: ElevenLabs, kloning suara...',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            final keyword = value.trim();
            if (keyword.isEmpty) return;
            Navigator.pop(context);
            Get.toNamed(AppRoutes.search, arguments: keyword);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final keyword = controller.text.trim();
              if (keyword.isEmpty) return;
              Navigator.pop(context);
              Get.toNamed(AppRoutes.search, arguments: keyword);
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        title: const Row(
          children: [
            Icon(Icons.graphic_eq_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'VoiceAI News',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Berita',
            onPressed: _bukaDialogCari,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopicChips(),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _muatUlang,
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 56,
                          color: AppColors.accentViolet,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada berita untuk topik ini.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () =>
                            Get.toNamed(AppRoutes.detail, arguments: article),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChips() {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final query = _topics.keys.elementAt(index);
          final isSelected = query == _selectedQuery;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _gantiTopik(query),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.mainGradient : null,
                  color: isSelected ? null : AppColors.softTint,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _topics[query]!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
