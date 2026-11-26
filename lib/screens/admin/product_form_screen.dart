import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/controllers/product_controller.dart';
import '../../widgets/product_image.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _originController;
  late TextEditingController _varietyController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  final TextEditingController _customPresentationController =
      TextEditingController();

  List<String> _imagePaths = [];
  List<String> _selectedPresentations = [];
  String _selectedCategory = 'Mujer';

  static const List<String> _quickPresentations = [
    '5 ml',
    '10 ml',
    '30 ml',
    '50 ml',
    '80 ml',
    '100 ml',
    '200 ml',
  ];

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _selectedCategory = p?.category ?? 'Mujer';
    _originController = TextEditingController(text: p?.origin ?? '');
    _varietyController = TextEditingController(text: p?.variety ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _stockController =
        TextEditingController(text: p != null ? p.stock.toString() : '');
    _descriptionController =
        TextEditingController(text: p?.description ?? '');

    _imagePaths = p != null ? List<String>.from(p.images) : [];
    _selectedPresentations =
        p != null ? List<String>.from(p.presentations) : ['100 ml'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _varietyController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _customPresentationController.dispose();
    super.dispose();
  }

  Future<void> _pickGalleryImages() async {
    final remainingSlots = 5 - _imagePaths.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya alcanzaste el límite máximo de 5 fotos.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (files.isNotEmpty) {
        setState(() {
          for (final f in files) {
            if (_imagePaths.length < 5 && !_imagePaths.contains(f.path)) {
              _imagePaths.add(f.path);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imágenes: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _pickCameraImage() async {
    if (_imagePaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya alcanzaste el límite máximo de 5 fotos.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (file != null) {
        setState(() {
          if (_imagePaths.length < 5) {
            _imagePaths.add(file.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    if (_imagePaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes el máximo de 5 fotos añadidas.'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Subir fotos del perfume (${_imagePaths.length}/5)',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF281E17),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Puedes subir hasta 5 fotografías desde tu dispositivo',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF3E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF8A6721),
                  ),
                ),
                title: const Text(
                  'Elegir de la galería / archivos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF281E17),
                  ),
                ),
                subtitle: const Text(
                  'Selecciona una o varias fotos a la vez',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickGalleryImages();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF3E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF8A6721),
                  ),
                ),
                title: const Text(
                  'Tomar foto con la cámara',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF281E17),
                  ),
                ),
                subtitle: const Text(
                  'Abre la cámara para fotografiar el frasco',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickCameraImage();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _addCustomPresentation() {
    final text = _customPresentationController.text.trim();
    if (text.isEmpty) return;

    final formatted = text.toLowerCase().endsWith('ml') ||
            text.toLowerCase().endsWith('oz') ||
            text.toLowerCase().endsWith('set')
        ? text
        : '$text ml';

    if (!_selectedPresentations.contains(formatted)) {
      setState(() {
        _selectedPresentations.add(formatted);
      });
      _customPresentationController.clear();
    }
  }

  void _togglePresentation(String size) {
    setState(() {
      if (_selectedPresentations.contains(size)) {
        if (_selectedPresentations.length > 1) {
          _selectedPresentations.remove(size);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debe existir al menos una presentación.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedPresentations.add(size);
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor sube al menos una foto para el perfume.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    if (_selectedPresentations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agrega al menos una presentación (ej: 100 ml).'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final product = ProductModel(
      id: widget.productToEdit?.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      presentation: _selectedPresentations.join(', '),
      origin: _originController.text.trim(),
      variety: _varietyController.text.trim(),
      price: price,
      stock: stock,
      description: _descriptionController.text.trim(),
      imageUrl: _imagePaths.join('|'),
    );

    bool success;
    if (isEditing) {
      success = await productProvider.updateProduct(product);
    } else {
      success = await productProvider.addProduct(product);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Perfume actualizado exitosamente.'
                : 'Nuevo perfume creado con éxito.',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productProvider.errorMessage ?? 'Error al guardar el perfume.',
          ),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final dynamicCategories = productProvider.availableCategories
        .where((c) => c.toLowerCase() != 'todos')
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? 'Editar Perfume' : 'Crear Nuevo Perfume'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER DE FOTOGRAFÍAS (MÁXIMO 5 IMÁGENES)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fotografías del perfume *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF281E17),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _imagePaths.length == 5
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                          : const Color(0xFFC5A059).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_imagePaths.length}/5 fotos',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: _imagePaths.length == 5
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF8A6721),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // VISTA DE MINIATURAS Y BOTÓN DE CARGA
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length + (_imagePaths.length < 5 ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    // Botón para agregar más fotos
                    if (index == _imagePaths.length) {
                      return InkWell(
                        onTap: _showImageSourceDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 105,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF8F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC5A059),
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 30,
                                color: Color(0xFF8A6721),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '+ Subir foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4C3A2B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final path = _imagePaths[index];
                    final isPrimary = index == 0;

                    return Stack(
                      children: [
                        Container(
                          width: 105,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPrimary
                                  ? const Color(0xFFC5A059)
                                  : const Color(0xFFE2D6C5),
                              width: isPrimary ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: ProductImage(
                              imageUrl: path,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Badge Principal
                        if (isPrimary)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C3A2B).withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Principal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Botón de Eliminar Foto
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imagePaths.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del perfume *',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: dynamicCategories.contains(_selectedCategory)
                          ? _selectedCategory
                          : (dynamicCategories.isNotEmpty
                              ? dynamicCategories.first
                              : 'Mujer'),
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: dynamicCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      tooltip: 'Nueva categoría',
                      onPressed: () {
                        final catController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            title: const Text('Nueva Categoría'),
                            content: TextField(
                              controller: catController,
                              autofocus: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la categoría',
                                hintText: 'Ej: Oriental, Árabe...',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final name = catController.text.trim();
                                  if (name.isEmpty) return;
                                  Navigator.of(ctx).pop();
                                  final success =
                                      await productProvider.addCategory(name);
                                  if (success) {
                                    setState(() {
                                      _selectedCategory = name;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C3A2B),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // SECCIÓN: PRESENTACIONES / TAMAÑOS (5 ml, 10 ml, 100 ml, etc.)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFE8DD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Presentaciones disponibles *',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF281E17),
                          ),
                        ),
                        Text(
                          '${_selectedPresentations.length} activas',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8A6721),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toca para activar las medidas que ofrece este perfume:',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 10),

                    // Chips de medidas comunes
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _quickPresentations.map((size) {
                        final isSelected = _selectedPresentations.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4C3A2B),
                          backgroundColor: const Color(0xFFFBF8F2),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF4C3A2B),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF4C3A2B)
                                : const Color(0xFFE2D6C5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (_) => _togglePresentation(size),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Agregar otra medida personalizada
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _customPresentationController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Otra medida (ej. 15 ml, 120 ml, Set)',
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2D6C5)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2D6C5)),
                                ),
                              ),
                              onSubmitted: (_) => _addCustomPresentation(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addCustomPresentation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3A2B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '+ Añadir',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedPresentations.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selectedPresentations.map((p) {
                          return Chip(
                            label: Text(p),
                            deleteIcon: const Icon(Icons.close, size: 13),
                            onDeleted: () => _togglePresentation(p),
                            backgroundColor:
                                const Color(0xFFC5A059).withValues(alpha: 0.15),
                            labelStyle: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C3A2B),
                            ),
                            side: const BorderSide(color: Color(0xFFC5A059)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Origin & Variety row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originController,
                      decoration: const InputDecoration(
                        labelText: 'Origen / Casa',
                        hintText: 'ej: Francia',
                        prefixIcon: Icon(Icons.public_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _varietyController,
                      decoration: const InputDecoration(
                        labelText: 'Concentración / Aroma',
                        hintText: 'ej: Eau de Parfum, Floral...',
                        prefixIcon: Icon(Icons.auto_awesome_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Price & Stock row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (COP) *',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa el precio';
                        if (double.tryParse(v) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock disponible *',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa el stock';
                        if (int.tryParse(v) == null) return 'Entero inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción y notas olfativas',
                  hintText:
                      'ej: Notas de salida cítricas, corazón floral, fondo amaderado...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa la descripción' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkGold.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Actualizar Perfume' : 'Guardar Perfume',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
