import 'package:get/get.dart';
import '../data/repositories/customer_repository.dart';
import '../data/models/customer_model.dart';
import '../core/network/api_client.dart';

/// Controller for customer operations
class CustomerController extends GetxController {
  late final CustomerRepository _customerRepository;

  // Observable states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final customers = <CustomerModel>[].obs;
  final hasMoreData = true.obs;

  // Pagination
  final currentPage = 1.obs;
  final int pageSize = 20;
  final totalPages = 0.obs;
  final totalRecords = 0.obs;

  // Search
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _customerRepository = CustomerRepository(ApiClient());
    // Don't auto-load customers on init
    // loadCustomers();
  }

  /// Load customers for specific page
  Future<void> loadCustomers({int? page}) async {
    if (page != null) {
      currentPage.value = page;
    }

    errorMessage.value = '';
    isLoading.value = true;
    customers.clear();

    try {
      final result = await _customerRepository.getCustomerList(
        searchQuery: searchQuery.value,
        pageNo: currentPage.value,
        pageSize: pageSize,
        sortBy: 'Balance',
      );

      print('CustomerController: Loaded ${result['customers'].length} customers for page ${currentPage.value}');

      customers.value = result['customers'];
      totalRecords.value = result['total'];
      totalPages.value = (result['total'] / pageSize).ceil();
      hasMoreData.value = currentPage.value < totalPages.value;

      print('CustomerController: Page ${currentPage.value} of ${totalPages.value}, Total: ${totalRecords.value}');

      isLoading.value = false;
    } catch (e) {
      print('CustomerController Error: $e');
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value) {
      await loadCustomers(page: currentPage.value + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await loadCustomers(page: currentPage.value - 1);
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value) {
      await loadCustomers(page: page);
    }
  }

  /// Search customers
  Future<void> searchCustomers(String query) async {
    searchQuery.value = query;
    await loadCustomers(page: 1);
  }

  /// Refresh customer list (pull to refresh)
  Future<void> refreshCustomers() async {
    await loadCustomers(page: currentPage.value);
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
