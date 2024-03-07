import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopos/src/models/input/membershipPlanInput.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/product.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_icons.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/custom_text_field2.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import 'package:shopos/src/widgets/custom_date_picker.dart';
// import 'package:intl/intl.dart';

import '../blocs/product/product_cubit.dart';
import '../models/product.dart';
import '../services/search_service.dart';

class CreatePlanArgs {
  final String? id;
  final bool? isCopy;
  CreatePlanArgs({this.id, this.isCopy});
}

class CreatePlan extends StatefulWidget {
  static const String routeName = '/create-plan';
  CreatePlanArgs? args;
  CreatePlan({Key? key, this.args}) : super(key: key);

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  late final MembershipCubit _productCubit;
  final _formKey = GlobalKey<FormState>();
  late MembershipPlanInput _formInput;
  final AudioCache _audioCache = AudioCache();
  late final ImagePicker _picker;
  bool _showLoader = false;
  bool gstSwitch = false;
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController gstratePriceController = TextEditingController();
  TextEditingController baseSellingPriceController = TextEditingController();

  final List<GlobalKey> _keys = [];
  final ScrollController _scrollController = ScrollController();
  final SearchProductServices searchProductServices = SearchProductServices();
  int includedExcludedRadioButton = 1;
  String additionalInformation = "";

  ///
  @override
  void initState() {
    super.initState();
    _formInput = MembershipPlanInput();
    _productCubit = MembershipCubit();
    _picker = ImagePicker();
    _fetchProductData();
    _productCubit.gst();
  }

  void _fetchProductData() async {
    MembershipPlanInput? membershipInput;
    if (widget.args?.id == null) {
      return;
    }
    try {
      final response =
          await ProductService().getPlan(widget.args!.id!);
      print("fetching product data in line 73 in createproduct");
      print(response.toString());
      membershipInput = MembershipPlanInput.fromMap(response.data['membership']);
    } on DioError catch (err) {
      log(err.message.toString());
    }
    if (membershipInput == null) {
      return;
    }
    setState(() {
      _formInput = membershipInput!;
      if (widget.args?.isCopy != null && widget.args?.isCopy == true) {
        //if user wants to copy the product
        _formInput.id = null;
        _formInput.plan = "${_formInput.plan} (copy)";
      }
    });
    setState(() {
      _formInput = membershipInput!;
    });

    if (_formInput.GSTincluded != null) if (_formInput.GSTincluded!) {
      includedExcludedRadioButton = 1;
    } else {
      includedExcludedRadioButton = 2;
    }

    print("gstttt");
    print(_formInput.gstRate);
    print(_formInput.gst);
    if (_formInput.gstRate != null && _formInput.gstRate != "null" && _formInput.gstRate != "") {
      _formInput.gst = true;
      gstSwitch = true;
    }
    sellingPriceController.text = _formInput.sellingPrice as String;

    setState(() {});

    gstratePriceController.text = _formInput.gstRate != "null" ? _formInput.gstRate as String : "";

    baseSellingPriceController.text = _formInput.basePrice != "null" && _formInput.basePrice != ""
                                          ? _formInput.basePrice!
                                          : "0";
    calculate();
  }

  @override
  void dispose() {
    _productCubit.close();
    _audioCache.clearAll();
    super.dispose();
  }


