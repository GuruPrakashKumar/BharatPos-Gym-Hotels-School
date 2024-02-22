// import 'api_v1.dart';
import 'package:shopos/src/models/membershipPlan_model.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:shopos/src/services/user.dart';

import '../models/product.dart';
import '../models/user.dart';

class SearchProductServices {
  Future<List<Product>> searchproduct(String catagory) async {
    final response =
        await ApiV1Service.getRequest('/inventory/me?keyword=$catagory');
    print('search=${response.data}');
    return (response.data["inventories"] as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MembershipPlanModel>> allPlans() async {
    final response =
        await ApiV1Service.postRequest('/membership/allPlans');
    return (response.data["allPlans"] as List)
        .map((e) => MembershipPlanModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> searchByExpiry(int days) async {
    final responseData = await UserService.me();
    final user = User.fromMap(responseData.data['user']);
    final userid = user.id;
    final response = await ApiV1Service.getRequest(
        '/inventory/$userid/expiring/$days');
    print('search=${response.data}');
    return response.data["expiringItems"] != null
        ? (response.data["expiringItems"] as List)
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList()
        : [];
  }
}
