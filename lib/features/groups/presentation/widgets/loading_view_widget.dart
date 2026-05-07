import 'package:flutter/material.dart';
import 'skeleton_widget.dart';

class LoadingViewWidget extends StatelessWidget {
  const LoadingViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBoxWidget(height: 28, width: 150),
              SkeletonBoxWidget(height: 24, width: 60),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBoxWidget(height: 120),
          const SizedBox(height: 24),
          const SkeletonBoxWidget(height: 200),
          const SizedBox(height: 24),
          Column(
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonLineWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}