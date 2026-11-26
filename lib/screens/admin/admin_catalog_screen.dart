import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/product_model.dart';
import '../../providers/controllers/product_controller.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../widgets/product_image.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfume'),
        content: Text(
          '¿Estás seguro de que deseas eliminar permanentemente "${product.name}" del catálogo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final productProvider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );
              final success = await productProvider.deleteProduct(product.id!);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Perfume eliminado correctamente.'
                        : 'Error al eliminar perfume.',
                  ),
                  backgroundColor: success
                      ? AppTheme.successGreen
                      : AppTheme.dangerRed,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppTheme.dangerRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewCategoryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.category_rounded, color: AppTheme.darkGold),
            SizedBox(width: 8),
            Text(
              'Nueva Categoría',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crea una categoría exclusiva para organizar tu catálogo de fragancias.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nombre de la categoría',
                hintText: 'Ej: Oriental, Árabe, Gourmet, Edición Especial...',
                prefixIcon: const Icon(Icons.label_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              final productProvider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );
              final success = await productProvider.addCategory(name);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '¡Categoría "$name" creada exitosamente!'
                        : (productProvider.errorMessage ??
                              'Error al crear categoría'),
                  ),
                  backgroundColor: success
                      ? AppTheme.successGreen
                      : AppTheme.dangerRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C3A2B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear Categoría'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(String currentName) {
    final textController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppTheme.darkGold),
            SizedBox(width: 8),
            Text(
              'Cambiar Nombre',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifica el nombre de "$currentName". Todos los perfumes de esta categoría se actualizarán automáticamente.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nuevo nombre',
                prefixIcon: const Icon(Icons.label_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isEmpty || newName == currentName) {
                Navigator.of(ctx).pop();
                return;
              }
              Navigator.of(ctx).pop();
              final productProvider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );
              final success = await productProvider.renameCategory(
                currentName,
                newName,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '¡Categoría renombrada a "$newName" exitosamente!'
                        : (productProvider.errorMessage ??
                              'Error al renombrar categoría'),
                  ),
                  backgroundColor: success
                      ? AppTheme.successGreen
                      : AppTheme.dangerRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C3A2B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar Nombre'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(String categoryName) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final count = productProvider.getProductCountForCategory(categoryName);

    // Si la categoría tiene productos, no permitir eliminarla
    if (count > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.block_rounded, color: AppTheme.dangerRed, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No se puede eliminar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La categoría "$categoryName" tiene $count perfume(s) registrado(s).',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No es posible eliminar una categoría que contiene perfumes. Primero debes reasignar estos perfumes a otra categoría o eliminarlos del catálogo.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C3A2B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Eliminar Categoría',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la categoría vacía "$categoryName"?',
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await productProvider.deleteCategory(
                categoryName,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Categoría "$categoryName" eliminada.'
                        : (productProvider.errorMessage ??
                              'Error al eliminar la categoría.'),
                  ),
                  backgroundColor: success
                      ? AppTheme.successGreen
                      : AppTheme.dangerRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int catPage = 1;
        const int catPageSize = 10;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                final categories = productProvider.availableCategories
                    .where((c) => c.toLowerCase() != 'todos')
                    .toList();
                final totalCatPages =
                    (categories.length / catPageSize).ceil().clamp(1, 99999);
                final currentCatPage = catPage.clamp(1, totalCatPages);
                final pagedCategories = categories
                    .skip((currentCatPage - 1) * catPageSize)
                    .take(catPageSize)
                    .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: AppTheme.darkGold,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Gestionar Categorías',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                        const Text(
                          'Cambia el nombre o elimina categorías de tu tienda de fragancias.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        Expanded(
                          child: categories.isEmpty
                              ? const Center(
                                  child: Text('No hay categorías registradas.'),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  itemCount: pagedCategories.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final cat = pagedCategories[index];
                                    final count = productProvider
                                        .getProductCountForCategory(cat);

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFFF3ECE0,
                                        ),
                                        child: Text(
                                          cat.isNotEmpty
                                              ? cat[0].toUpperCase()
                                              : 'C',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8A6721),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        cat,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$count perfume${count == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Color(0xFF8A6721),
                                              size: 19,
                                            ),
                                            tooltip: 'Cambiar nombre',
                                            onPressed: () =>
                                                _showEditCategoryDialog(cat),
                                          ),
                                          IconButton(
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppTheme.dangerRed,
                                              size: 19,
                                            ),
                                            tooltip: 'Eliminar categoría',
                                            onPressed: () =>
                                                _showDeleteCategoryDialog(cat),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (totalCatPages > 1) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: currentCatPage > 1
                                      ? () => setModalState(
                                            () => catPage = currentCatPage - 1,
                                          )
                                      : null,
                                  icon: const Icon(
                                    Icons.chevron_left_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Anterior',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  'Pág. $currentCatPage de $totalCatPages',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4C3A2B),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: currentCatPage < totalCatPages
                                      ? () => setModalState(
                                            () => catPage = currentCatPage + 1,
                                          )
                                      : null,
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Siguiente',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showNewCategoryDialog();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text(
                                'Crear Nueva Categoría',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C3A2B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
  },
);
}

