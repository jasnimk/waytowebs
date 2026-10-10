import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Zoho Workbook API Integration Service
/// Handles product sync, dealer verification, and order management
class ZohoService {
  final Dio _dio;

  // Zoho API endpoints
  static const String _baseUrl = 'https://analyticsapi.zoho.com/restapi/v2/bulk';
  static const String _authUrl = 'https://accounts.zoho.com/oauth/v2';

  // These should be loaded from environment variables or secure storage
  late String _clientId;
  late String _clientSecret;
  late String _refreshToken;
  late String _workspaceId;
  late String _productsViewId;
  late String _dealersViewId;
  late String _ordersViewId;

  String? _accessToken;
  DateTime? _tokenExpiry;

  ZohoService(this._dio);

  /// Initialize Zoho service with credentials
  void initialize({
    required String clientId,
    required String clientSecret,
    required String refreshToken,
    required String workspaceId,
    required String productsViewId,
    required String dealersViewId,
    required String ordersViewId,
  }) {
    _clientId = clientId;
    _clientSecret = clientSecret;
    _refreshToken = refreshToken;
    _workspaceId = workspaceId;
    _productsViewId = productsViewId;
    _dealersViewId = dealersViewId;
    _ordersViewId = ordersViewId;

    AppLogger.info('Zoho service initialized');
  }

  /// Get or refresh access token
  Future<String> _getAccessToken() async {
    // If token is still valid, return it
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    AppLogger.info('Refreshing Zoho access token');

    try {
      final response = await _dio.post(
        '$_authUrl/token',
        data: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': _refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      _accessToken = response.data['access_token'];
      final expiresIn = response.data['expires_in'] as int; // seconds
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // Refresh 1 min early

      AppLogger.success('Zoho access token refreshed');
      return _accessToken!;
    } catch (e) {
      AppLogger.error('Failed to refresh Zoho access token', e);
      rethrow;
    }
  }

  /// Fetch all products from Zoho Workbook
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final token = await _getAccessToken();

      AppLogger.info('Fetching products from Zoho');

      final response = await _dio.get(
        '$_baseUrl/workspaces/$_workspaceId/views/$_productsViewId/data',
        options: Options(
          headers: {
            'Authorization': 'Zoho-oauthtoken $token',
          },
        ),
      );

      final data = response.data['data'] as List;
      AppLogger.success('Fetched ${data.length} products from Zoho');

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to fetch products from Zoho', e);
      rethrow;
    }
  }

  /// Verify if dealer exists and is approved in Zoho
  Future<Map<String, dynamic>?> verifyDealer(String phoneNumber) async {
    try {
      final token = await _getAccessToken();

      AppLogger.info('Verifying dealer: $phoneNumber');

      final response = await _dio.get(
        '$_baseUrl/workspaces/$_workspaceId/views/$_dealersViewId/data',
        queryParameters: {
          'criteria': "phone_number='$phoneNumber'",
        },
        options: Options(
          headers: {
            'Authorization': 'Zoho-oauthtoken $token',
          },
        ),
      );

      final data = response.data['data'] as List;

      if (data.isEmpty) {
        AppLogger.warning('Dealer not found in Zoho: $phoneNumber');
        return null;
      }

      AppLogger.success('Dealer verified: $phoneNumber');
      return data.first as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to verify dealer', e);
      rethrow;
    }
  }

  /// Update stock quantity in Zoho after order
  Future<bool> updateProductStock(String productId, int newQuantity) async {
    try {
      final token = await _getAccessToken();

      AppLogger.info('Updating stock for product: $productId to $newQuantity');

      final response = await _dio.post(
        '$_baseUrl/workspaces/$_workspaceId/views/$_productsViewId/rows',
        data: {
          'updateColumn': 'product_id',
          'updateValue': productId,
          'columns': {
            'stock_quantity': newQuantity,
            'last_updated': DateTime.now().toIso8601String(),
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Zoho-oauthtoken $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      AppLogger.success('Stock updated in Zoho for product: $productId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to update stock in Zoho', e);
      return false;
    }
  }

  /// Push order to Zoho Workbook
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final token = await _getAccessToken();

      AppLogger.info('Creating order in Zoho: ${orderData['order_number']}');

      final response = await _dio.post(
        '$_baseUrl/workspaces/$_workspaceId/views/$_ordersViewId/rows',
        data: {
          'rows': [orderData],
        },
        options: Options(
          headers: {
            'Authorization': 'Zoho-oauthtoken $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final zohoOrderId = response.data['data']?[0]?['id']?.toString();

      if (zohoOrderId != null) {
        AppLogger.success('Order created in Zoho: $zohoOrderId');
      }

      return zohoOrderId;
    } catch (e) {
      AppLogger.error('Failed to create order in Zoho', e);
      return null;
    }
  }

  /// Update order status in Zoho
  Future<bool> updateOrderStatus(String zohoOrderId, String status) async {
    try {
      final token = await _getAccessToken();

      AppLogger.info('Updating order status in Zoho: $zohoOrderId to $status');

      await _dio.post(
        '$_baseUrl/workspaces/$_workspaceId/views/$_ordersViewId/rows',
        data: {
          'updateColumn': 'order_id',
          'updateValue': zohoOrderId,
          'columns': {
            'order_status': status,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Zoho-oauthtoken $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      AppLogger.success('Order status updated in Zoho: $zohoOrderId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to update order status in Zoho', e);
      return false;
    }
  }
}
