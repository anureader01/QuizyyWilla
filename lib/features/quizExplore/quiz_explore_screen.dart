import 'package:flutter/material.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_controller.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_enum.dart';
import 'package:quizbit_2/widgets/quiz_item.dart';

class QuizExploreScreen extends StatefulWidget {
  final QuizCategory category;
  final String? tag;
  const QuizExploreScreen({super.key, required this.category, this.tag});

  @override
  State<QuizExploreScreen> createState() => _QuizExploreScreenState();
}

class _QuizExploreScreenState extends State<QuizExploreScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  final _controller = QuizExploreController();
  final _scrollController = ScrollController();
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.loadInitial(category: widget.category, tag: widget.tag);
    if (!mounted) return;
    setState(() {});
    _fadeController.forward();
  }

  Future<void> _loadMore() async {
    if (_controller.isLoadingMore || !_controller.hasMore) return;
    await _controller.loadMore(category: widget.category, tag: widget.tag);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _refresh() async {
    _fadeController.reset();
    await _controller.loadInitial(category: widget.category, tag: widget.tag);
    if (!mounted) return;
    setState(() {});
    _fadeController.forward();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  String get _title {
    if (widget.category == QuizCategory.byTag && widget.tag != null) {
      return widget.tag!;
    }
    return widget.category.title;
  }

  String get _subtitle {
    switch (widget.category) {
      case QuizCategory.byTag:
        return "Quizzes tagged with #${widget.tag ?? ''}";
      case QuizCategory.newThisWeek:
        return "Fresh picks from this week";
      case QuizCategory.recentlyAdded:
        return "Hot off the press";
      case QuizCategory.mostPlayed:
        return "Community favorites";
      default:
        return "Browse quizzes";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kDark),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kSoft, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: kDark, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kAccent,
          backgroundColor: Colors.white,
          onRefresh: _refresh,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return _buildLoading();
    }
    if (_controller.quizzes.isEmpty) {
      return _buildEmpty();
    }
    return _buildGrid();
  }

  // ============================================================
  // HEADER (sliver-like, sits at top of grid)
  // ============================================================
  Widget _header() {
    final count = _controller.quizzes.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.category.icon,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Result count pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kSoft, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.style_rounded, size: 13, color: kAccent),
                const SizedBox(width: 5),
                Text(
                  "$count ${count == 1 ? 'quiz' : 'quizzes'}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRID
  // ============================================================
  Widget _buildGrid() {
    final showSkeletons = _controller.isLoadingMore;
    final totalItems = _controller.quizzes.length + (showSkeletons ? 2 : 0);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _header()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skeleton placeholders for pagination
                if (index >= _controller.quizzes.length) {
                  return _skeletonTile();
                }
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 40)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: QuizItem(quizModel: _controller.quizzes[index]),
                );
              },
              childCount: totalItems,
            ),
          ),
        ),
        // End-of-list footer
        SliverToBoxAdapter(
          child: !_controller.hasMore && _controller.quizzes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 14, color: kMuted.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        "You've seen them all",
                        style: TextStyle(
                          fontSize: 12,
                          color: kMuted.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 12),
        ),
      ],
    );
  }

  // ============================================================
  // SKELETON TILE
  // ============================================================
  Widget _skeletonTile() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.7),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color: kSoft.withOpacity(value),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // Bottom gradient block (mimics title area)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kMuted.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: kMuted.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LOADING STATE (initial load)
  // ============================================================
  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _headerSkeleton(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _skeletonTile(),
          ),
        ),
      ],
    );
  }

  Widget _headerSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kSoft,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 22,
                  width: 160,
                  decoration: BoxDecoration(
                    color: kSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: kSoft.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmpty() {
    return ListView(
      // ListView so RefreshIndicator works on empty state
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _header(),
        const SizedBox(height: 40),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: kMuted.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Nothing here yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.category == QuizCategory.byTag
                      ? "No quizzes match this tag right now."
                      : "Check back later for new content.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    "Try again",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
