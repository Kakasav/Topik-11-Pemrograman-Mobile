import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class SearchResultView extends StatefulWidget {
  const SearchResultView({super.key});

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  final NewsApiService _service = NewsApiService();
  late final String _keyword;
  late Future<List<ArticleModel>> _futureSearch;

  @override
  void initState() {
    super.initState();
    _keyword = Get.arguments as String? ?? '';
    _futureSearch = _service.searchNews(_keyword);
  }

  void _muatUlang() {
    setState(() {
      _futureSearch = _service.searchNews(_keyword);
    });
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureSearch;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        title: Text(
          'Hasil: "$_keyword"',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _futureSearch,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
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
            return Center(
              child: Text(
                'Tidak ada berita ditemukan untuk "$_keyword".',
                style: const TextStyle(color: AppColors.textSecondary),
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
    );
  }
}