@override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final allProducts = productProvider.filteredProducts;
    final totalProducts = allProducts.length;
    final totalPages = (totalProducts / _pageSize).ceil().clamp(1, 99999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _pageSize;
    final pagedProducts =
        allProducts.skip(startIndex).take(_pageSize).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppTheme.darkGold,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Administrador Elora',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Estás en el entorno de administración protegido de Elora. Para salir, debes cerrar tu sesión de administrador.',
              style: TextStyle(fontSize: 13.5, color: AppTheme.textDark),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Permanecer'),
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
        if (shouldLogout == true && context.mounted) {
          Provider.of<ProductProvider>(context, listen: false).clearUserFavorites();
          authProvider.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.catalog, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Inventario Elora (Admin)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Deseas cerrar tu sesión de administrador?',
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
                if (confirm == true && context.mounted) {
                  Provider.of<ProductProvider>(context, listen: false).clearUserFavorites();
                  authProvider.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.catalog,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Action Banner: Pedidos, Ventas & + Nueva Categoría
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.adminOrders);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C3A2B),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Pedidos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.adminSales);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A6721),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.analytics_rounded, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Ventas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showManageCategoriesModal,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFC5A059),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 16,
                              color: Color(0xFF8A6721),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Categorías',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF4C3A2B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search & Filter header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, origen, notas...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _currentPage = 1);
                            productProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() => _currentPage = 1);
                  productProvider.setSearchQuery(val);
                },
              ),
            ),

            // Categories chips with + and ⚙ actions
            Container(
              height: 42,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.availableCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = productProvider.availableCategories[idx];
                  final isSelected = productProvider.selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.darkGold,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.darkGold
                          : AppTheme.warmBorder,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _currentPage = 1);
                        productProvider.setCategory(cat);
                      }
                    },
                  );
                },
              ),
            ),

            // Products List
            Expanded(
              child: productProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                      ),
                    )
                  : productProvider.filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay perfumes registrados.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => productProvider.loadProducts(),
                      color: AppTheme.primaryGold,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 85,
                        ),
                        itemCount: pagedProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = pagedProducts[index];

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.productForm,
                                  arguments: product,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: product.isLowStock
                                        ? AppTheme.warningOrange.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppTheme.warmBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGold.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        color: AppTheme.backgroundLight,
                                        child: ProductImage(
                                          imageUrl: product.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${product.category} • ${product.presentation} • ${product.origin}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                AppTheme.formatPrice(
                                                  product.price,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15.5,
                                                  color: AppTheme.darkGold,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: product.stock == 0
                                                      ? AppTheme.dangerRed
                                                      : (product.isLowStock
                                                            ? AppTheme
                                                                  .warningOrange
                                                            : AppTheme
                                                                  .successGreen),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Stock: ${product.stock}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions: Edit & Delete
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: AppTheme.darkGold,
                                            size: 19,
                                          ),
                                          tooltip: 'Editar',
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.productForm,
                                              arguments: product,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppTheme.dangerRed,
                                            size: 19,
                                          ),
                                          tooltip: 'Eliminar',
                                          onPressed: () =>
                                              _confirmDelete(product),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFEADBBE), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: currentPage > 1
                              ? () => setState(
                                  () => _currentPage = currentPage - 1)
                              : null,
                          icon:
                              const Icon(Icons.chevron_left_rounded, size: 18),
                          label: const Text(
                            'Anterior',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            side: const BorderSide(color: Color(0xFFC5A059)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text(
                          'Pág. $currentPage de $totalPages',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C3A2B),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: currentPage < totalPages
                              ? () => setState(
                                  () => _currentPage = currentPage + 1)
                              : null,
                          iconAlignment: IconAlignment.end,
                          icon:
                              const Icon(Icons.chevron_right_rounded, size: 18),
                          label: const Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            side: const BorderSide(color: Color(0xFFC5A059)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.darkGold,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Perfume'),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(AppRoutes.productForm, arguments: null);
          },
        ),
      ),
    );
  }
}
