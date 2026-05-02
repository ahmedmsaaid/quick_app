import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../riverpod/pagination_state.dart';

enum PaginationViewType { list, grid }

class PaginationListView<T> extends ConsumerStatefulWidget {
  final StateNotifierProvider<dynamic, PaginationState<T>> provider;

  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  final PaginationViewType viewType;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double gridChildAspectRatio;
  final SliverGridDelegate? gridDelegate;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? loadMoreWidget;
  final double loadMoreThreshold;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Widget Function(BuildContext, String)? errorBuilder;

  final void Function()? onLoadMore;

  const PaginationListView({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.viewType = PaginationViewType.list,
    this.gridCrossAxisCount = 2,
    this.gridMainAxisSpacing = 10,
    this.gridCrossAxisSpacing = 10,
    this.gridChildAspectRatio = 1.0,
    this.gridDelegate,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadMoreWidget,
    this.loadMoreThreshold = 200.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.errorBuilder,
    this.onLoadMore,
  });

  @override
  ConsumerState<PaginationListView<T>> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends ConsumerState<PaginationListView<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - widget.loadMoreThreshold) {
      // widget.onLoadMore?.call();
      onLoadMore();
    }
  }

  void onLoadMore() {
    ref.read(widget.provider.notifier).loadMore();
  }

  void onInitial() {
    ref.read(widget.provider.notifier).loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(widget.provider);

    return paginationState.when(
      initial: () => widget.emptyWidget ?? const SizedBox.shrink(),

      loading: () => widget.loadingWidget ?? const _CenterLoader(),

      data: (items, hasMore, page) {
        if (items.isEmpty) {
          return widget.emptyWidget ?? const _EmptyView();
        }

        return _buildContent(items: items, hasMore: hasMore);
      },

      error: (message, items) {
        if (items == null || items.isEmpty) {
          return _ErrorView(message: message, onRetry: () => onInitial());
        }

        return _buildContent(
          items: items,
          hasMore: false,
          errorMessage: message,
        );
      },
    );
  }

  Widget _buildContent({
    required List<T> items,
    required bool hasMore,
    String? errorMessage,
  }) {
    if (widget.viewType == PaginationViewType.grid) {
      return _buildGridView(items, hasMore, errorMessage);
    }
    return _buildListView(items, hasMore, errorMessage);
  }

  Widget _buildListView(List<T> items, bool hasMore, String? errorMessage) {
    return RefreshIndicator(
      onRefresh: () async {
        // widget.onLoadMore?.call();
        onInitial();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + (hasMore || errorMessage != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < items.length) {
            return widget.itemBuilder(context, items[index], index);
          }

          if (errorMessage != null) {
            return _ErrorFooter(
              message: errorMessage,
              onRetry:
                  // widget.onLoadMore ??
                  () {
                    onInitial();
                  },
            );
          }

          return widget.loadMoreWidget ??
              Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
        },
      ),
    );
  }

  Widget _buildGridView(List<T> items, bool hasMore, String? errorMessage) {
    return RefreshIndicator(
      onRefresh: () async {
        // widget.onLoadMore?.call();
        onInitial();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        gridDelegate:
            widget.gridDelegate ??
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.gridCrossAxisCount,
              mainAxisSpacing: widget.gridMainAxisSpacing,
              crossAxisSpacing: widget.gridCrossAxisSpacing,
              childAspectRatio: widget.gridChildAspectRatio,
            ),
        itemCount: items.length + (hasMore || errorMessage != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < items.length) {
            return widget.itemBuilder(context, items[index], index);
          }

          if (errorMessage != null) {
            return _ErrorFooter(
              message: errorMessage,
              onRetry:
                  // widget.onLoadMore ??
                  () {
                    onInitial();
                  },
            );
          }

          return widget.loadMoreWidget ??
              Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}

// Helper Widgets
class _CenterLoader extends StatelessWidget {
  const _CenterLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No items found'));
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorFooter extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorFooter({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          SizedBox(height: 8.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
