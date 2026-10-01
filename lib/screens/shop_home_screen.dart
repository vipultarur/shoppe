import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

// Data models
class ProductItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageAsset;
  final String category;
  final bool isNew;
  final bool isPopular;
  final bool isFlashSale;
  final List<String> variations;

  const ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageAsset,
    required this.category,
    this.isNew = false,
    this.isPopular = false,
    this.isFlashSale = false,
    this.variations = const [],
  });
}

class CategoryItem {
  final String name;
  final List<String> images; // 4 images for 2x2 grid
  final int count;

  const CategoryItem({
    required this.name,
    required this.images,
    this.count = 0,
  });
}

class ShopHomeScreen extends StatefulWidget {
  final UserModel user;

  const ShopHomeScreen({super.key, required this.user});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _flashSaleTimer;
  Duration _flashSaleDuration = const Duration(hours: 2);

  // Banner images from assets
  final List<String> _bannerImages = const [
    'assets/images/banner/1.png',
    'assets/images/banner/2.png',
    'assets/images/banner/3.png',
    'assets/images/banner/4.png',
  ];

  // Categories data with 4 images each for 2x2 grid
  final List<CategoryItem> _categories = const [
    CategoryItem(
      name: 'Clothing',
      count: 109,
      images: [
        'assets/images/categories/g11.png',
        'assets/images/categories/g12.png',
        'assets/images/categories/g13.png',
        'assets/images/categories/g14.png',
      ],
    ),
    CategoryItem(
      name: 'Shoes',
      count: 530,
      images: [
        'assets/images/categories/g21.png',
        'assets/images/categories/g22.png',
        'assets/images/categories/g23.png',
        'assets/images/categories/g24.png',
      ],
    ),
    CategoryItem(
      name: 'Bags',
      count: 87,
      images: [
        'assets/images/categories/Placeholder_01-6.png',
        'assets/images/categories/Placeholder_01-5.png',
        'assets/images/categories/Placeholder_01-4.png',
        'assets/images/categories/Placeholder_01-3.jpg',
      ],
    ),
    CategoryItem(
      name: 'Lingerie',
      count: 218,
      images: [
        'assets/images/categories/g31.png',
        'assets/images/categories/g32.png',
        'assets/images/categories/g33.png',
        'assets/images/categories/g34.jpg',
      ],
    ),
    CategoryItem(
      name: 'Watch',
      count: 218,
      images: [
        'assets/images/categories/g41.png',
        'assets/images/categories/g42.png',
        'assets/images/categories/g43.png',
        'assets/images/categories/g44.jpg',
      ],
    ),
    CategoryItem(
      name: 'Hoodies',
      count: 218,
      images: [
        'assets/images/categories/Placeholder_01-2.jpg',
        'assets/images/categories/Placeholder_01-4.jpg',
        'assets/images/categories/Placeholder_01-3.jpg',
        'assets/images/categories/Placeholder_01-5.jpg',
      ],
    ),
  ];

  // New Items
  final List<ProductItem> _newItems = const [
    ProductItem(
      id: 'n1',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.',
      price: 17.00,
      imageAsset: 'assets/images/categories/Placeholder_01-6.jpg',
      category: 'Clothing',
      isNew: true,
    ),
    ProductItem(
      id: 'n2',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: 33.00,
      imageAsset: 'assets/images/categories/Placeholder_01-7.jpg',
      category: 'Shoes',
      isNew: true,
    ),
    ProductItem(
      id: 'n3',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: 21.00,
      imageAsset: 'assets/images/categories/Placeholder_01-8.jpg',
      category: 'Clothing',
      isNew: true,
    ),
  ];


