import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/services/api_v1.dart';

class SalesService {
  const SalesService();

  static Future<Response> payDue(Order orderItemInput, String invoiceNum) async {
    final response = await ApiV1Service.postRequest(
      '/membership/payDue',
      data: {
        'paymentDate': DateTime.now().toString(),
        'membership': orderItemInput.orderItems?[0].membership?.id,
        'orderItems': orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'total': orderItemInput.orderItems?.fold<double>(0, (acc, curr) {
          return curr.membership!.sellingPrice! + acc;
        }),
        'party': orderItemInput.party?.id,
        'invoiceNum': invoiceNum,
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'gst': orderItemInput.gst,
      },
    );
    print("response.data from payDue");
    print(response.data);
    return response;
  }

  ///
  static Future<Response> createSalesOrder(
    Order orderItemInput,
    String invoiceNum,
  ) async {
    var dataSent = {
      'paymentDate': DateTime.now().toString(),
      'membership': orderItemInput.orderItems?[0].membership?.id,
      'orderItems': orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
      'modeOfPayment': orderItemInput.modeOfPayment,
      'total': orderItemInput.orderItems?.fold<double>(0, (acc, curr) {
        return curr.membership!.sellingPrice! + acc;
      }),
      'party': orderItemInput.party?.id,
      'invoiceNum': int.parse(invoiceNum),
      'reciverName': orderItemInput.reciverName,
      'businessName': orderItemInput.businessName,
      'businessAddress': orderItemInput.businessAddress,
      'gst': orderItemInput.gst,
    };
    
    print("data json is : ${jsonEncode(dataSent)}");
    final response = await ApiV1Service.postRequest(
      '/membership/sell',
      data: {
        'paymentDate': DateTime.now().toString(),
        'membership': orderItemInput.orderItems?[0].membership?.id,
        'orderItems': orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'total': orderItemInput.orderItems?.fold<double>(0, (acc, curr) {
          return curr.membership!.sellingPrice! + acc;
        }),
        'party': orderItemInput.party?.id,
        'invoiceNum': invoiceNum,
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'gst': orderItemInput.gst,
      },
    );
    print("line 37 in sales.dart");
    print(response.data);
    return response;
  }
  static Future<Map<String, dynamic>> getNumberOfSales() async {
    final response = await ApiV1Service.getRequest('/salesNum');
    print("sales num is ${response.data}");
    return response.data;
  }
  ///
  static Future<Response> getAllSalesOrders() async {
    final response = await ApiV1Service.getRequest('/salesOrders/me');
    return response;
  }
  static Future<Map<String, dynamic>> getSingleSaleOrder(String invoiceNum) async {
    final response = await ApiV1Service.getRequest('/salesOrder/$invoiceNum');
    print("line 65 in sales.dart");
    print(response.data);
    return response.data;
  }
}
