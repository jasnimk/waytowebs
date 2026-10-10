import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple Zoho CRM service for dealer verification
/// Handles OAuth token refresh and API calls
class ZohoService {
  // Zoho credentials (India data center - CRM + Books access)
  static const String _clientId = '1000.Z2WV6AMXSQ6OESCUAT4D6K8ILH2I8Q';
  static const String _clientSecret = 'bbdf331d22e5a1dadff7a63e2eb66a3684b5bcbf54';
  static const String _refreshToken = '1000.022cc784602a34c5e5434a5d6310b39e.c1231e2ec20c4104c627b4070edef356';

  static const String _accountsUrl = 'https://accounts.zoho.in';
  static const String _apiUrl = 'https://www.zohoapis.in/crm/v3';
  static const String _booksApiUrl = 'https://www.zohoapis.in/books/v3';
  static const String _organizationId = '60091505026';

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Get a valid access token (refreshes if expired)
  Future<String> _getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    // Refresh token
    final response = await http.post(
      Uri.parse('$_accountsUrl/oauth/v2/token'),
      body: {
        'refresh_token': _refreshToken,
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: 3500)); // Expire before actual expiry
      return _accessToken!;
    } else {
      throw Exception('Failed to refresh Zoho token: ${response.body}');
    }
  }

  /// Verify if a dealer exists and is verified in Zoho CRM
  /// Returns dealer data if found and verified, null otherwise
  Future<Map<String, dynamic>?> verifyDealer(String phoneNumber) async {
    try {
      final token = await _getAccessToken();

      // Search for dealer by phone number
      final response = await http.get(
        Uri.parse('$_apiUrl/Contacts/search?phone=$phoneNumber'),
        headers: {
          'Authorization': 'Zoho-oauthtoken $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if dealer found
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final dealer = data['data'][0];

          // Check if verified
          final isVerified = dealer['Dealer_Verified'] == true;

          if (isVerified) {
            return {
              'id': dealer['id'],
              'name': dealer['Full_Name'],
              'email': dealer['Email'],
              'phone': dealer['Phone'],
              'credit_30_enabled': dealer['Credit_30_Days_Enabled_1'] == true,
              'credit_90_enabled': dealer['Credit_90_Days_Enabled'] == true,
              'credit_limit': dealer['Credit_Limit'],
              'status': dealer['Dealer_Status'],
            };
          }
        }
      } else if (response.statusCode == 204) {
        // No content - dealer not found
        return null;
      }

      return null;
    } catch (e) {
      print('Error verifying dealer: $e');
      return null;
    }
  }

  /// Sync products from Zoho Books/Workbooks
  /// Returns list of products with complete details
  Future<Map<String, dynamic>> syncProductsFromZoho() async {
    try {
      print('🔄 Starting Zoho Books sync...');

      final token = await _getAccessToken();
      print('✅ Got access token');

      // Zoho Books Items API
      final url = '$_booksApiUrl/items?organization_id=$_organizationId';
      print('📡 Calling: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Zoho-oauthtoken $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Zoho Books response: ${data.keys}');

        final items = (data['items'] as List? ?? []);
        print('📦 Found ${items.length} items in Zoho Books');

        // Transform Zoho items to our product format
        final products = items.map((item) {
          return {
            'id': item['item_id']?.toString() ?? '',
            'name': item['name']?.toString() ?? 'Unnamed Product',
            'sku': item['sku']?.toString() ?? '',
            'description': item['description']?.toString() ?? '',
            'customer_price': _parsePrice(item['rate']),
            'dealer_price': _parsePrice(item['purchase_rate']) > 0
                ? _parsePrice(item['purchase_rate'])
                : _parsePrice(item['rate']) * 0.8, // 20% discount if no purchase rate
            'stock': item['stock_on_hand'] ?? 0,
            'category': item['category_name']?.toString() ?? 'Uncategorized',
            'image_url': item['image_url']?.toString() ?? '',
          };
        }).toList();

        print('✅ Sync completed: ${products.length} products transformed');

        return {
          'success': true,
          'products': products,
          'count': products.length,
          'synced_at': DateTime.now().toIso8601String(),
          'source': 'zoho_books',
        };
      } else {
        print('❌ Zoho Books API error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'error': 'API returned ${response.statusCode}: ${response.body}',
          'products': [],
          'count': 0,
        };
      }
    } catch (e) {
      print('❌ Error syncing products from Zoho: $e');
      return {
        'success': false,
        'error': e.toString(),
        'products': [],
        'count': 0,
      };
    }
  }

  /// Helper to safely parse price values
  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Get mock products for testing (DEPRECATED - use syncProductsFromZoho)
  @Deprecated('Use syncProductsFromZoho() instead')
  Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await syncProductsFromZoho();
    return result['success'] == true
        ? List<Map<String, dynamic>>.from(result['products'])
        : [];
  }
}
