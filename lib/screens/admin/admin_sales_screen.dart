import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../data/database_helper.dart';
import '../../models/order_model.dart';

class AdminSalesScreen extends StatefulWidget {
  const AdminSalesScreen({super.key});

  @override
  State<AdminSalesScreen> createState() => _AdminSalesScreenState();
}

class _AdminSalesScreenState extends State<AdminSalesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  List<OrderModel> _allOrders = [];
  int _selectedTab = 0; // 0: Ventas concretadas, 1: Perfumes más vendidos
  int _currentSalesPage = 1;
  int _currentPerfumesPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData(showSpinner: true);
  }

  Future<void> _loadData({bool showSpinner = false}) async {
    if (showSpinner || _allOrders.isEmpty) {
      setState(() => _isLoading = true);
    }
    final orders = await _dbHelper.getAllOrders();
    if (!mounted) return;
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // REGLA CLAVE DEL USUARIO: "cada pedido que se pone en entregado se convierte en una venta"
    final deliveredSales = _allOrders
        .where((o) => o.status.trim().toLowerCase() == 'entregado')
        .toList();

    final totalDeliveredSales = deliveredSales.length;
    final totalSalesPages =
        (totalDeliveredSales / _pageSize).ceil().clamp(1, 99999);
    final currentSalesPage = _currentSalesPage.clamp(1, totalSalesPages);
    final salesStartIndex = (currentSalesPage - 1) * _pageSize;
    final pagedDeliveredSales =
        deliveredSales.skip(salesStartIndex).take(_pageSize).toList();

    final pendingOrders = _allOrders
        .where((o) => o.status.trim().toLowerCase() != 'entregado')
        .toList();

    final double totalSalesRevenue =
        deliveredSales.fold(0.0, (acc, o) => acc + o.total);

    final double pendingRevenue =
        pendingOrders.fold(0.0, (acc, o) => acc + o.total);

    final int totalUnitsSold = deliveredSales.fold(
      0,
      (acc, o) => acc + o.items.fold(0, (sub, i) => sub + i.quantity),
    );

    final double averageTicket = deliveredSales.isNotEmpty
        ? totalSalesRevenue / deliveredSales.length
        : 0.0;

    // Perfumes más vendidos en base a pedidos entregados
    final Map<String, int> productUnits = {};
    final Map<String, double> productRevenue = {};

    for (final order in deliveredSales) {
      for (final item in order.items) {
        productUnits[item.productName] =
            (productUnits[item.productName] ?? 0) + item.quantity;
        productRevenue[item.productName] =
            (productRevenue[item.productName] ?? 0.0) + item.subtotal;
      }
    }

    final sortedProducts = productUnits.keys.toList()
      ..sort((a, b) =>
          (productRevenue[b] ?? 0.0).compareTo(productRevenue[a] ?? 0.0));

    final totalPerfumes = sortedProducts.length;
    final totalPerfumePages =
        (totalPerfumes / _pageSize).ceil().clamp(1, 99999);
    final currentPerfumePage =
        _currentPerfumesPage.clamp(1, totalPerfumePages);
    final perfumeStartIndex = (currentPerfumePage - 1) * _pageSize;
    final pagedPerfumes =
        sortedProducts.skip(perfumeStartIndex).take(_pageSize).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
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
              height: 22,
              errorBuilder: (_, __, _) => const Icon(
                Icons.analytics_rounded,
                size: 20,
                color: Color(0xFFC5A059),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Reporte de Ventas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF281E17),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(),
              color: AppTheme.primaryGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO CARD: VENTAS TOTALES (PEDIDOS ENTREGADOS)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF38291F), Color(0xFF1E1510)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC5A059)
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFC5A059)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        size: 14, color: Color(0xFFEADBBE)),
                                    SizedBox(width: 5),
                                    Text(
                                      'VENTAS CONCRETADAS',
                                      style: TextStyle(
                                        color: Color(0xFFEADBBE),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFFC5A059),
                                size: 26,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Ingresos Totales (Entregados)',
                            style: TextStyle(
                              color: Color(0xFFD4C9BC),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppTheme.formatPrice(totalSalesRevenue),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Regla de negocio: Cada pedido marcado como "Entregado" se contabiliza automáticamente como una venta exitosa.',
                            style: TextStyle(
                              color: Color(0xFFAFA497),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFF554436), height: 1),
                          const SizedBox(height: 16),
                          // KPI METRICS ROW
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiStat(
                                  label: 'Pedidos',
                                  value: '${deliveredSales.length}',
                                  icon: Icons.check_circle_rounded,
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: const Color(0xFF554436)),
                              Expanded(
                                child: _buildKpiStat(
                                  label: 'Unidades',
                                  value: '$totalUnitsSold',
                                  icon: Icons.inventory_2_rounded,
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: const Color(0xFF554436)),
                              Expanded(
                                child: _buildKpiStat(
                                  label: 'Promedio',
                                  value: AppTheme.formatPrice(averageTicket),
                                  icon: Icons.auto_graph_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECONDARY CARD: PEDIDOS EN CURSO / POR ENTREGAR
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFFE2D6C5), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8A6721)
                                  .withValues(alpha: 0.12),
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Color(0xFF8A6721),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'En tránsito / Por entregar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF281E17),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pendingOrders.length} pedidos pendientes • ${AppTheme.formatPrice(pendingRevenue)} proyectados',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF7A6F64),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushNamed(AppRoutes.adminOrders);
                              if (mounted) {
                                _loadData();
                              }
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Gestionar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: Color(0xFF8A6721),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    size: 16, color: Color(0xFF8A6721)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SELECTOR SUPERIOR: VENTAS CONCRETADAS vs PERFUMES MÁS VENDIDOS
                    Container(
                      margin: const EdgeInsets.only(top: 18, bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE8DD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2D6C5),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0
                                      ? const Color(0xFF4C3A2B)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.12),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 16,
                                      color: _selectedTab == 0
                                          ? const Color(0xFFFFD580)
                                          : const Color(0xFF6B5A4B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ventas Concretadas',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 0
                                            ? Colors.white
                                            : const Color(0xFF6B5A4B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1
                                      ? const Color(0xFF4C3A2B)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.12),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.leaderboard_rounded,
                                      size: 16,
                                      color: _selectedTab == 1
                                          ? const Color(0xFFFFD580)
                                          : const Color(0xFF6B5A4B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Perfumes Más Vendidos',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 1
                                            ? Colors.white
                                            : const Color(0xFF6B5A4B),
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

                    // TAB 0: HISTORIAL DE VENTAS CONCRETADAS (10 en 10)
                    if (_selectedTab == 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ventas Concretadas',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF241B15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${deliveredSales.length} entregados',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (deliveredSales.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFECE3D4)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Color(0xFFB5A99B),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Aún no hay ventas concretadas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF281E17),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Entra a "Ver Pedidos" y cambia el estado de cualquier orden a "Entregado" para registrar la venta.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A7E73),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .pushNamed(AppRoutes.adminOrders);
                                  if (mounted) {
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.receipt_long_rounded,
                                    size: 16),
                                label: const Text('Ir a Gestión de Pedidos'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C3A2B),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pagedDeliveredSales.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final order = pagedDeliveredSales[idx];
                            final totalPerfumes = order.items.fold(
                              0,
                              (acc, item) => acc + item.quantity,
                            );

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5DDD0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4C3A2B),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Text(
                                              '#ELO0${order.id}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            order.clientName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF241B15),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 12,
                                              color: Color(0xFF2E7D32),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'CONCRETADA',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fecha: ${order.createdAt.length >= 10 ? order.createdAt.substring(0, 10) : order.createdAt} • ${order.paymentMethod}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF8A7E73),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFF1EAE0),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$totalPerfumes perfume${totalPerfumes == 1 ? '' : 's'}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF7A6F64),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            AppTheme.formatPrice(order.total),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF4C3A2B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _showSaleDetailModal(order),
                                        icon: const Icon(
                                          Icons.receipt_long_rounded,
                                          size: 15,
                                        ),
                                        label: const Text('Ver detalle'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4C3A2B),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
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
                    ],

                    // TAB 1: PERFUMES MÁS VENDIDOS (10 en 10)
                    if (_selectedTab == 1) ...[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Perfumes Más Vendidos',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF241B15),
                            ),
                          ),
                          Text(
                            'Por ventas entregadas',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8A6721),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (sortedProducts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFECE3D4)),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 44,
                                color: Color(0xFFB5A99B),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aún no hay perfumes vendidos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF281E17),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Las fragancias se registrarán aquí automáticamente conforme se entreguen pedidos.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF8A7E73),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFECE3D4)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pagedPerfumes.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0xFFF3EEE6)),
                            itemBuilder: (context, idx) {
                              final rank = perfumeStartIndex + idx + 1;
                              final name = pagedPerfumes[idx];
                              final units = productUnits[name] ?? 0;
                              final rev = productRevenue[name] ?? 0.0;
                              return ListTile(
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: rank == 1
                                        ? const Color(0xFFFFB300)
                                            .withValues(alpha: 0.15)
                                        : const Color(0xFFF4ECE1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: rank == 1
                                            ? const Color(0xFF8A6721)
                                            : const Color(0xFF4C3A2B),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF241B15),
                                  ),
                                ),
                                subtitle: Text(
                                  '$units unidades entregadas',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF8A7E73)),
                                ),
                                trailing: Text(
                                  AppTheme.formatPrice(rev),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF4C3A2B),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
                  onPressed: _selectedTab == 0
                      ? (currentSalesPage > 1
                          ? () => setState(
                              () => _currentSalesPage = currentSalesPage - 1)
                          : null)
                      : (currentPerfumePage > 1
                          ? () => setState(() =>
                              _currentPerfumesPage = currentPerfumePage - 1)
                          : null),
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
                  _selectedTab == 0
                      ? 'Pág. $currentSalesPage de $totalSalesPages'
                      : 'Pág. $currentPerfumePage de $totalPerfumePages',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C3A2B),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectedTab == 0
                      ? (currentSalesPage < totalSalesPages
                          ? () => setState(
                              () => _currentSalesPage = currentSalesPage + 1)
                          : null)
                      : (currentPerfumePage < totalPerfumePages
                          ? () => setState(() =>
                              _currentPerfumesPage = currentPerfumePage + 1)
                          : null),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
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

  void _showSaleDetailModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD2C3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C3A2B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#ELO0${order.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Detalle de Venta',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF281E17),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CONCRETADA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFECE3D4)),
                ),
                child: Column(
                  children: [
                    _buildModalInfoRow(
                      Icons.person_outline_rounded,
                      'Cliente:',
                      order.clientName,
                    ),
                    const SizedBox(height: 6),
                    _buildModalInfoRow(
                      Icons.calendar_today_outlined,
                      'Fecha:',
                      order.createdAt.length >= 10
                          ? order.createdAt.substring(0, 10)
                          : order.createdAt,
                    ),
                    const SizedBox(height: 6),
                    _buildModalInfoRow(
                      Icons.credit_card_outlined,
                      'Método de Pago:',
                      order.paymentMethod,
                    ),
                    if (order.deliveryAddress.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildModalInfoRow(
                        Icons.pin_drop_outlined,
                        'Dirección:',
                        order.deliveryAddress,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Perfumes Vendidos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF281E17),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF1EAE0)),
                  itemBuilder: (context, i) {
                    final item = order.items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8A6721)
                                  .withValues(alpha: 0.1),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.sanitizer_rounded,
                                size: 16,
                                color: Color(0xFF8A6721),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.productName}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF241B15),
                                  ),
                                ),
                                if (item.presentation.isNotEmpty)
                                  Text(
                                    item.presentation,
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
                          const SizedBox(width: 8),
                          Text(
                            AppTheme.formatPrice(item.subtotal),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C3A2B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5DDD0)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cobrado:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF281E17),
                    ),
                  ),
                  Text(
                    AppTheme.formatPrice(order.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4C3A2B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8A6721)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF554436),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF281E17),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFC5A059)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB5A99B),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
