import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopos/src/models/membershipPlan_model.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/product_availability_service.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

import '../services/global.dart';

class ProductCardHorizontal extends StatefulWidget {
  final MembershipPlanModel membership;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback? reduceQuantity;
  final VoidCallback? addQuantity;
  final int selectQuantity;
  final bool? isSelecting;
  int color;
  OrderType type;
  Function onTap;
  ProductCardHorizontal({
    Key? key,
    required this.membership,
    required this.onDelete,
    required this.onEdit,
    required this.onCopy,
    this.isSelecting = false,
    required this.type,
    this.addQuantity,
    this.reduceQuantity,
    this.selectQuantity = 0,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ProductCardHorizontal> createState() => _ProductCardHorizontalState();
}

class _ProductCardHorizontalState extends State<ProductCardHorizontal> {
  int selectFlag = 0;
  String? errorText;
  bool tapflag = false;
  bool onTapOutsideWillWork = false;
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          print("select flag on tap= $selectFlag");
          widget.onTap(selectFlag);
          setState(() {});
          if(selectFlag==1){
            selectFlag = 0;
          }else{
            selectFlag = 1;
          }

      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.33,
        child: Card(
          color: Color(widget.color).withOpacity(1),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Color(widget.color), // Set the border color
              width: 5.0, // Set the border width
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.55,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                child: Text(
                                  widget.membership.plan ?? "",
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PopupMenuButton<int>(
                                  child: const Icon(Icons.more_vert_rounded),
                                  onSelected: (int e) {
                                    if (e == 0) {
                                      widget.onEdit();
                                    } else if (e == 1) {
                                      widget.onDelete();
                                    } else if(e == 2) {
                                      widget.onCopy();
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuItem<int>>[
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 2,
                                        child: Text('Copy'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                                    ];
                                  },
                                ),
                              ),
                            ),
                          )

                        ],
                      ),
                      Divider(color: Colors.black54),
                      Container(
                        width: MediaQuery.of(context).size.width/2.30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: widget.membership.gstRate != null,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Price'),
                                      Text('₹ ${widget.membership.basePrice == "null" ? widget.membership.sellingPrice : widget.membership.basePrice}'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('GST @${widget.membership.gstRate}%'),
                                      Text('₹ ${widget.membership.igst == "null" ? "0" : double.parse(widget.membership.igst!).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Net Price'),
                                Text(
                                  ' ₹ ${widget.membership.sellingPrice!.toStringAsFixed(2) ?? 0.0}',
                                  maxLines: 1,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Visibility(
                              visible: widget.membership.validity != null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Validity'),
                                  Text(
                                    '${widget.membership.validity.toString()}',
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
}

class ProductCardPurchase extends StatefulWidget {
  final MembershipPlanModel membership;
  final VoidCallback onDelete;
  final String? type;
  String discount;
  ProductCardPurchase({Key? key, required this.membership,required this.onDelete, this.discount = "", this.type}) : super(key: key);

  @override
  State<ProductCardPurchase> createState() => _ProductCardPurchaseState();
}

class _ProductCardPurchaseState extends State<ProductCardPurchase> {
  double baseSellingPrice = 0;
  double Sellinggstvalue = 0;
  double SellingPrice = 0;
  bool onTapOutSideWillWork=false;
  double basePurchasePrice = 0;
  double Purchasegstvalue = 0;
  double PurchasePrice = 0;
  String? errorText;

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
  @override
  Widget build(BuildContext context) {

    print("widget.membership.gstRate is ${widget.membership.gstRate}");
    if (widget.type == "sale") {
      print("type is sale");
      if (widget.membership.gstRate != "null") {
        print("if part");

        baseSellingPrice = double.parse(widget.membership.basePrice!);
        Sellinggstvalue = double.parse(widget.membership.igst!);
      }else if (widget.membership.gstRate == "null") {
        print("else part");
        baseSellingPrice = widget.membership.sellingPrice!;
      }
      SellingPrice = widget.membership.sellingPrice!;
    }
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(onPressed: (){
              widget.onDelete();
            }, icon: Icon(Icons.delete, color: Colors.red,)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2.25,
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              widget.membership.plan ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black54,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount'),
                        (widget.type == "sale" ||widget.type == "estimate") ? Text('₹ ${(baseSellingPrice + double.parse(widget.discount)).toStringAsFixed(2)}') : Text('₹ ${basePurchasePrice}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount '),
                        Text('₹ ${widget.discount}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Subtotal'),
                        (widget.type == "sale" ||widget.type == "estimate") ? Text('₹ ${baseSellingPrice}') : Text('₹ ${basePurchasePrice}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax GST @${widget.membership.gstRate == "null" ? "0" : widget.membership.gstRate}%'),
                        (widget.type == "sale" ||widget.type == "estimate") ? Text('₹ ${Sellinggstvalue}') : Text('₹ ${Purchasegstvalue}'),
                      ],
                    ),
                    const SizedBox(height: 5),

                    Divider(
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Total'),
                        (widget.type == "sale" ||widget.type == "estimate")
                            ? Text(
                                '₹ ${SellingPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Text(
                                '₹ ${PurchasePrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
