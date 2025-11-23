import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/post_controller.dart';
import '../../models/post_model.dart';
import 'widgets/post_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PostController>().loadPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed (MVC + Provider + HTTP)'),
      ),
      body: Consumer<PostController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.loadPosts,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (controller.posts.isEmpty) {
            return const Center(child: Text('Nenhum post carregado.'));
          }

          return RefreshIndicator(
            onRefresh: controller.loadPosts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.posts.length,
              itemBuilder: (context, index) {
                final PostModel post = controller.posts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<PostController>().loadPosts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
