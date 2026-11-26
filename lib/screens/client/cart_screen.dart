import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/controllers/cart_controller.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../providers/controllers/product_controller.dart';
import '../../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.adminCatalog,
            (route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 19, color: Color(0xFF281E17)),
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
                Icons.shopping_cart_outlined,
                size: 20,
                color: Color(0xFFC5A059),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mi Carrito',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF281E17),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!cartProvider.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.dangerRed),
              tooltip: 'Vaciar carrito',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Vaciar carrito?'),
                    content: const Text(
                      'Se eliminarán todos los perfumes de tu compra actual.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Vaciar',
                          style: TextStyle(color: AppTheme.dangerRed),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartProvider.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 42,
                        color: AppTheme.darkGold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explora nuestra exclusiva colección de fragancias y agrega tus favoritas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGold,
                      ),
                      child: const Text('Explorar fragancias'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // List of items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items.values.elementAt(index);
                      // Match product to check current max stock
                      final matchingProduct = productProvider.allProducts
                          .where((p) => p.id == item.productId)
                          .firstOrNull;
                      final maxStock = matchingProduct?.stock ?? 99;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.warmBorder, width: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGold.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 68,
                                height: 68,
                                color: AppTheme.backgroundLight,
                                child: ProductImage(
                                  imageUrl: matchingProduct?.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.presentation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppTheme.formatPrice(item.unitPrice),
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls (- / +) and delete
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cartProvider.decreaseQuantity(item.productId);
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppTheme.warmBorder),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(Icons.remove,
                                            size: 14, color: AppTheme.textDark),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final increased = cartProvider
                                            .increaseQuantity(
                                                item.productId, maxStock);
                                        if (!increased) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Máximo de stock alcanzado ($maxStock unidades)'),
                                              duration:
                                                  const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppTheme.warmBorder),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(Icons.add,
                                            size: 14, color: AppTheme.textDark),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    cartProvider.removeProduct(item.productId);
                                  },
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: AppTheme.dangerRed,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
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

                // Order Summary and Checkout Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              AppTheme.formatPrice(cartProvider.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Envío',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              'Gratis',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              AppTheme.formatPrice(cartProvider.totalAmount),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.darkGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Finalizar compra button
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.darkGold.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // CHECK AUTH STATUS
                              if (!authProvider.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor inicia sesión para completar tu compra.',
                                    ),
                                    backgroundColor: AppTheme.darkGold,
                                  ),
                                );
                                Navigator.of(context).pushNamed(
                                  AppRoutes.login,
                                  arguments: AppRoutes.checkout,
                                );
                              } else {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.checkout);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Finalizar compra',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
    );
  }
}
