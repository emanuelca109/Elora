import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../data/database_helper.dart';
import '../../providers/controllers/cart_controller.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../providers/controllers/product_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  String _selectedPaymentMethod = 'Tarjeta de crédito / débito';

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'id': 'Tarjeta de crédito / débito',
      'title': 'Tarjeta de crédito / débito',
      'subtitle': 'Visa, Mastercard, American Express (Hasta 12 cuotas)',
      'icon': Icons.credit_card_rounded,
      'badge': '0% interés',
    },
    {
      'id': 'Transferencia PSE',
      'title': 'Transferencia Bancaria PSE',
      'subtitle': 'Débito seguro desde Bancolombia, Davivienda, etc.',
      'icon': Icons.account_balance_rounded,
      'badge': 'En línea',
    },
    {
      'id': 'Nequi',
      'title': 'Nequi',
      'subtitle': 'Pago inmediato escaneando QR o a número de celular',
      'icon': Icons.phone_android_rounded,
      'badge': 'Express',
    },
    {
      'id': 'Daviplata',
      'title': 'Daviplata',
      'subtitle': 'Transferencia rápida y sin costo de intermediación',
      'icon': Icons.smartphone_rounded,
      'badge': 'Sin costo',
    },
    {
      'id': 'Bancolombia QR',
      'title': 'Bancolombia QR / Llave',
      'subtitle': 'Aprobación automática y despacho prioritario',
      'icon': Icons.qr_code_2_rounded,
      'badge': 'Inmediato',
    },
    {
      'id': 'Billetera Digital',
      'title': 'Apple Pay / Google Pay',
      'subtitle': 'Pago biométrico rápido con un solo toque',
      'icon': Icons.contactless_rounded,
      'badge': 'Seguro',
    },
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: '312 456 7890');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController =
        TextEditingController(text: 'Cra 43A # 1-50, El Poblado');
    _cityController = TextEditingController(text: 'Medellín, Antioquia');

    if (user != null) {
      DatabaseHelper.instance.getAddresses(user.email).then((addrs) {
        if (addrs.isNotEmpty && mounted) {
          final def = addrs.firstWhere((a) => a['is_default'] == 1,
              orElse: () => addrs.first);
          setState(() {
            _nameController.text = def['recipient_name'] ?? user.name;
            _phoneController.text = def['phone'] ?? _phoneController.text;
            _addressController.text =
                def['address_line'] ?? _addressController.text;
            _cityController.text = def['city'] ?? _cityController.text;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final fullAddress =
        '${_addressController.text.trim()}, ${_cityController.text.trim()}';

    final orderId = await cartProvider.processCheckout(
      clientName: _nameController.text.trim(),
      clientPhone: _phoneController.text.trim(),
      clientEmail: _emailController.text.trim(),
      deliveryAddress: fullAddress,
      paymentMethod: _selectedPaymentMethod,
    );

    if (!mounted) return;

    if (orderId != null) {
      // Reload products to refresh stock counts
      productProvider.loadProducts();

      _showOrderSuccessDialog(orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cartProvider.checkoutError ?? 'Error al procesar el pedido.',
          ),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _showOrderSuccessDialog(int orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '¡Pedido Confirmado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu orden #ELO0$orderId ha sido registrada y está en preparación.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.catalog,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Volver a la tienda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.adminCatalog,
            (route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Finalizar compra'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección Dirección de Envío (matching mockup screen 9)
              const Text(
                'Dirección de envío',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warmBorder),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre receptor',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (Calle, Carrera, Apto)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad y Departamento',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección Método de Pago
              const Text(
                'Método de pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: _paymentOptions.map((opt) {
                  final isSelected = _selectedPaymentMethod == opt['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = opt['id'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFBF8F2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC5A059)
                              : AppTheme.warmBorder,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFFC5A059).withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF4C3A2B)
                                  : const Color(0xFFFAF4EB),
                            ),
                            child: Icon(
                              opt['icon'] as IconData,
                              color: isSelected
                                  ? const Color(0xFFEADBBE)
                                  : const Color(0xFF8A6721),
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        opt['title'] as String,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 14,
                                          color: const Color(0xFF241B15),
                                        ),
                                      ),
                                    ),
                                    if (opt['badge'] != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8A6721)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          opt['badge'] as String,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8A6721),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  opt['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7E7266),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8A6721)
                                    : const Color(0xFFC7B8A6),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF8A6721),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Resumen del Pedido
              const Text(
                'Resumen del pedido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warmBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(color: AppTheme.textMuted)),
                        Text(
                          AppTheme.formatPrice(cartProvider.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Envío',
                            style: TextStyle(color: AppTheme.textMuted)),
                        Text(
                          'Gratis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          AppTheme.formatPrice(cartProvider.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Botón Confirmar Pedido
              Container(
                width: double.infinity,
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
                  onPressed: cartProvider.isProcessingCheckout
                      ? null
                      : _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: cartProvider.isProcessingCheckout
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirmar pedido',
                          style: TextStyle(
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
