/// Configuración centralizada de la API
/// 
/// Este archivo contiene las constantes de configuración
/// para la comunicación con el backend.
class ApiConfig {
  // URL base de la API
  static const String baseUrl = 'http://localhost:3000/api';
  
  // URL base para Android Emulator (usa 10.0.2.2 en lugar de localhost)
  static const String androidBaseUrl = 'http://10.0.2.2:3000/api';
  
  // Versión de la API
  static const String apiVersion = 'v1';
  
  // Timeout para peticiones HTTP
  static const Duration timeout = Duration(seconds: 30);
  
  // Timeout para conexión
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Reintentos para peticiones fallidas
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
