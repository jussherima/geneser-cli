import 'package:{{project_name}}/src/exceptions/app_exception_code.dart';
sealed class AppException implements Exception { final AppExceptionCode code; final String message; AppException(this.code, this.message); @override String toString() => message; }
class UnauthenticatedException extends AppException { UnauthenticatedException(): super(AppExceptionCode.unauthenticated, 'Unauthenticated'); }
class NetworkException extends AppException { NetworkException(): super(AppExceptionCode.network, 'Network error'); }
class DataNotFoundException extends AppException { DataNotFoundException([String? m]): super(AppExceptionCode.dataNotFound, m ?? 'Data not found'); }
class WrongUniqueCodeException extends AppException { WrongUniqueCodeException(): super(AppExceptionCode.wrongUniqueCode, 'Wrong code'); }
