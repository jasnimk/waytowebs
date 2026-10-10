import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../../services/zoho/zoho_service.dart';
import '../../../customer/products/controllers/products_controller.dart';

/// Admin Products Management Screen
/// Per PDF: View products, stock levels, pricing (syncs from Zoho Workbooks)
class ProductsManagementScreen extends StatelessWidget {
  const ProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: const Text(
          'Products Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: Colors.white),
            tooltip: 'Sync from Zoho Workbooks',
            onPressed: () => _showZohoSyncDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Zoho Integration Info',
            onPressed: () => _showZohoInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<ProductsController>(
        builder: (context, controller, _) {
          final products = controller.products;

          return Column(
            children: [
              // Stats Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _statCard('Total', '${products.length}', Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Low Stock', '${products.where((p) => p.stockQuantity < 10 && p.stockQuantity > 0).length}', Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Out Stock', '${products.where((p) => p.stockQuantity == 0).length}', Colors.red)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Products List
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          'No products. Sync from Zoho Workbooks',
                          style: context.typography.bodyMedium?.copyWith(color: context.colors.textLight),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final lowStock = product.stockQuantity < 10 && product.stockQuantity > 0;
                          final outOfStock = product.stockQuantity == 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.mist),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.displayImage,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: context.colors.mist,
                                    child: Icon(Icons.image, color: context.colors.textLight),
                                  ),
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: context.typography.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: outOfStock
                                                ? Colors.red.withOpacity(0.1)
                                                : lowStock
                                                    ? Colors.orange.withOpacity(0.1)
                                                    : Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            outOfStock
                                                ? 'Out of Stock'
                                                : lowStock
                                                    ? 'Low (${product.stockQuantity})'
                                                    : 'Stock: ${product.stockQuantity}',
                                            style: context.typography.labelSmall?.copyWith(
                                              color: outOfStock
                                                  ? Colors.red
                                                  : lowStock
                                                      ? Colors.orange
                                                      : Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '�${product.price}',
                                          style: context.typography.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (product.dealerPrice != null) ...[
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '/ �${product.dealerPrice} (D)',
                                            style: context.typography.bodySmall?.copyWith(color: Colors.blue),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'stock', child: Text('Update Stock')),
                                  const PopupMenuItem(value: 'sync', child: Text('Sync from Zoho')),
                                ],
                                onSelected: (value) {
                                  AppSnackbar.info(context, '$value - Integrates with Zoho Workbooks');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppSnackbar.info(context, 'Add Product - Syncs to Zoho Workbooks');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showZohoSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_sync, color: Colors.blue),
            SizedBox(width: 12),
            Text('Zoho Workbooks Sync'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products sync from Zoho Workbooks automatically:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('✓ Product name, SKU, description'),
            Text('✓ Customer price & Dealer price'),
            Text('✓ Stock quantities (real-time)'),
            Text('✓ Categories & images'),
            SizedBox(height: 16),
            Text('Sync happens:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Automatically every hour'),
            Text('• Manually via this button'),
            Text('• On app startup'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Save context and controller before async operation
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final controller = Provider.of<ProductsController>(context, listen: false);
              Navigator.pop(context);

              // Show loading
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('Syncing from Zoho Books...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                ),
              );

              // Call Zoho sync through controller
              final result = await controller.syncFromZohoBooks();

              // Clear loading snackbar
              scaffoldMessenger.clearSnackBars();

              // Show result
              if (result['success'] == true) {
                final count = result['count'];
                final source = result['source'];
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ Synced $count products from ${source == 'zoho_books' ? 'Zoho Books' : 'Zoho (Demo)'}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('❌ Sync failed: ${result['error']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  void _showZohoInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 12),
            Text('Zoho Integration'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How it works:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),

              Text('1. Zoho CRM (✓ ACTIVE)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Text('   • Dealer verification on login'),
              Text('   • Credit settings (30-day, 90-day)'),
              Text('   • Dealer status tracking'),
              SizedBox(height: 12),

              Text('2. Zoho Workbooks (Ready)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              Text('   • Product catalog management'),
              Text('   • Pricing & stock sync'),
              Text('   • Inventory tracking'),
              SizedBox(height: 12),

              Text('Setup Required:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('1. Create Zoho Workbooks account'),
              Text('2. Add products with fields:'),
              Text('   - Product Name, SKU'),
              Text('   - Customer Price, Dealer Price'),
              Text('   - Stock Quantity'),
              Text('   - Category, Images'),
              Text('3. Get API credentials'),
              Text('4. Add to ZohoService class'),
              SizedBox(height: 12),

              Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('✓ Single source of truth'),
              Text('✓ Real-time stock updates'),
              Text('✓ No manual data entry'),
              Text('✓ Automatic price changes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
