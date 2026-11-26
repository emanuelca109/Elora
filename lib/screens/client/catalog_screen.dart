import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/product_model.dart';
import '../../data/database_helper.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../providers/controllers/product_controller.dart';
import '../../providers/controllers/cart_controller.dart';
import '../../widgets/product_image.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Carousel Controller & Timer
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _bannerSlides = [
    {
      'tag': 'PERFUMERÍA ÁRABE DE DUBÁI',
      'title': 'Khamrah &\nAsad Imperial\nOud & Ámbar',
      'button': 'Ver colección',
      'search': 'Khamrah',
      'image': 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?auto=format&fit=crop&w=800&q=80',
    },
    {
      'tag': 'ELIXIR REAL DE ORIENTE',
      'title': 'Bade\'e Al Oud\nJoyas Reales\nde Dubái',
      'button': 'Ver colección',
      'search': 'Oud',
      'image': 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
    },
    {
      'tag': 'ALTA PERFUMERÍA ORIENTAL',
      'title': 'Yara & Niche\nEsencias Árabes\nExclusivas',
      'button': 'Ver colección',
      'search': 'Yara',
      'image': 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prodProv = Provider.of<ProductProvider>(context, listen: false);
      prodProv.loadProducts();
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      if (authProv.isLoggedIn && authProv.currentUser != null) {
        prodProv.loadUserFavorites(authProv.currentUser!.email);
      }
    });

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % _bannerSlides.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openProductDetail(ProductModel product) {
    Navigator.of(context)
        .pushNamed(AppRoutes.productDetail, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // El administrador no puede ver productos ni navegar en la tienda pública
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.adminCatalog, (route) => false);
        }
      });
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.darkGold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // SIN FLECHA <- EN LA PÁGINA PRINCIPAL
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'Buscar perfume, marca, notas...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        ).setSearchQuery('');
                      });
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).setSearchQuery(val);
                },
                onChanged: (val) {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).setSearchQuery(val);
                },
              )
            : Row(
                children: [
                  // LOGO OFICIAL ELORA EN ORO DE LUJO
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC5A059)
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/elora_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, _) => Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ELORA',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          letterSpacing: 4.5,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.5,
                          color: Color(0xFF281E17),
                        ),
                      ),
                      Text(
                        'HAUTE PARFUMERIE',
                        style: TextStyle(
                          fontSize: 7.5,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A6721).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                size: 23,
                color: Color(0xFF281E17),
              ),
              tooltip: 'Buscar',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _currentIndex = 0;
                });
              },
            ),
          // LUXURY CART ICON WITH BADGE
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.cart);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14, left: 4),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC5A059)
                              .withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 21,
                      color: Color(0xFF281E17),
                    ),
                  ),
                  if (cartProvider.totalProductsCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cartProvider.totalProductsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildCurrentTab(authProvider),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppTheme.warmBorder.withValues(alpha: 0.8),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF281E17),
          unselectedItemColor: const Color(0xFFA1978C),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Mi cuenta',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab(AuthProvider authProvider) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCatalogTab();
      case 2:
        return _buildFavoritesTab(authProvider);
      case 3:
        return _buildProfileTab(authProvider);
      default:
        return _buildHomeTab();
    }
  }

  // -------------------------------------------------------------
  // TAB 0: INICIO (HOME FEED)
  // -------------------------------------------------------------
  Widget _buildHomeTab() {
    final productProvider = Provider.of<ProductProvider>(context);
    final isSearching = productProvider.searchQuery.trim().isNotEmpty;
    final displayedProducts = isSearching
        ? productProvider.searchResults
        : productProvider.allProducts;

    return RefreshIndicator(
      onRefresh: () => productProvider.loadProducts(),
      color: AppTheme.primaryGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSearching) ...[
              // INTERACTIVE & AUTO-MOVING CAROUSEL SLIDER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _bannerSlides.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentBannerPage = idx;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = _bannerSlides[index];

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF9F5EE),
                              Color(0xFFEDE4D5),
                              Color(0xFFFBF9F6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC5A059)
                                  .withValues(alpha: 0.16),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEADBBE)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              top: 0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(26),
                                  bottomRight: Radius.circular(26),
                                ),
                                child: Image.network(
                                  slide['image']!,
                                  fit: BoxFit.cover,
                                  width: 175,
                                  errorBuilder: (_, __, _) => const SizedBox(),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 22,
                              right: 155,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8A6721)
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          slide['tag']!,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: Color(0xFF6E4E11),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        slide['title']!,
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF322317),
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () {
                                          final term = slide['search'] ?? '';
                                          if (term.isNotEmpty) {
                                            productProvider.setCategory(
                                              'Todos',
                                            );
                                            productProvider.setSearchQuery(
                                              term,
                                            );
                                            _searchController.text = term;
                                            setState(() {
                                              _isSearching = true;
                                            });
                                          } else {
                                            productProvider.setCategory(
                                              'Todos',
                                            );
                                            setState(() {
                                              _currentIndex = 1;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4C3A2B),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                slide['button']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Carousel Dot Indicators
                            Positioned(
                              bottom: 10,
                              left: 22,
                              child: Row(
                                children: List.generate(_bannerSlides.length, (
                                  dotIdx,
                                ) {
                                  final isActive = dotIdx == _currentBannerPage;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 5),
                                    width: isActive ? 18 : 6,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFF8A6721)
                                          : const Color(0xFFC7B8A6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // QUICK CATEGORY CIRCLES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLuxuryCategoryCircle(
                      label: 'Mujer',
                      icon: Icons.female_rounded,
                      isSelected: productProvider.selectedCategory == 'Mujer',
                      onTap: () {
                        productProvider.setCategory('Mujer');
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                    _buildLuxuryCategoryCircle(
                      label: 'Hombre',
                      icon: Icons.male_rounded,
                      isSelected: productProvider.selectedCategory == 'Hombre',
                      onTap: () {
                        productProvider.setCategory('Hombre');
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                    _buildLuxuryCategoryCircle(
                      label: 'Unisex',
                      icon: Icons.all_inclusive_rounded,
                      isSelected: productProvider.selectedCategory == 'Unisex',
                      onTap: () {
                        productProvider.setCategory('Unisex');
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                    _buildLuxuryCategoryCircle(
                      label: 'Sets',
                      icon: Icons.card_giftcard_rounded,
                      isSelected: productProvider.selectedCategory == 'Sets',
                      onTap: () {
                        productProvider.setCategory('Sets');
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ], // Cierre de if (!isSearching)

            if (isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultados para "${productProvider.searchQuery.trim()}"',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF241B15),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${displayedProducts.length} perfume${displayedProducts.length == 1 ? '' : 's'} encontrado${displayedProducts.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A6721),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        });
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF8A6721),
                      ),
                      label: const Text(
                        'Limpiar',
                        style: TextStyle(color: Color(0xFF8A6721)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const SizedBox(height: 26),
              // SECTION HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Colección de Fragancias',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF241B15),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A6721).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${displayedProducts.length} fragancias',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF8A6721),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ALL PRODUCTS GRID / RESULTADOS DE BÚSQUEDA
            if (productProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              )
            else if (displayedProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFAF3E6),
                          border: Border.all(color: const Color(0xFFE2D4BC)),
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 46,
                          color: Color(0xFF8A6721),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSearching
                            ? 'No se encontraron perfumes para "${productProvider.searchQuery.trim()}"'
                            : 'No hay perfumes disponibles en el catálogo.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D221A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSearching
                            ? 'Prueba con otra marca (ej: Lattafa, Dior, Chanel) o notas aromáticas.'
                            : 'Vuelve a consultar pronto.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7368),
                        ),
                      ),
                      if (isSearching) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              productProvider.setSearchQuery('');
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3A2B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Ver todos los perfumes'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.61,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    return _buildLuxuryProductCard(product);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryCategoryCircle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4C3A2B)
                    : const Color(0xFFECE4D8),
                width: isSelected ? 1.8 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4C3A2B)
                    : const Color(0xFF2C2219),
                size: 25,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF261D16),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: CATEGORÍAS (CATÁLOGO COMPLETO)
  // -------------------------------------------------------------
  Widget _buildCatalogTab() {
    final productProvider = Provider.of<ProductProvider>(context);
    final allProducts = productProvider.filteredProducts;

    return Column(
      children: [
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: productProvider.availableCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = productProvider.availableCategories[index];
              final isSelected = productProvider.selectedCategory == cat;
              return ChoiceChip(
                avatar: Icon(
                  _getCategoryIcon(cat),
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF6E4E11),
                ),
                label: Text(cat),
                selected: isSelected,
                selectedColor: const Color(0xFF4A3728),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF281E17),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4A3728)
                      : const Color(0xFFECE3D4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (val) {
                  if (val) {
                    productProvider.setCategory(cat);
                  }
                },
              );
            },
          ),
        ),
        Expanded(
          child: productProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                )
              : allProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 54,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No se encontraron perfumes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(),
                  color: AppTheme.primaryGold,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.61,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      final product = allProducts[index];
                      return _buildLuxuryProductCard(product);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mujer':
        return Icons.female_rounded;
      case 'hombre':
        return Icons.male_rounded;
      case 'unisex':
        return Icons.all_inclusive_rounded;
      case 'sets':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  // -------------------------------------------------------------
  // LUXURY PRODUCT CARD (SIN CORAZÓN EN LA PANTALLA PRINCIPAL)
  // ICONO DE AGREGAR DIRECTO AL CARRITO (SIN TEXTO 'Añadir')
  // -------------------------------------------------------------
  Widget _buildLuxuryProductCard(ProductModel product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => _openProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE8DD), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image (LIMPIO, SIN CORAZÓN EN LA PANTALLA PRINCIPAL)
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFFAF8F5),
                      child: product.images.length > 1
                          ? Stack(
                              children: [
                                PageView.builder(
                                  itemCount: product.images.length,
                                  itemBuilder: (context, idx) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: ProductImage(
                                        imageUrl: product.images[idx],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 6,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: List.generate(
                                      product.images.length,
                                      (i) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFC5A059)
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: ProductImage(
                                imageUrl: product.primaryImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  if (product.isLowStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Últimas ${product.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details: Name, Brand, Price, Add Icon Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Color(0xFF221A15),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF857B71),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppTheme.formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.5,
                            color: Color(0xFF221A15),
                          ),
                        ),
                      ),
                      // BOTÓN CON ICONO QUE SIMBOLIZA AÑADIR (SIN TEXTO 'Añadir')
                      GestureDetector(
                        onTap: () {
                          final added = cartProvider.addToCart(product);
                          if (added) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFFC5A059),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '¡"${product.name}" añadido al carrito!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                duration:
                                    const Duration(milliseconds: 1800),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: const Color(0xFF38291F),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'No hay más stock disponible',
                                ),
                                duration:
                                    const Duration(milliseconds: 1800),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: AppTheme.dangerRed,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C3A2B), Color(0xFF2E2218)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4C3A2B)
                                    .withValues(alpha: 0.28),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: FAVORITOS
  // -------------------------------------------------------------
  Widget _buildFavoritesTab(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 46,
                  color: Color(0xFF8A6721),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tus Favoritos Personalizados',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF281E17),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión con tu cuenta para guardar y sincronizar tus fragancias favoritas exclusivas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF7A6F64),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Iniciar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C3A2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final productProvider = Provider.of<ProductProvider>(context);
    final favProducts = productProvider.favoriteProducts;

    if (favProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline_rounded,
              size: 60,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 12),
            Text(
              'Aún no tienes fragancias favoritas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Abre el detalle de cualquier perfume y toca el corazón para guardarlo aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: favProducts.length,
      itemBuilder: (context, index) {
        return _buildLuxuryProductCard(favProducts[index]);
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: MI CUENTA / PERFIL
  // -------------------------------------------------------------
  Widget _buildProfileTab(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGold.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 44,
                  color: AppTheme.darkGold,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Bienvenido a Elora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión para gestionar tus pedidos y comprar fragancias exclusivas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C3A2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    final user = authProvider.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 14,
                        color: AppTheme.darkGold,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'CLIENTE EXCLUSIVO ELORA',
                        style: TextStyle(
                          color: AppTheme.darkGold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 1. Mis pedidos (Esencial para el cliente)
          _buildProfileMenuItem(
            icon: Icons.receipt_long_rounded,
            title: 'Mis pedidos',
            subtitle: 'Rastreo y estado en tiempo real de tus compras',
            onTap: () => _showMyOrdersDialog(user.email),
          ),

          // 2. Mis direcciones de entrega (Cambiar o agregar nueva)
          _buildProfileMenuItem(
            icon: Icons.pin_drop_rounded,
            title: 'Mis direcciones de entrega',
            subtitle: 'Gestionar, cambiar o agregar nueva dirección',
            onTap: () => _showAddressesModal(user.email),
          ),

          // 3. Cambiar contraseña
          _buildProfileMenuItem(
            icon: Icons.lock_reset_rounded,
            title: 'Cambiar contraseña',
            subtitle: 'Actualizar la clave de seguridad de tu cuenta',
            onTap: () => _showChangePasswordDialog(user.email),
          ),

          const SizedBox(height: 12),

          // 4. Cerrar sesión
          _buildProfileMenuItem(
            icon: Icons.logout_rounded,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta de forma segura',
            textColor: AppTheme.dangerRed,
            iconColor: AppTheme.dangerRed,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar tu sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRed,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).clearUserFavorites();
                authProvider.logout();
                setState(() {
                  _currentIndex = 0;
                  _isSearching = false;
                  _searchController.clear();
                });
                Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).setSearchQuery('');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Sesión cerrada. Mostrando catálogo principal',
                    ),
                    duration: const Duration(milliseconds: 1800),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // DIÁLOGO PARA CAMBIAR CONTRASEÑA DIRECTAMENTE DESDE LA CUENTA
  void _showChangePasswordDialog(String email) {
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePass = true;
    bool obscureConfirm = true;
    String? errorText;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              bottom: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAF3E6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 22,
                            color: Color(0xFF8A6721),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Actualizar Contraseña',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF281E17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Actualiza tu clave de acceso para $email.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF8A7E73)),
                    ),
                    const SizedBox(height: 20),
                    if (errorText != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          errorText!,
                          style: const TextStyle(
                            color: AppTheme.dangerRed,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: passController,
                      obscureText: obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setSheetState(() => obscurePass = !obscurePass);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Nueva Contraseña',
                        hintText: 'Repite tu nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setSheetState(
                              () => obscureConfirm = !obscureConfirm,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final newP = passController.text;
                              final confP = confirmController.text;

                              if (newP.length < 6) {
                                setSheetState(() {
                                  errorText =
                                      'La contraseña debe tener al menos 6 caracteres';
                                });
                                return;
                              }
                              if (newP != confP) {
                                setSheetState(() {
                                  errorText = 'Las contraseñas no coinciden';
                                });
                                return;
                              }

                              setSheetState(() {
                                isLoading = true;
                                errorText = null;
                              });

                              final ok = await DatabaseHelper.instance
                                  .updateUserPassword(email, newP);

                              if (!context.mounted) return;

                              if (ok) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      '¡Contraseña actualizada con éxito!',
                                    ),
                                    backgroundColor: AppTheme.successGreen,
                                    duration:
                                        const Duration(milliseconds: 2000),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                );
                              } else {
                                setSheetState(() {
                                  isLoading = false;
                                  errorText =
                                      'No se pudo actualizar la contraseña';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C3A2B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Nueva Contraseña',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warmBorder, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.darkGold).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppTheme.darkGold, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: textColor ?? AppTheme.textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textLight,
          size: 22,
        ),
        onTap: onTap,
      ),
    );
  }

  // --- MODAL DE GESTIÓN DE DIRECCIONES (VER, CAMBIAR, AGREGAR) ---
  void _showAddressesModal(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getAddresses(email),
              builder: (context, snapshot) {
                final addresses = snapshot.data ?? [];
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return SafeArea(
                  bottom: true,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      12 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF3E6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFC5A059),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.pin_drop_rounded,
                                color: Color(0xFF8A6721),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mis Direcciones de Entrega',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF281E17),
                                    ),
                                  ),
                                  Text(
                                    'Tus domicilios exclusivos para entrega de fragancias',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 22),
                              onPressed: () => Navigator.of(modalCtx).pop(),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (isLoading)
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryGold,
                              ),
                            ),
                          )
                        else if (addresses.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFAF6EE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_off_outlined,
                                      size: 46,
                                      color: Color(0xFFC5A059),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No tienes direcciones guardadas',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF281E17),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Añade una dirección para recibir tus perfumes favoritos.',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              itemCount: addresses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                final addr = addresses[idx];
                                final isDefault =
                                    (addr['is_default'] ?? 0) == 1;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDefault
                                        ? const Color(0xFFFAF6EE)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isDefault
                                          ? const Color(0xFFC5A059)
                                          : const Color(0xFFECE4D8),
                                      width: isDefault ? 1.6 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDefault
                                            ? const Color(0xFFC5A059)
                                                  .withValues(alpha: 0.12)
                                            : Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isDefault
                                                ? Icons.star_rounded
                                                : Icons.location_on_rounded,
                                            color: isDefault
                                                ? const Color(0xFFB88E3E)
                                                : const Color(0xFF8A7E73),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              addr['title'] ?? 'Dirección',
                                              style: const TextStyle(
                                                fontFamily: 'Georgia',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.5,
                                                color: Color(0xFF281E17),
                                              ),
                                            ),
                                          ),
                                          if (isDefault)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3.5,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFC5A059),
                                                    Color(0xFF8A6721),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF8A6721,
                                                    ).withValues(alpha: 0.3),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_rounded,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'Principal',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline_rounded,
                                            size: 15,
                                            color: Color(0xFF8A6721),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${addr['recipient_name']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF281E17),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.phone_outlined,
                                            size: 14,
                                            color: Color(0xFF8A6721),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${addr['phone']}',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFF6B5E51),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Icon(
                                              Icons.home_outlined,
                                              size: 15,
                                              color: Color(0xFF8A6721),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${addr['address_line']}, ${addr['city']}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF4C3A2B),
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(height: 1),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: [
                                          if (!isDefault)
                                            TextButton.icon(
                                              onPressed: () async {
                                                await DatabaseHelper.instance
                                                    .setDefaultAddress(
                                                      addr['id'] as int,
                                                      email,
                                                    );
                                                setModalState(() {});
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                size: 16,
                                                color: Color(0xFF8A6721),
                                              ),
                                              label: const Text(
                                                'Hacer principal',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF8A6721),
                                                ),
                                              ),
                                            ),
                                          TextButton.icon(
                                            onPressed: () async {
                                              await _showAddressFormDialog(
                                                email: email,
                                                existingAddress: addr,
                                              );
                                              setModalState(() {});
                                            },
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: Color(0xFF4C3A2B),
                                            ),
                                            label: const Text(
                                              'Editar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4C3A2B),
                                              ),
                                            ),
                                          ),
                                          if (addresses.length > 1)
                                            TextButton.icon(
                                              onPressed: () async {
                                                final del = await showDialog<bool>(
                                                  context: context,
                                                  builder: (dCtx) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                          'Eliminar dirección',
                                                        ),
                                                        content: const Text(
                                                          '¿Deseas eliminar esta dirección de entrega?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dCtx,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancelar',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dCtx,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Eliminar',
                                                              style: TextStyle(
                                                                color: AppTheme
                                                                    .dangerRed,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                                if (del == true) {
                                                  await DatabaseHelper.instance
                                                      .deleteAddress(
                                                        addr['id'] as int,
                                                      );
                                                  setModalState(() {});
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 16,
                                                color: AppTheme.dangerRed,
                                              ),
                                              label: const Text(
                                                'Eliminar',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.dangerRed,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),

                        // BOTÓN ELEVADO SEGURO POR ENCIMA DE LA BARRA DE NAVEGACIÓN ANDROID
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38291F), Color(0xFF1E140D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFFC5A059)
                                  .withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E140D)
                                    .withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _showAddressFormDialog(email: email);
                              setModalState(() {});
                            },
                            icon: const Icon(
                              Icons.add_location_alt_rounded,
                              size: 19,
                              color: Color(0xFFEADBBE),
                            ),
                            label: const Text(
                              'Agregar nueva dirección',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                letterSpacing: 0.3,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- DIÁLOGO PARA CREAR O EDITAR DIRECCIÓN ---
  Future<void> _showAddressFormDialog({
    required String email,
    Map<String, dynamic>? existingAddress,
  }) async {
    final isEditing = existingAddress != null;
    final titleCtrl = TextEditingController(
      text: existingAddress?['title'] ?? 'Casa',
    );
    final nameCtrl = TextEditingController(
      text: existingAddress?['recipient_name'] ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: existingAddress?['phone'] ?? '',
    );
    final lineCtrl = TextEditingController(
      text: existingAddress?['address_line'] ?? '',
    );
    final cityCtrl = TextEditingController(
      text: existingAddress?['city'] ?? 'Medellín, Antioquia',
    );
    bool isDefault = (existingAddress?['is_default'] ?? 0) == 1;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_location_alt : Icons.add_location_alt,
                  color: AppTheme.darkGold,
                ),
                const SizedBox(width: 8),
                Text(
                  isEditing ? 'Editar Dirección' : 'Nueva Dirección',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alias / Lugar (ej: Casa, Trabajo, Apto)',
                        prefixIcon: Icon(Icons.bookmark_outline_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa un alias'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de quien recibe',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa el nombre del receptor'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono / Celular',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa un teléfono'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lineCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (Calle, Carrera, Apto...)',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa la dirección exacta'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad y Departamento',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa la ciudad'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Establecer como dirección principal',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: isDefault,
                      activeTrackColor: AppTheme.darkGold.withValues(
                        alpha: 0.5,
                      ),
                      activeThumbColor: AppTheme.darkGold,
                      onChanged: (val) => setDialogState(() => isDefault = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(dCtx).pop();

                  final addressData = {
                    'user_email': email,
                    'title': titleCtrl.text.trim(),
                    'recipient_name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'address_line': lineCtrl.text.trim(),
                    'city': cityCtrl.text.trim(),
                    'is_default': isDefault ? 1 : 0,
                  };

                  if (isEditing) {
                    await DatabaseHelper.instance.updateAddress(
                      existingAddress['id'] as int,
                      addressData,
                    );
                  } else {
                    await DatabaseHelper.instance.insertAddress(addressData);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Dirección actualizada con éxito'
                              : '¡Nueva dirección agregada exitosamente!',
                        ),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C3A2B),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Agregar Dirección',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMyOrdersDialog(String email) async {
    final orders = await DatabaseHelper.instance.getOrdersByEmail(email);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          bottom: true,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3E6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC5A059),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFF8A6721),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis Pedidos',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF281E17),
                            ),
                          ),
                          Text(
                            'Historial y seguimiento exclusivo de tus órdenes',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFAF6EE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 46,
                                  color: Color(0xFFC5A059),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Aún no tienes pedidos registrados',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF281E17),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Explora nuestro catálogo exclusivo y añade tus fragancias favoritas.',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, idx) {
                            final ord = orders[idx];
                            final isDelivered = ord.status == 'Entregado';
                            final isShipping = ord.status == 'En camino';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCFAF7),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDelivered
                                      ? AppTheme.successGreen.withValues(
                                          alpha: 0.35,
                                        )
                                      : const Color(0xFFEDE4D6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.shopping_bag_outlined,
                                            size: 16,
                                            color: Color(0xFF8A6721),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '#ELO-00${ord.id}',
                                            style: const TextStyle(
                                              fontFamily: 'Georgia',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.5,
                                              color: Color(0xFF281E17),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDelivered
                                              ? const Color(0xFFE8F5E9)
                                              : isShipping
                                              ? const Color(0xFFE3F2FD)
                                              : const Color(0xFFFFF8E1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isDelivered
                                                ? AppTheme.successGreen
                                                      .withValues(alpha: 0.3)
                                                : isShipping
                                                ? Colors.blue.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : const Color(0xFFC5A059)
                                                      .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isDelivered
                                                  ? Icons.check_circle_rounded
                                                  : isShipping
                                                  ? Icons.local_shipping_rounded
                                                  : Icons.inventory_2_rounded,
                                              size: 13,
                                              color: isDelivered
                                                  ? AppTheme.successGreen
                                                  : isShipping
                                                  ? const Color(0xFF1565C0)
                                                  : const Color(0xFF8A6721),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              ord.status,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: isDelivered
                                                    ? AppTheme.successGreen
                                                    : isShipping
                                                    ? const Color(0xFF1565C0)
                                                    : const Color(0xFF8A6721),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Color(0xFF8A7E73),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ord.createdAt,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF8A7E73),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.pin_drop_outlined,
                                          size: 13,
                                          color: Color(0xFF8A7E73),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Entrega: ${ord.deliveryAddress}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF4C3A2B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  ...ord.items.map(
                                    (it) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3ECE0),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${it.quantity}x',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF8A6721),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              it.productName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF281E17),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            it.presentation,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF8A7E73),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total de la orden:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4C3A2B),
                                        ),
                                      ),
                                      Text(
                                        AppTheme.formatPrice(ord.total),
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8A6721),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
