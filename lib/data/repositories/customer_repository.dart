import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository(this._apiClient);

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
          'SortyBy': sortBy,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        print('Customer API Response: $data');
        print('Response Type: ${data.runtimeType}');

        List<dynamic> customerList = [];

        if (data is List) {
          customerList = data;
          print('Direct list with ${customerList.length} customers');
        } else if (data is Map<String, dynamic>) {
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

        final customers = customerList
            .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
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
          if (customers.length >= pageSize) {
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
      throw e.toString();
    }
  }

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
