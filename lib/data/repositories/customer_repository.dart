import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/customer_model.dart';

/// Repository for customer operations
class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository(this._apiClient);

  /// Get customer list with pagination
  Future<Map<String, dynamic>> getCustomerList({
    String searchQuery = '',
    int pageNo = 1,
    int pageSize = 20,
    String sortBy = 'Balance',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerListEndpoint,
        requiresAuth: true,
        queryParameters: {
          'searchquery': searchQuery,
          'pageNo': pageNo,
          'pageSize': pageSize,
          'SortyBy': sortBy, // Note: API has typo "SortyBy" instead of "SortBy"
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Debug: Print the raw response
        print('Customer API Response: $data');
        print('Response Type: ${data.runtimeType}');

        // Handle different response structures
        List<dynamic> customerList = [];

        if (data is List) {
          // Direct list response
          customerList = data;
          print('Direct list with ${customerList.length} customers');
        } else if (data is Map<String, dynamic>) {
          // Nested response: {Data: [...], Success: true, ...}
          print('Map keys: ${data.keys}');
          customerList = data['Data'] ?? 
                        data['data'] ?? 
                        data['Customers'] ?? 
                        data['customers'] ?? 
                        data['CustomerList'] ??
                        data['customerList'] ??
                        [];
          print('Extracted ${customerList.length} customers from map');
        }

        // Convert JSON list to CustomerModel list
        final customers = customerList
            .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Get total count from PageInfo
        int totalCount = customers.length;
        if (data is Map<String, dynamic> && data['PageInfo'] != null) {
          final pageInfo = data['PageInfo'];
          print('PageInfo: $pageInfo');
          totalCount = pageInfo['TotalRecordCount'] ?? 
                      pageInfo['TotalRecords'] ?? 
                      pageInfo['totalRecords'] ??
                      pageInfo['Total'] ??
                      pageInfo['total'] ??
                      customers.length;
        } else {
          // If no PageInfo and we got a full page, assume there are more pages
          // Estimate based on current page and received count
          if (customers.length >= pageSize) {
            // Assume at least 10 pages worth of data (can adjust based on typical dataset)
            totalCount = pageSize * 10;
          }
        }
        
        print('Final customer count: ${customers.length}, Total: $totalCount');
        return {
          'customers': customers,
          'total': totalCount,
        };
      } else {
        throw 'Failed to load customers: ${response.statusCode}';
      }
    } catch (e) {
      // Re-throw to be handled by controller
      throw e.toString();
    }
  }

  /// Search customers (reuses getCustomerList with search query)
  Future<Map<String, dynamic>> searchCustomers({
    required String query,
    int pageNo = 1,
    int pageSize = 20,
    String sortBy = 'Balance',
  }) async {
    return getCustomerList(
      searchQuery: query,
      pageNo: pageNo,
      pageSize: pageSize,
      sortBy: sortBy,
    );
  }
}
