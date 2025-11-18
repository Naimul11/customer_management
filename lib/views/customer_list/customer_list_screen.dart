import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/customer_card.dart';

/// Customer list screen with pagination
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late final CustomerController _customerController;
  late final AuthController _authController;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get or create the controllers
    try {
      _customerController = Get.find<CustomerController>();
    } catch (e) {
      _customerController = Get.put(CustomerController());
    }
    try {
      _authController = Get.find<AuthController>();
    } catch (e) {
      _authController = Get.put(AuthController());
    }
    // Load customers after screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerController.loadCustomers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authController.logout();
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _customerController.searchCustomers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                _customerController.searchCustomers(value.trim());
              },
            ),
          ),

          // Customer list
          Expanded(
            child: Obx(() {
              // Loading state (initial)
              if (_customerController.isLoading.value &&
                  _customerController.customers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Error state (no customers loaded)
              if (_customerController.errorMessage.value.isNotEmpty &&
                  _customerController.customers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _customerController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            _customerController.clearError();
                            _customerController.loadCustomers(page: 1);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty state
              if (_customerController.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customers found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Customer list
              return RefreshIndicator(
                onRefresh: _customerController.refreshCustomers,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _customerController.customers.length,
                  itemBuilder: (context, index) {
                    // Customer card
                    final customer = _customerController.customers[index];
                    return CustomerCard(
                      customer: customer,
                      onTap: () {
                        // Show customer details dialog
                        _showCustomerDetails(customer);
                      },
                    );
                  },
                ),
              );
            }),
          ),

          // Pagination controls
          Obx(() {
            if (_customerController.customers.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page info
                  Text(
                    'Page ${_customerController.currentPage.value} of ${_customerController.totalPages.value} (Total: ${_customerController.totalRecords.value} customers)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  // Pagination buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // First page
                      IconButton(
                        onPressed: _customerController.currentPage.value > 1
                            ? () => _customerController.goToPage(1)
                            : null,
                        icon: const Icon(Icons.first_page),
                        tooltip: 'First page',
                      ),

                      // Previous page
                      IconButton(
                        onPressed: _customerController.currentPage.value > 1
                            ? _customerController.previousPage
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous page',
                      ),

                      const SizedBox(width: 8),

                      // Page numbers (show current and nearby pages)
                      ..._buildPageNumbers(),

                      const SizedBox(width: 8),

                      // Next page
                      IconButton(
                        onPressed: _customerController.currentPage.value <
                                _customerController.totalPages.value
                            ? _customerController.nextPage
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next page',
                      ),

                      // Last page
                      IconButton(
                        onPressed: _customerController.currentPage.value <
                                _customerController.totalPages.value
                            ? () => _customerController
                                .goToPage(_customerController.totalPages.value)
                            : null,
                        icon: const Icon(Icons.last_page),
                        tooltip: 'Last page',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final currentPage = _customerController.currentPage.value;
    final totalPages = _customerController.totalPages.value;
    final List<Widget> pageButtons = [];

    if (totalPages <= 1) return pageButtons;

    // Always show first page
    if (currentPage > 3) {
      pageButtons.add(_buildPageButton(1));
      if (currentPage > 4) {
        pageButtons.add(_buildEllipsis());
      }
    }

    // Show current page and 2 pages before and after
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i));
    }

    // Always show last page
    if (currentPage < totalPages - 2) {
      if (currentPage < totalPages - 3) {
        pageButtons.add(_buildEllipsis());
      }
      pageButtons.add(_buildPageButton(totalPages));
    }

    return pageButtons;
  }

  Widget _buildPageButton(int pageNum) {
    final currentPage = _customerController.currentPage.value;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: currentPage == pageNum
          ? ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
              child: Text('$pageNum'),
            )
          : OutlinedButton(
              onPressed: () => _customerController.goToPage(pageNum),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
              child: Text('$pageNum'),
            ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text('...', style: TextStyle(fontSize: 18)),
    );
  }

  void _showCustomerDetails(customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name ?? 'Customer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customer.code != null) ...[
                _buildDetailRow('Code', customer.code!),
                const Divider(),
              ],
              if (customer.phone != null) ...[
                _buildDetailRow('Phone', customer.phone!),
                const Divider(),
              ],
              if (customer.email != null && customer.email!.isNotEmpty) ...[
                _buildDetailRow('Email', customer.email!),
                const Divider(),
              ],
              if (customer.address != null && customer.address!.isNotEmpty) ...[
                _buildDetailRow('Address', customer.address!),
                const Divider(),
              ],
              if (customer.customerType != null) ...[
                _buildDetailRow('Type', customer.customerType!),
                const Divider(),
              ],
              _buildDetailRow(
                'Balance',
                '\$${customer.balance?.toStringAsFixed(2) ?? '0.00'}',
              ),
              if (customer.remarks != null && customer.remarks!.isNotEmpty) ...[
                const Divider(),
                _buildDetailRow('Remarks', customer.remarks!),
              ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
