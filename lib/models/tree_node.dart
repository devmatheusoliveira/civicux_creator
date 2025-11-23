import 'package:flutter/material.dart';

class TreeNode {
  final String id;
  String title;
  final List<TreeNode> children;
  Offset position;

  final bool isPost;
  final String? imageUrl;
  String? description;

  TreeNode({
    required this.id,
    required this.title,
    List<TreeNode>? children,
    this.position = Offset.zero,
    this.isPost = false,
    this.imageUrl,
    this.description,
  }) : children = children != null ? List.from(children) : [];
}
