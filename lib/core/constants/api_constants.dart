class ApiConstants {
  static const String baseUrl = 'https://www.pqstec.com/InvoiceApps/Values/';
  static const String imageBaseUrl = 'https://www.pqstec.com/InvoiceApps/';

  static const String loginEndpoint = 'LogIn';
  static const String customerListEndpoint = 'GetCustomerList';

  static const int defaultComId = 1;
  static const int defaultPageSize = 20;
  static const String defaultSortBy = 'Balance';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
