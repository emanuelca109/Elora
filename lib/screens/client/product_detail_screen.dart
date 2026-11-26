import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/product_model.dart';
import '../../providers/controllers/cart_controller.dart';
import '../../providers/controllers/product_controller.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  late String _selectedPresentation;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedPresentation = widget.product.defaultPresentation;
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.adminCatalog, (route) => false);
        }
      });
      return const SizedBox.shrink();
    }

    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final product = widget.product;
    final inCartCount = cartProvider.items[product.id]?.quantity ?? 0;
    final availableStock = product.stock - inCartCount;
    final isFav = productProvider.isFavorite(product.id);

    // Recomendaciones: otros productos de dos en dos hacia abajo
    final recommendedProducts = productProvider.allProducts
        .where((p) => p.id != product.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Color(0xFF281E17),
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Regresar',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/elora_logo.png',
              height: 24,
              errorBuilder: (_, _, _) => const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: Color(0xFFC5A059),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ELORA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: Color(0xFF281E17),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // BOTÓN CARRITO EN LA PARTE SUPERIOR CON CONTADOR
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.cart);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 4),
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
                      size: 20,
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
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE SECTION PANTALLA COMPLETA
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFECE3D4), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 320,
                      width: double.infinity,
                      color: const Color(0xFFF9F7F4),
                      child: product.images.length > 1
                          ? PageView.builder(
                              controller: _imagePageController,
                              itemCount: product.images.length,
                              onPageChanged: (i) {
                                setState(() {
                                  _currentImageIndex = i;
                                });
                              },
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
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: ProductImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),

                  // Indicadores de puntos si hay más de 1 imagen
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (idx) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == idx ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == idx
                                  ? const Color(0xFFC5A059)
                                  : Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // BADGES SUPERIORES IZQUIERDA (ORIGEN Y CATEGORÍA)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2D6C5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Color(0xFF8A6721),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.origin.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF4C3A2B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C3A2B).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTÓN ME ENCANTA DIRECTAMENTE EN LA FOTO
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        if (!auth.isLoggedIn) {
                          productProvider.setPendingFavorite(product.id);
                          final shouldLogin = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.favorite_rounded,
                                      color: AppTheme.dangerRed, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Guardar en Favoritos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Inicia sesión para guardar tus fragancias favoritas en tu cuenta y verlas desde cualquier lugar.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4C3A2B),
                                  height: 1.4,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    productProvider.clearPendingFavorite();
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: const Text('Cancelar',
                                      style: TextStyle(color: Color(0xFF8A7E73))),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4C3A2B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Iniciar Sesión'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogin == true && context.mounted) {
                            await Navigator.of(context).pushNamed(AppRoutes.login);
                            if (context.mounted) {
                              final authNow = Provider.of<AuthProvider>(context, listen: false);
                              if (authNow.isLoggedIn && authNow.currentUser != null) {
                                await productProvider.loadUserFavorites(authNow.currentUser!.email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.favorite_rounded,
                                              color: AppTheme.dangerRed, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '¡"${product.name}" guardado en tus favoritos!',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: const Color(0xFF38291F),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                          return;
                        }

                        final userEmail = auth.currentUser?.email;
                        await productProvider.toggleFavorite(product.id, userEmail: userEmail);
                        final nowFav = productProvider.isFavorite(product.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    nowFav ? Icons.favorite_rounded : Icons.heart_broken_rounded,
                                    color: nowFav ? AppTheme.dangerRed : Colors.white70,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      nowFav
                                          ? '¡"${product.name}" añadido a tus favoritos!'
                                          : 'Eliminado de tus favoritos',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  nowFav ? const Color(0xFF38291F) : AppTheme.textMuted,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.94),
                          border: Border.all(
                            color: isFav
                                ? AppTheme.dangerRed.withValues(alpha: 0.35)
                                : const Color(0xFFE2D6C5),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 22,
                          color: isFav
                              ? AppTheme.dangerRed
                              : const Color(0xFF4C3A2B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFORMACIÓN DEL PRODUCTO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.variety.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: Color(0xFF8A6721),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF241B15),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PRECIO
                  Text(
                    AppTheme.formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF281E17),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // DESCRIPCIÓN & NOTAS OLFATIVAS
                  const Text(
                    'Descripción y notas olfativas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF281E17),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6156),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // PRESENTACIÓN DISPONIBLE
                  const Text(
                    'Selecciona la presentación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF281E17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: product.presentations.map((size) {
                      final isSelected = _selectedPresentation == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        selectedColor: const Color(0xFF4C3A2B),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF281E17),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4C3A2B)
                              : const Color(0xFFECE3D4),
                          width: isSelected ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedPresentation = size;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // STOCK & SELECTOR DE CANTIDAD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.stock > 0
                                  ? 'Stock disponible'
                                  : 'Agotado temporalmente',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: product.stock > 0
                                    ? const Color(0xFF2E7D32)
                                    : AppTheme.dangerRed,
                              ),
                            ),
                            if (product.stock > 0)
                              Text(
                                '${product.stock} unidades en inventario',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF8A7E73),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (availableStock > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE2D6C5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 17),
                                color: const Color(0xFF281E17),
                                onPressed: _selectedQuantity > 1
                                    ? () {
                                        setState(() {
                                          _selectedQuantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  '$_selectedQuantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF281E17),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 17),
                                color: const Color(0xFF281E17),
                                onPressed: _selectedQuantity < availableStock
                                    ? () {
                                        setState(() {
                                          _selectedQuantity++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // BOTÓN AGREGAR AL CARRITO
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: availableStock <= 0
                          ? null
                          : () {
                              final success = cartProvider.addToCart(
                                product.copyWith(
                                  presentation: _selectedPresentation,
                                ),
                                quantity: _selectedQuantity,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            color: Color(0xFFC5A059), size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '¡"${product.name}" agregado al carrito!',
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
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'No hay más stock disponible',
                                    ),
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
                                    backgroundColor: AppTheme.dangerRed,
                                  ),
                                );
                              }
                            },
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 21,
                        color: Colors.white,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          availableStock <= 0
                              ? 'Agotado'
                              : 'Agregar al carrito • ${AppTheme.formatPrice(product.price * _selectedQuantity)}',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C3A2B),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // SEPARADOR ELEGANTE
                  const Divider(color: Color(0xFFEFE8DD), height: 1),
                  const SizedBox(height: 24),

                  // SECCIÓN: TAMBIÉN TE PODRÍA ENCANTAR / RECOMENDADOS
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'También te podría encantar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF241B15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A6721).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Recomendados',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8A6721),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fragancias seleccionadas con notas afines',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF8A7E73)),
                  ),

                  const SizedBox(height: 16),

                  // RECOMENDACIONES DE DOS EN DOS HACIA ABAJO
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: recommendedProducts.length,
                    itemBuilder: (context, index) {
                      final recProduct = recommendedProducts[index];
                      return _buildRecommendedCard(
                        context,
                        recProduct,
                        cartProvider,
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE RECOMENDACIÓN (DE DOS EN DOS)
  Widget _buildRecommendedCard(
    BuildContext context,
    ProductModel item,
    CartProvider cartProvider,
  ) {
    return GestureDetector(
      onTap: () {
        // Navega a pantalla completa para el perfume recomendado
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE8DD), width: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFFAF8F5),
                  child: ProductImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.origin.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8276),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221A15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppTheme.formatPrice(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4C3A2B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // ICONO PARA AÑADIR DIRECTO AL CARRITO
                      GestureDetector(
                        onTap: () {
                          final added = cartProvider.addToCart(item);
                          if (added) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡"${item.name}" añadido al carrito!'),
                                duration: const Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: const Color(0xFF38291F),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C3A2B), Color(0xFF2E2218)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4C3A2B)
                                    .withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 14,
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
}
