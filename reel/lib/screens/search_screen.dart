// 검색 화면 — AI 추천 태그 + 키워드로 사진 찾기
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  static const _suggestedTags = ['해변', '노을', '음식', '산', '생일', '집', '봄', '겨울', '여행', '가족'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    _controller.text = query;
    ref.read(searchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 헤더 + 검색창
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('사진 찾기',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                _SearchBar(
                  controller: _controller,
                  onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                  onClear: () => _search(''),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 추천 태그
                  const Text('AI 추천 태그', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _suggestedTags.map((tag) => _TagChip(
                      tag: tag,
                      active: query == tag,
                      onTap: () => _search(query == tag ? '' : tag),
                    )).toList(),
                  ),
                  const SizedBox(height: 28),
                  // 검색 결과
                  if (query.isNotEmpty) ...[
                    resultsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                      error: (_, __) => const Text('검색 실패', style: TextStyle(color: AppColors.textSecondary)),
                      data: (photos) => _SearchResults(query: query, photos: photos),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: '장소, 음식, 사람…',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(onTap: onClear, child: const Icon(Icons.close, color: Colors.white38, size: 18)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final bool active;
  final VoidCallback onTap;

  const _TagChip({required this.tag, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.accent.withOpacity(0.2) : const Color(0x14000000),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<Photo> photos;
  const _SearchResults({required this.query, required this.photos});

  static const _gradients = [
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
  ];

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('"$query" 검색 결과가 없어요',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15), textAlign: TextAlign.center),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('검색 결과', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            Text('사진 ${photos.length}장', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 3, crossAxisSpacing: 3,
          ),
          itemCount: photos.length,
          itemBuilder: (_, i) {
            final file = File(photos[i].filePath);
            return ClipRRect(
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _gradients[i % _gradients.length],
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
