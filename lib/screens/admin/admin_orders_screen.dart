import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../data/database_helper.dart';
import '../../models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  int _currentPage = 1;
  static const int _pageSize = 10;

  final List<String> _filterOptions = [
    'Todos',
    'Preparando',
    'En camino',
    'Entregado',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _dbHelper.getAllOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    await _dbHelper.updateOrderStatus(orderId, newStatus);
    await _loadOrders();
    if (!mounted) return;
    final isDelivered = newStatus == 'Entregado';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDelivered
              ? '¡Orden #ELO0$orderId ENTREGADA y contabilizada como Venta exitosa!'
              : 'Estado de orden #ELO0$orderId actualizado a "$newStatus"',
        ),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  List<OrderModel> get _filteredOrders {
    if (_selectedFilter == 'Todos') return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Preparando':
        return AppTheme.warningOrange;
      case 'En camino':
        return AppTheme.darkGold;
      case 'Entregado':
        return AppTheme.successGreen;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = _filteredOrders;
    final totalOrders = allOrders.length;
    final totalPages = (totalOrders / _pageSize).ceil().clamp(1, 99999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _pageSize;
    final pagedOrders = allOrders.skip(startIndex).take(_pageSize).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Gestión de Pedidos'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final f = _filterOptions[idx];
                final isSelected = _selectedFilter == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  selectedColor: AppTheme.darkGold,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.darkGold : AppTheme.warmBorder,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedFilter = f;
                        _currentPage = 1;
                      });
                    }
                  },
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                    ),
                  )
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_rounded,
                          size: 54,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay órdenes con este filtro',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: AppTheme.primaryGold,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pagedOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final order = pagedOrders[idx];
                        final statusColor = _getStatusColor(order.status);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.warmBorder,
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGold.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: statusColor,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#ELO0${order.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    AppTheme.formatPrice(order.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order.clientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),

                                      // Client Info
                                      _buildDetailRow(
                                        Icons.email_outlined,
                                        'Email:',
                                        order.clientEmail,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildDetailRow(
                                        Icons.phone_outlined,
                                        'Teléfono:',
                                        order.clientPhone,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildDetailRow(
                                        Icons.location_on_outlined,
                                        'Dirección:',
                                        order.deliveryAddress,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildDetailRow(
                                        Icons.credit_card_outlined,
                                        'Método:',
                                        order.paymentMethod,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildDetailRow(
                                        Icons.access_time_rounded,
                                        'Fecha:',
                                        order.createdAt,
                                      ),

                                      const SizedBox(height: 12),
                                      const Text(
                                        'Productos Comprados:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ...order.items.map(
                                        (it) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${it.quantity}x ${it.productName} (${it.presentation})',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppTheme.formatPrice(
                                                  it.subtotal,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      // Status Changer Dropdown
                                      Row(
                                        children: [
                                          const Text(
                                            'Cambiar estado: ',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          DropdownButton<String>(
                                            value: order.status,
                                            underline: const SizedBox(),
                                            items:
                                                [
                                                      'Preparando',
                                                      'En camino',
                                                      'Entregado',
                                                    ]
                                                    .map(
                                                      (s) => DropdownMenuItem(
                                                        value: s,
                                                        child: Text(
                                                          s,
                                                          style: TextStyle(
                                                            color:
                                                                _getStatusColor(
                                                                  s,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.5,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (newVal) {
                                              if (newVal != null &&
                                                  newVal != order.status) {
                                                _updateStatus(
                                                  order.id!,
                                                  newVal,
                                                );
                                              }
                                            },
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
                      },
                    ),
                  ),
          ),
          // Barra de Paginación de Pedidos (10 en 10)
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
                        icon: const Icon(Icons.chevron_left_rounded, size: 18),
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}
