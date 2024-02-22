import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/membershipPlanInput.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/api_v1.dart';

import '../models/membershipPlan_model.dart';

class ProductService {
  const ProductService();

  Future<Response> createPlan(MembershipPlanInput input) async {
    print("line 20 in product.dart");
    print("FormInput:");
    print(input.toMap());

    var dataToSend = input.toMap();
    final response =
        await ApiV1Service.postRequest('/membership/new', data: dataToSend);
    print(response.data);
    return response;
  }

  ///
  Future<Response> updatePlan(MembershipPlanInput input) async {
    print("last sec");
    print(input.toMap());
    var dataToSend = input.toMap();
    final response = await ApiV1Service.putRequest(
      '/membership/${input.id}',
      data: dataToSend,
    );
    return response;
  }

  Future<Response> getAllPlans() async {
    final response =
        await ApiV1Service.postRequest('/membership/allPlans');
    print("response is $response");
    return response;
  }

  Future<Response> getPlan(String id) async {
    final response = await ApiV1Service.getRequest('/membership/$id');
    return response;
  }

  ///
  Future<Response> getProduct(String id) async {
    final response = await ApiV1Service.getRequest('/inventory/$id');
    return response;
  }

  /// Fetch Product by barcode
  Future<Response> getProductByBarcode(String barcode) async {
    return await ApiV1Service.getRequest('/inventory/barcode/$barcode');
  }

  ///
  Future<Response> searchProducts(String keyword) async {
    var response =
        await ApiV1Service.getRequest('/inventory/me?keyword=$keyword');
    print(response.data);
    return response;
  }

  ///
  Future<Response> deletePlan(MembershipPlanModel plan) async {
    final response =
        await ApiV1Service.deleteRequest('/membership/${plan.id}');
    return response;
  }
}
