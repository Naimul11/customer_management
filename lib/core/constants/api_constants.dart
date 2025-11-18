/// API configuration constants
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://www.pqstec.com/InvoiceApps/Values/';
  static const String imageBaseUrl = 'https://www.pqstec.com/InvoiceApps/';

  // API Endpoints
  static const String loginEndpoint = 'LogIn';
  static const String customerListEndpoint = 'GetCustomerList';

  // Default Parameters
  static const int defaultComId = 1;
  static const int defaultPageSize = 20;
  static const String defaultSortBy = 'Balance';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
