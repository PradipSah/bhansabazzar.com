import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/error_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ApiErrorHandler {
  static dynamic getMessage(dynamic error) {
    dynamic errorDescription = "";

    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request to API server was cancelled";
              break;

            case DioExceptionType.connectionTimeout:
              errorDescription = "Connection timeout with API server";
              break;

            case DioExceptionType.sendTimeout:
              errorDescription = "Send timeout";
              break;

            case DioExceptionType.receiveTimeout:
              errorDescription =
                  "Receive timeout in connection with API server";
              break;

            case DioExceptionType.transformTimeout:
              errorDescription = "Response transform timeout";
              break;

            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  if (error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse =
                        ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else {
                    errorDescription = error.response?.data['message'] ?? '';
                  }
                  break;

                case 401:
                  Provider.of<AuthController>(
                    Get.context!,
                    listen: false,
                  ).clearSharedData();

                  if (error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse =
                        ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else {
                    errorDescription = error.response!.data['message'];
                  }
                  break;

                case 403:
                  if (error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse =
                        ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else {
                    errorDescription = error.response!.data['message'];
                  }

                  if (kDebugMode) {
                    print("=================403=============>>$errorDescription");
                    print("=================403=============>>${error.response!.data}");
                  }
                  break;

                case 404:
                  errorDescription = "Resource not found";
                  break;

                case 422:
                  if (error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse =
                        ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else {
                    errorDescription = error.response?.data['message'] ?? '';
                  }
                  break;

                case 429:
                  errorDescription =
                      error.response?.statusMessage ?? "Too many requests";
                  break;

                case 500:
                  if (kDebugMode) {
                    print(
                        "-----------500------------->>${error.response!.data}");
                  }
                  errorDescription = "Internal server error";
                  break;

                case 503:
                  if (error.response!.data['message'] != null) {
                    errorDescription = error.response!.data['message'];
                  } else {
                    errorDescription = "Service unavailable";
                  }
                  break;

                default:
                  try {
                    ErrorResponse errorResponse =
                        ErrorResponse.fromJson(error.response!.data);

                    if (errorResponse.errors != null &&
                        errorResponse.errors!.isNotEmpty) {
                      errorDescription = errorResponse.errors![0].message;
                    } else {
                      errorDescription =
                          "Failed to load data - Status code: ${error.response!.statusCode}";
                    }
                  } catch (_) {
                    errorDescription =
                        "Failed to load data - Status code: ${error.response!.statusCode}";
                  }
              }
              break;

            case DioExceptionType.badCertificate:
              errorDescription = "Bad SSL certificate";
              break;

            case DioExceptionType.connectionError:
              errorDescription = "Connection error";
              break;

            case DioExceptionType.unknown:
              errorDescription = "Unexpected error occurred";
              break;
          }
        } else {
          errorDescription = "Unexpected error occurred";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "Is not a subtype of Exception";
    }

    return errorDescription;
  }
}