import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shop_home_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();
  int _currentImagePage = 0;
  bool _isFavorite = false;

  late final List<String> _productImages;

  // Variation images matching screenshot (without border)
  final List<String> _variationImages = const [
    'assets/images/flesh sale/Placeholder_01-4.jpg',
    'assets/images/flesh sale/Placeholder_01-1.jpg',
    'assets/images/flesh sale/Placeholder_01-5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Build gallery list starting with the actual clicked product image
    _productImages = [
      widget.product.imageAsset,
      'assets/images/categories/Image@2x.png',
      'assets/images/flesh sale/Placeholder_01.jpg',
      'assets/images/flesh sale/Placeholder_01-1.jpg',
    ];
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Carousel with Slide Animation
                  _buildImageCarousel(),

                  const SizedBox(height: 16),

                  // Price and Direct Share Image (No container / shadow)
                  _buildPriceRow(),

                  const SizedBox(height: 12),

                  // Description Text
                  _buildDescription(),

                  const SizedBox(height: 24),

                  // Variations Section (No borders on thumbnail images)
                  _buildVariationsSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar (Black Add to Cart + Blue Buy Now)
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─── IMAGE CAROUSEL ───────────────────────────────────────
  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.48,
          child: PageView.builder(
            controller: _imageController,
            onPageChanged: (index) {
              setState(() => _currentImagePage = index);
            },
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _productImages[index],
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/categories/Image@2x.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                  );
                },
              );
            },
          ),
        ),

        // Back Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),

        // Page indicators matching screenshot (Blue active pill + Gray inactive dots)
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_productImages.length, (index) {
              final isSelected = _currentImagePage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFD0D4DC),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── PRICE & DIRECT SHARE ROW ──────────────────────────────
  Widget _buildPriceRow() {
    // Format price e.g. $17,00
    final priceStr = '\$${widget.product.price.toStringAsFixed(2).replaceAll('.', ',')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bold Price Text
          Text(
            priceStr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          // Direct Share Image (No background container or shadow)
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'assets/images/categories/Share.png',
              width: 26,
              height: 26,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.share, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DESCRIPTION ──────────────────────────────────────────
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.product.description.isNotEmpty
            ? widget.product.description
            : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF444444),
          height: 1.45,
        ),
      ),
    );
  }

  // ─── VARIATIONS SECTION (NO BORDER ON IMAGES) ─────────────
  Widget _buildVariationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Variations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 14),
              // Pink chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pink',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // M chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'M',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              // Arrow button
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0052FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Variation image thumbnails (WITHOUT BORDER as requested)
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _variationImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 85,
                    height: 85,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        _variationImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM ACTION BAR ────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Wishlist heart button (Bold icon)
            GestureDetector(
              onTap: () {
                setState(() => _isFavorite = !_isFavorite);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 24,
                  color: _isFavorite ? Colors.red : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Add to Cart Button (BLACK THEME)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Added to cart!'),
                        ],
                      ),
                      backgroundColor: AppColors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2022),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Add to cart',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Buy Now Button (BLUE THEME)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Order placed successfully!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0052FF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Buy now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
