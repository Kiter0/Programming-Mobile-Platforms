import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_state.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final AppState appState;

  const ProductCard({
    super.key,
    required this.product,
    required this.appState,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  bool _isLoading = true;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

 void _toggleFavorite() {
    widget.appState.toggleFavorite(widget.product);
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.appState.isFavorite(widget.product);
    
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) {
          return;
        }

        if (details.primaryVelocity! > 0) {
          if (!widget.appState.isFavorite(widget.product)) {
            _toggleFavorite();
          }
        } else if (details.primaryVelocity! < 0) {
          if (widget.appState.isFavorite(widget.product)) {
            _toggleFavorite();
          }
        }
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          _showImagePreview(context);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(isFavorite),
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.product.description,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                             widget.appState.addToCart(widget.product);

                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.product.name} додано до кошика',
                                ),
                              duration: const Duration(milliseconds: 700),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('До кошика'),
                      ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
  return SizedBox(
    height: 220,
    width: double.infinity,
    child: Image.network(
      widget.product.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          if (_isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
          }

          return child;
        }

        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        }

        return Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'Не вдалося завантажити зображення',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    ),
  );
}

  void _showImagePreview(BuildContext context) {
    if (_isLoading) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