  // Just For You
  final List<ProductItem> _justForYou = const [
    ProductItem(
      id: 'j1',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.',
      price: 17.00,
      imageAsset: 'assets/images/flesh sale/Placeholder_01-4.jpg',
      category: 'Clothing',
      variations: ['Pink', 'M'],
    ),
    ProductItem(
      id: 'j2',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: 17.00,
      imageAsset: 'assets/images/flesh sale/Placeholder_01-5.jpg',
      category: 'Clothing',
      variations: ['Blue', 'L'],
    ),
    ProductItem(
      id: 'j3',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: 17.00,
      imageAsset: 'assets/images/categories/Placeholder_01-6.jpg',
      category: 'Clothing',
      variations: ['Red', 'S'],
    ),
    ProductItem(
      id: 'j4',
      name: 'Lorem ipsum dolor sit amet consectetur.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: 17.00,
      imageAsset: 'assets/images/categories/Placeholder_01-7.jpg',
      category: 'Shoes',
      variations: ['White', 'M'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _startFlashSaleTimer();
  }

  void _startFlashSaleTimer() {
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_flashSaleDuration.inSeconds > 0) {
        setState(() {
          _flashSaleDuration = _flashSaleDuration - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % _bannerImages.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _flashSaleTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _navigateToProduct(ProductItem product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Shop title + Search + Filter icon
              _buildTopBar(),
              const SizedBox(height: 16),

              // Big Sale Banner Carousel
              _buildBannerCarousel(),
              const SizedBox(height: 24),

              // Categories Section
              _buildSectionHeader('Categories', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildCategoriesGrid(),
              const SizedBox(height: 24),

              // Top Products
              _buildTopProductsSection(),
              const SizedBox(height: 24),

              // New Items Section
              _buildSectionHeader('New Items', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildNewItemsList(),
              const SizedBox(height: 24),

              // Flash Sale Section
              _buildFlashSaleSection(),
              const SizedBox(height: 24),

              // Most Popular Section
              _buildSectionHeader('Most Popular', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildPopularList(),
              const SizedBox(height: 24),

              // Just For You Section
              _buildSectionHeader('Just For You', showHeart: true),
              const SizedBox(height: 12),
              _buildJustForYouGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Shop',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.only(left: 20, right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/navicons/camera Icon.svg',
                      width: 24,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BANNER CAROUSEL ──────────────────────────────────────
  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() => _currentBannerPage = index);
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index ? AppColors.primary : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, bool showHeart = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (showHeart) ...[
                const SizedBox(width: 6),
                const Icon(Icons.favorite, color: Colors.red, size: 18),
              ],
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0052FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── CATEGORIES GRID (2-col, each card has 2x2 thumbnails) ──
  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 2×2 image mosaic with compact padding
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: _buildCategoryMosaic(cat.images),
                    ),
                  ),
                  // Name + count row with reduced padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EDFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cat.count}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a 2×2 mosaic of 4 rounded images for a category card with reduced inner spacing.
  Widget _buildCategoryMosaic(List<String> images) {
    return Column(
      children: [
        // Top row
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(images[0], fit: BoxFit.cover, height: double.infinity),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(images[1], fit: BoxFit.cover, height: double.infinity),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Bottom row
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(images[2], fit: BoxFit.cover, height: double.infinity),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(images[3], fit: BoxFit.cover, height: double.infinity),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── TOP PRODUCTS (horizontal circles with white border and shadow) ──
  Widget _buildTopProductsSection() {
    final images = [
      'assets/images/flesh sale/Placeholder_01-5.jpg',
      'assets/images/categories/Placeholder_01@2x-8.jpg',
      'assets/images/categories/Placeholder_01@2x-9.jpg',
      'assets/images/categories/Placeholder_01-4.jpg',
      'assets/images/categories/Placeholder_01-8.jpg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _navigateToProduct(ProductItem(
                    id: 't$index',
                    name: 'Top Product',
                    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                    price: 49.99,
                    imageAsset: images[index],
                    category: 'Top Products',
                  ));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                width: 73,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── NEW ITEMS (horizontal card list matching image) ──────────────────
  Widget _buildNewItemsList() {
    return SizedBox(
      height: 215,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _newItems.length,
        itemBuilder: (context, index) {
          final item = _newItems[index];
          final priceFormatted = '\$${item.price.toStringAsFixed(2).replaceAll('.', ',')}';
          return GestureDetector(
            onTap: () => _navigateToProduct(item),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.imageAsset,
                      width: 140,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatted,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── FLASH SALE SECTION (3-column grid matching design image) ─────────
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Widget _buildFlashSaleSection() {
    final hours = _twoDigits(_flashSaleDuration.inHours);
    final minutes = _twoDigits(_flashSaleDuration.inMinutes.remainder(60));
    final seconds = _twoDigits(_flashSaleDuration.inSeconds.remainder(60));

    final flashImages = [
      'assets/images/flesh sale/Placeholder_01.jpg',
      'assets/images/flesh sale/Placeholder_01-1.jpg',
      'assets/images/flesh sale/Placeholder_01-2.jpg',
      'assets/images/flesh sale/Placeholder_01-3.jpg',
      'assets/images/flesh sale/Placeholder_01-4.jpg',
      'assets/images/flesh sale/Placeholder_01-5.jpg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Flash Sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/navicons/clock.svg',
                colorFilter: const ColorFilter.mode(Color(0xFF0052FF), BlendMode.srcIn),
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              _buildTimerBox(hours),
              const SizedBox(width: 6),
              _buildTimerBox(minutes),
              const SizedBox(width: 6),
              _buildTimerBox(seconds),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: flashImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _navigateToProduct(ProductItem(
                    id: 'f$index',
                    name: 'Flash Sale Product',
                    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                    price: 29.99,
                    imageAsset: flashImages[index],
                    category: 'Flash Sale',
                    isFlashSale: true,
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.5),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          flashImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF81140), Color(0xFFFF5790)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              topLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: const Text(
                            '-20%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBox(String value) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ─── MOST POPULAR (matching screenshot layout) ─────────────────────
  Widget _buildPopularList() {
    final popularItems = [
      {
        'image': 'assets/images/flesh sale/Placeholder_01-1.jpg',
        'price': '1780',
        'tag': 'New',
      },
      {
        'image': 'assets/images/flesh sale/Placeholder_01.jpg',
        'price': '1780',
        'tag': 'Sale',
      },
      {
        'image': 'assets/images/categories/Placeholder_01-10.jpg',
        'price': '1780',
        'tag': 'Hot',
      },
      {
        'image': 'assets/images/flesh sale/Placeholder_01-4.jpg',
        'price': '1780',
        'tag': 'New',
      },
    ];

    return SizedBox(
      height: 172,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: popularItems.length,
            itemBuilder: (context, index) {
          final item = popularItems[index];
          return GestureDetector(
            onTap: () {
              _navigateToProduct(ProductItem(
                id: 'p$index',
                name: 'Popular Product',
                description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                price: double.tryParse(item['price']!) ?? 99.99,
                imageAsset: item['image']!,
                category: 'Popular',
                isPopular: true,
              ));
            },
            child: Container(
              width: 128,
              margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item['image']!,
                    width: 128,
                    height: 132,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        item['price']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 3),
            
                      const Spacer(),
                      Text(
                        item['tag']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  // ─── JUST FOR YOU GRID ─────────────────────────────────────
  Widget _buildJustForYouGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _justForYou.length,
        itemBuilder: (context, index) {
          final item = _justForYou[index];
          return GestureDetector(
            onTap: () => _navigateToProduct(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(item.imageAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
