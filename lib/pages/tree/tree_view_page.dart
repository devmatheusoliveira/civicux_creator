import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/tree_node.dart';
import '../../widgets/tree_card.dart';
import '../../services/gemini_service.dart';
import '../../services/nano_banana_service.dart';
import '../../services/camara_service.dart';
import '../../services/post_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TreeViewPage extends StatefulWidget {
  final String initialRootTitle;
  final int? proposalId;

  const TreeViewPage({
    super.key,
    this.initialRootTitle = 'Início',
    this.proposalId,
  });

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  late TreeNode rootNode;
  final TransformationController _transformationController =
      TransformationController();
  Map<String, dynamic>? proposalDetails;
  bool _loadingProposal = false;

  @override
  void initState() {
    super.initState();
    rootNode = TreeNode(
      id: const Uuid().v4(),
      title: widget.initialRootTitle,
      position: const Offset(2500, 2500),
    );

    if (widget.proposalId != null) {
      _loadProposalDetails();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matrix = Matrix4.identity();
      matrix.translate(-2000.0, -2000.0);
      _transformationController.value = matrix;
    });
  }

  Future<void> _loadProposalDetails() async {
    setState(() => _loadingProposal = true);
    final details = await CamaraService().fetchProposalDetails(
      widget.proposalId!,
    );
    setState(() {
      proposalDetails = details;
      _loadingProposal = false;
    });
  }

  void _addNode(TreeNode parent) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Público'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Descrição do Público',
            hintText: 'Ex: Estudantes de TI',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  final newNode = TreeNode(
                    id: const Uuid().v4(),
                    title: controller.text,
                  );
                  parent.children.add(newNode);
                  _calculateLayout();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _generatePostsFromLeaves() {
    setState(() {
      _addPostToLeaves(rootNode);
      _calculateLayout();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Posts gerados para os nós folha!')),
    );
  }

  void _addPostToLeaves(TreeNode node) {
    if (node.children.isEmpty && !node.isPost) {
      _generateContentForNode(node);
    } else {
      for (var child in node.children) {
        _addPostToLeaves(child);
      }
    }
  }

  Future<void> _generateContentForNode(TreeNode node) async {
    // Create a placeholder post first
    final postNode = TreeNode(
      id: const Uuid().v4(),
      title: 'Gerando conteúdo...',
      isPost: true,
      imageUrl: 'https://picsum.photos/200/300', // Mock image for now
      description: 'Aguarde, estamos criando o post...',
    );

    setState(() {
      node.children.add(postNode);
      _calculateLayout();
    });

    // Build context for AI generation
    String proposalContext = '';
    String? pdfBase64;
    String pdfInstruction = '';

    if (proposalDetails != null) {
      final ementa = proposalDetails!['ementa'] ?? '';
      final keywords = proposalDetails!['keywords'] ?? '';
      final siglaTipo = proposalDetails!['siglaTipo'] ?? '';
      final numero = proposalDetails!['numero']?.toString() ?? '';
      final ano = proposalDetails!['ano']?.toString() ?? '';
      final urlInteiroTeor = proposalDetails!['urlInteiroTeor'];

      proposalContext =
          '''
Proposição: $siglaTipo $numero/$ano
Ementa: $ementa
Palavras-chave: $keywords
''';

      if (urlInteiroTeor != null && urlInteiroTeor.toString().isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(urlInteiroTeor));
          if (response.statusCode == 200) {
            pdfBase64 = base64Encode(response.bodyBytes);
            pdfInstruction =
                'Analise o documento PDF anexo (inteiro teor da lei). Extraia os pontos principais e explique-os de forma simples.';
          }
        } catch (e) {
          print('Erro ao baixar PDF: $e');
        }
      }
    }

    // Call Gemini for Text with full context
    final textPrompt =
        '''
$proposalContext
$pdfInstruction

Assunto: ${proposalDetails?['ementa'] ?? node.title}
Público-alvo: ${node.title}
''';

    final systemInstruction = '''
Você é um especialista em redes sociais.
Sua tarefa é criar APENAS o texto para um post de Instagram.
NÃO inclua introduções, explicações, títulos ou notas como "Aqui está o post".
NÃO use formatação markdown como negrito ou itálico excessivo se não for natural para o Instagram.
O texto deve ser curto, engajador e adaptado ao público-alvo especificado.
Use emojis moderadamente.
Inclua 3-5 hashtags no final.
Se houver um PDF anexo, use as informações dele para garantir precisão técnica, mas explique de forma simples.
''';

    final content = await GeminiService().generatePostContent(
      textPrompt,
      node.title,
      pdfBase64: pdfBase64,
      systemInstruction: systemInstruction,
    );

    // Call Gemini (Nano Banana) for Image with context
    final imagePrompt =
        '''
Create a high-quality image about: ${proposalDetails?['ementa'] ?? node.title}
Target audience: ${node.title}
Style: Modern, vibrant, engaging, suitable for social media
Requirements: Clear visual hierarchy, eye-catching colors, professional design and with humor
''';

    final imageBase64 = await NanoBananaService().generateImage(imagePrompt);

    if (mounted) {
      setState(() {
        postNode.title = 'Post Instagram';
        postNode.description = content;
      });

      if (imageBase64 != null) {
        // Since imageUrl is final, we replace the node
        final updatedNode = TreeNode(
          id: postNode.id,
          title: postNode.title,
          isPost: true,
          imageUrl: imageBase64, // This will be a data URI
          description: content,
          position: postNode.position,
        );

        final index = node.children.indexOf(postNode);
        if (index != -1) {
          setState(() {
            node.children[index] = updatedNode;
          });
        }
      }

      // Save to Supabase
      try {
        await PostService().savePost(
          title: node.title, // Audience
          content: content,
          imageBase64: imageBase64,
          proposalId: widget.proposalId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post salvo na nuvem! ☁️')),
          );
        }
      } catch (e) {
        print('Erro ao salvar post: $e');
      }
    }
  }

  void _calculateLayout() {
    // Simple layout algorithm
    // This needs to be improved for a real tree, but works for a simple demo
    // We'll traverse and set positions relative to parent

    _layoutNode(rootNode, 2500, 2500, 300);
  }

  void _layoutNode(TreeNode node, double x, double y, double availableHeight) {
    node.position = Offset(x, y);

    if (node.children.isEmpty) return;

    double childX = x + 250; // Horizontal spacing

    // Calculate total height needed for children
    double totalChildrenHeight = 0;
    for (var child in node.children) {
      totalChildrenHeight += child.isPost ? 300.0 : 120.0;
    }

    double startY =
        y - (totalChildrenHeight / 2) + (node.children.first.isPost ? 140 : 60);

    double currentY = startY;
    for (int i = 0; i < node.children.length; i++) {
      var child = node.children[i];
      double childHeight = child.isPost ? 300.0 : 120.0;

      _layoutNode(child, childX, currentY, childHeight);

      currentY += childHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'app_logo',
              child: Image.asset('assets/images/logo-icon.png', height: 28),
            ),
            const SizedBox(width: 12),
            Text(
              'Árvore de Hiper-personalização',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.play_arrow_rounded, color: theme.primaryColor),
              tooltip: 'Gerar posts',
              onPressed: _generatePostsFromLeaves,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Infinite Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // Tree View
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 4.0,
            child: SizedBox(
              width: 5000,
              height: 5000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Draw lines
                  CustomPaint(
                    size: const Size(5000, 5000),
                    painter: TreePainter(
                      rootNode: rootNode,
                      lineColor: theme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  // Draw nodes
                  ..._buildNodeWidgets(rootNode),
                ],
              ),
            ),
          ),

          // Floating Controls
          Positioned(
            bottom: 32,
            right: 32,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    _transformationController.value *= Matrix4.diagonal3Values(
                      1.2,
                      1.2,
                      1,
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    _transformationController.value *= Matrix4.diagonal3Values(
                      0.8,
                      0.8,
                      1,
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'center',
                  onPressed: () {
                    final matrix = Matrix4.identity();
                    // Center on the 5000x5000 canvas (approximate center of screen)
                    // Assuming screen center is roughly offset by half of canvas size
                    // But simpler is just identity which puts (0,0) at top left.
                    // To center (2500, 2500), we need to translate by -2500 + screenWidth/2.
                    // For now, let's just reset to identity which shows top-left, but since we moved content to 2500,2500 it might be off-screen.
                    // We should translate to show the content.
                    matrix.translate(-2000.0, -2000.0);
                    _transformationController.value = matrix;
                  },
                  backgroundColor: theme.primaryColor,
                  child: const Icon(Icons.center_focus_strong_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNodeWidgets(TreeNode node) {
    List<Widget> widgets = [];

    widgets.add(
      Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          onPanUpdate: node.isPost
              ? (details) {
                  setState(() {
                    node.position += details.delta;
                  });
                }
              : null,
          child: TreeCard(
            node: node,
            onTap: () => _addNode(node),
            showAddButton: node == rootNode,
          ),
        ),
      ),
    );

    for (var child in node.children) {
      widgets.addAll(_buildNodeWidgets(child));
    }

    return widgets;
  }
}

class TreePainter extends CustomPainter {
  final TreeNode rootNode;
  final Color lineColor;

  TreePainter({required this.rootNode, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawLines(canvas, rootNode, paint);
  }

  void _drawLines(Canvas canvas, TreeNode node, Paint paint) {
    // 150 (card width) + 12 (button offset center) = 162
    // Adjusted for better visual connection
    final parentCenter =
        node.position + const Offset(180, 40); // Center right of card

    for (var child in node.children) {
      final childCenter =
          child.position + const Offset(0, 40); // Center left of card

      final path = Path();
      path.moveTo(parentCenter.dx, parentCenter.dy);

      // Cubic bezier for smooth curve
      path.cubicTo(
        parentCenter.dx + 80,
        parentCenter.dy, // Control point 1
        childCenter.dx - 80,
        childCenter.dy, // Control point 2
        childCenter.dx,
        childCenter.dy,
      );

      canvas.drawPath(path, paint);

      _drawLines(canvas, child, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const double spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
