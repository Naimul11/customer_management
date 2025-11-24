import 'package:get/get.dart';
import '../data/repositories/customer_repository.dart';
import '../data/models/customer_model.dart';
import '../core/network/api_client.dart';

class CustomerController extends GetxController {
  late final CustomerRepository _customerRepository;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final customers = <CustomerModel>[].obs;
  final hasMoreData = true.obs;

  final currentPage = 1.obs;
  final int pageSize = 20;
  final totalPages = 0.obs;
  final totalRecords = 0.obs;

  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _customerRepository = CustomerRepository(ApiClient());
  }

  Future<void> loadCustomers({int? page}) async {
    if (page != null) {
      currentPage.value = page;
    } else {
      currentPage.value = 1;
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

  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value) {
      await loadCustomers(page: currentPage.value + 1);
    }
  }

  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await loadCustomers(page: currentPage.value - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value) {
      await loadCustomers(page: page);
    }
  }

  Future<void> searchCustomers(String query) async {
    searchQuery.value = query;
    await loadCustomers(page: 1);
  }

  Future<void> refreshCustomers() async {
    await loadCustomers(page: currentPage.value);
  }

  void clearError() {
    errorMessage.value = '';
  }
}
