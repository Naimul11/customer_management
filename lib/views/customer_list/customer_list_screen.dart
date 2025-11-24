import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/customer_card.dart';

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
  final _showPagination = true.obs;

  @override
  void initState() {
    super.initState();
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

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        if (maxScroll - currentScroll <= 200) {
          _showPagination.value = true;
        } else {
          _showPagination.value = false;
        }
      }
    });

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 93, 120, 164), // Decent blue-grey
        elevation: 0,
        title: const Text(
          'Customers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, email...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _customerController.searchCustomers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (value) {
                _customerController.searchCustomers(value.trim());
              },
            ),
          ),

          Expanded(
            child: Obx(() {
              if (_customerController.isLoading.value &&
                  _customerController.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading customers...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_customerController.errorMessage.value.isNotEmpty &&
                  _customerController.customers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oops! Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _customerController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            _customerController.clearError();
                            _customerController.loadCustomers(page: 1);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_customerController.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No customers found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Try adjusting your search criteria',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _customerController.refreshCustomers,
                color: Theme.of(context).primaryColor,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: _customerController.customers.length + 1,
                  itemBuilder: (context, index) {
                    if ((index + 1) % 21 == 0 && index > 0) {
                      return _buildPaginationWidget();
                    }
                    
                    final customerIndex = index - (index ~/ 21);
                    
                    if (customerIndex >= _customerController.customers.length) {
                      return const SizedBox.shrink();
                    }
                    
                    final customer = _customerController.customers[customerIndex];
                    return CustomerCard(
                      customer: customer,
                      onTap: () {
                        _showCustomerDetails(customer);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (_customerController.customers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _buildPageNumbers(),
        );
      }),
    );
  }

  List<Widget> _buildPageNumbers() {
    final currentPage = _customerController.currentPage.value;
    final totalPages = _customerController.totalPages.value;
    final List<Widget> pageButtons = [];

    if (totalPages <= 1) return pageButtons;

    pageButtons.add(_buildNavigationButton(
      icon: Icons.chevron_left,
      onTap: currentPage > 1 ? () => _customerController.previousPage() : null,
    ));

    int startPage, endPage;
    
    if (totalPages <= 4) {
      startPage = 1;
      endPage = totalPages;
    } else {
      if (currentPage <= 2) {
        startPage = 1;
        endPage = 4;
      } else if (currentPage >= totalPages - 1) {
        startPage = totalPages - 3;
        endPage = totalPages;
      } else {
        startPage = currentPage - 1;
        endPage = currentPage + 2;
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i));
    }

    pageButtons.add(_buildNavigationButton(
      icon: Icons.chevron_right,
      onTap: currentPage < totalPages ? () => _customerController.nextPage() : null,
    ));

    return pageButtons;
  }

  Widget _buildNavigationButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap != null ? Colors.blue[50] : Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null ? Colors.blue[700] : Colors.grey[400],
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton(int pageNum) {
    final currentPage = _customerController.currentPage.value;
    final bool isActive = currentPage == pageNum;
    
    return Material(
      color: isActive ? Colors.black87 : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isActive ? null : () => _customerController.goToPage(pageNum),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.black87 : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$pageNum',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
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