  void calculate() {
    if (_formInput.gstRate != "null" && _formInput.gst) {
      int rate = int.parse(_formInput.gstRate!);

// selling price
      if (_formInput.sellingPrice != null && includedExcludedRadioButton == 1) {
        print("gggggggggg");
        double oldsp = double.parse(_formInput.sellingPrice!);
        double basesp = (oldsp * 100 / (100 + rate));

        String sgst = ((oldsp - basesp) / 2).toStringAsFixed(2);
        String cgst = ((oldsp - basesp) / 2).toStringAsFixed(2);
        String igst = (oldsp - basesp).toStringAsFixed(2);
        setState(() {
          _formInput.sgst = sgst.toString();
          _formInput.cgst = cgst.toString();
          _formInput.igst = igst.toString();
          _formInput.basePrice = basesp.toStringAsFixed(2).toString();
        });

        baseSellingPriceController.text = basesp.toStringAsFixed(2).toString();
      }
      if (includedExcludedRadioButton == 2) {
        double bsp = double.parse(_formInput.basePrice!);
        double gstRate = double.parse(_formInput.gstRate!);

        double gstAmt = (bsp * (gstRate / 100));
        _formInput.sellingPrice = (bsp + gstAmt).toString();

        double oldsp = double.parse(_formInput.sellingPrice!);

        String sgst = ((oldsp - bsp) / 2).toStringAsFixed(2);
        String cgst = ((oldsp - bsp) / 2).toStringAsFixed(2);
        String igst = (oldsp - bsp).toStringAsFixed(2);

        _formInput.sgst = sgst.toString();
        _formInput.cgst = cgst.toString();
        _formInput.igst = igst.toString();

        sellingPriceController.text =
            (bsp + gstAmt).toStringAsFixed(2).toString();

        setState(() {});
      }
    }

    var temp = _formInput;
    _formInput = temp;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Plan'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CustomTextField(
                      label: "Plan Name",
                      value: _formInput.plan,
                      onChanged: (e) {
                        _formInput.plan = e;
                      },
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Please enter plan name";
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Additional Information",
                      onChanged: (e) {
                        additionalInformation = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField2(
                      readonly:
                          includedExcludedRadioButton == 2 ? true : false,
                      controller: sellingPriceController,
                      label: "Selling Price",
                      value: _formInput.sellingPrice,
                      inputType: TextInputType.number,
                      onChanged: (e) {
                        if (e.isNotEmpty &&
                            includedExcludedRadioButton == 1) {
                          _formInput.sellingPrice = e;
                          calculate();
                        }
                      },
                      validator: (e) {
                        if (e!.contains(",")) {
                          return '(,) characters are not allowed';
                        }
                        if (e.isEmpty) {
                          return "Please enter selling price";
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                            value: gstSwitch,
                            onChanged: (value) {
                              setState(() {
                                gstSwitch = value;
                                _formInput.gst = true;
                              });
                            }),
                        VerticalDivider(),
                        !gstSwitch
                            ? Text(
                                "GST Details",
                                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.black12,fontWeight: FontWeight.normal),
                              )
                            : Text(
                                "GST Details",
                                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.black,fontWeight: FontWeight.normal),)
                      ],
                    ),
                    Visibility(
                      visible: gstSwitch,
                      child: Column(
                        children: [
                          const Divider(color: Color.fromRGBO(0, 0, 0, 0)),
                          Row(
                            children: [
                              RadioMenuButton(
                                  value: 1,
                                  groupValue: includedExcludedRadioButton,
                                  onChanged: (val) {
                                    if (includedExcludedRadioButton == 2) {
                                      _formInput.GSTincluded = true;
                                      sellingPriceController.text = baseSellingPriceController.text;
                                      _formInput.sellingPrice = baseSellingPriceController.text;

                                      baseSellingPriceController.text = "";
                                      setState(() {
                                        includedExcludedRadioButton = 1;
                                      });
                                      calculate();
                                    }
                                  },
                                  child: Text("Included")),
                              RadioMenuButton(
                                  value: 2,
                                  groupValue: includedExcludedRadioButton,
                                  onChanged: (val) {
                                    if (includedExcludedRadioButton == 1) {
                                      _formInput.GSTincluded = false;
                                      baseSellingPriceController.text =
                                          sellingPriceController.text;
                                      _formInput.basePrice =
                                          sellingPriceController.text;
                                      //  sellingPriceController.text="";

                                      setState(() {
                                        includedExcludedRadioButton = 2;
                                      });
                                      calculate();
                                    }
                                  },
                                  child: Text("Excluded"))
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),

                          CustomTextField2(
                            controller: gstratePriceController,
                            label: "GST Rate (%)",
                            value: _formInput.gstRate != "null"
                                ? _formInput.gstRate
                                : "0",
                            inputType: TextInputType.number,
                            onChanged: (e) {
                              _formInput.gstRate = e;

                              setState(() {});
                              calculate();
                            },
                            validator: (e) {
                              if (gstSwitch && e!.isEmpty) return "Enter Rate";
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField2(
                            controller: baseSellingPriceController,
                            readonly:
                                includedExcludedRadioButton == 1 ? true : false,
                            label: "Base Selling Price",
                            value: _formInput.basePrice == "null"
                                ? "0"
                                : _formInput.basePrice,
                            onChanged: (e) {
                              if (includedExcludedRadioButton == 2) {
                                _formInput.basePrice = e;

                                setState(() {});
                                calculate();
                              }
                            },
                            validator: (e) => null,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: 'Validity',
                      value: _formInput.validity,
                      inputType: TextInputType.number,
                      onChanged: (e) {
                        _formInput.validity = e;
                      },
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Please enter validity";
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent, height: 40),
                    CustomButton(
                      title: "Save",
                      onTap: () async {
                        _formKey.currentState?.save();

                        if (_formKey.currentState?.validate() ?? false) {
                          _formInput.plan = "${_formInput.plan} $additionalInformation";
                          print("gstswitch is $gstSwitch includedExcludedRadioButton is $includedExcludedRadioButton and _form.gstincluded is ${_formInput.GSTincluded}");
                          if(gstSwitch && includedExcludedRadioButton==1) _formInput.GSTincluded = true;

                          _productCubit.createPlan(_formInput);
                          // Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ))));
  }


}
