import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/membershipPlanInput.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/models/membershipPlan_model.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/product.dart';

part 'product_state.dart';

class MembershipCubit extends Cubit<MembershipState> {
  final ProductService _productService = const ProductService();
  MembershipCubit() : super(MembershipInitial());

  ///
/*  void getProducts(int i) async {
    emit(ProductLoading());
    final response = await _productService.getProducts();
    if ((response.statusCode ?? 400) > 300) {
      emit(MembershipError('Failed to get products'));
      return;
    }

    final products = List.generate(

      response.data['inventories'].length,
          (int index) => Product.fromMap(

        response.data['inventories'][index],
      ),
    );

    emit(MembershipListRender(products));
  }*/

  getPlan(String id) async {
    emit(MembershipLoading());
    final response = await _productService.getPlan(id);
    if ((response.statusCode ?? 400) > 300) {
      emit(MembershipError('Failed to get products'));
      return;
    }
    MembershipPlanModel membershipPlan = MembershipPlanModel.fromMap(response.data['membership']);
    return membershipPlan;
  }

  getAllPlans() async {
    emit(MembershipLoading());
    final response = await _productService.getAllPlans();
    // print("response.data iiis ${response.data['allPlans']}");
    if ((response.statusCode ?? 400) > 300) {
      emit(MembershipError('Failed to get products'));
      return;
    }

    final plans = List.generate(
      response.data['allPlans'].length,
      (int index) => MembershipPlanModel.fromMap(response.data['allPlans'][index]),
    );

    emit(MembershipListRender(plans));
  }

  ///
  void searchProducts(String pattern) async {
    emit(MembershipLoading());
    try {
      final response = await _productService.searchProducts(pattern);
      final data = response.data['allPlans'];
      final prods = List.generate(data.length, (int index) {
        return MembershipPlanModel.fromMap(data[index]);
      });
      emit(MembershipListRender(prods));
    } on DioError {
      emit(MembershipError('Failed to get products'));
    }
  }

  

  ///
  void createPlan(MembershipPlanInput input) async {
    emit(MembershipLoading());
    try {
      final response = input.id == null
          ? await _productService.createPlan(input)
          : await _productService.updatePlan(input);
      print(response);
      if ((response.statusCode ?? 400) > 300) {
        emit(MembershipError(response.data['message']));
        return;
      }
      emit(MembershipCreated());
    } on DioError catch (err) {
      // print("printing error");
      // print(err.response);
      emit(MembershipError(err.response?.data['message'] ?? err.message));
    }
  }

  ///
  void deletePlan(MembershipPlanModel plan) async {
    try {
      final response = await _productService.deletePlan(plan);
      if ((response.statusCode ?? 400) > 300) {
        emit(MembershipError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(MembershipError(err.message.toString()));
    }
    getAllPlans();
  }

  ///
  void gst() {
    emit(gstincludeoptionenable());
  }

  ///
  void calculategst() {
    emit(calculateallgst());
  }
}
