class ApiExceptionCustom implements Exception {
  final ApiExcpetionCode code;
  final String msg;
  ApiExceptionCustom({required this.code, required this.msg});
  
}

enum ApiExcpetionCode{
  locationNotEnabled,
   locationPermissionDenied,
   locationPermissionDeniedPermenant

}
