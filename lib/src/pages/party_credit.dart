import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/membershipPlan_model.dart';

import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;
import 'package:url_launcher/url_launcher.dart';

class ScreenArguments {
  final String partyId;
  final String partName;
  final String partyContactNo;
  final String? partyAddress;
  final String? guardianName;
  final int tabbarNo;

  ScreenArguments(this.partyId, this.partName, this.partyContactNo,
      this.tabbarNo, this.guardianName, this.partyAddress);
}

class PartyCreditPage extends StatefulWidget {
  final ScreenArguments args;
  static const routeName = '/party_credit';

  const PartyCreditPage({Key? key, required this.args}) : super(key: key);

  @override
  State<PartyCreditPage> createState() => _PartyCreditPageState();
}

class _PartyCreditPageState extends State<PartyCreditPage> {
  late final SpecificPartyCubit _specificpartyCubit;
  late Party _specificPartyInput;
  PinService _pinService = PinService();
  late final ReportCubit _reportCubit;
  final TextEditingController pinController = TextEditingController();

  User? user;
  @override
  void initState() {
    super.initState();
    _specificpartyCubit = SpecificPartyCubit();
    fetchdata();
    _specificPartyInput = Party();
    _reportCubit = ReportCubit();
  }

  void fetchdata() async {
    print("line 60 in party_credit");
    // widget.args.tabbarNo == 0 ? _specificpartyCubit.getInitialCreditHistory(widget.args.partyId) : _specificpartyCubit.getInitialpurchasedHistory(widget.args.partyId);
    widget.args.tabbarNo == 0
        ? _specificpartyCubit.getAllActiveMembership(widget.args.partyId)
        : _specificpartyCubit.getAllActiveMembership(widget.args.partyId);
    print("line 62 in party_credit");

    final response = await UserService.me();
    user = User.fromMap(response.data['user']);
    setState(() {});
  }

  @override
  void dispose() {
    _specificpartyCubit.close();
    _reportCubit.close();
    super.dispose();
  }

  void sort(List<Order> o) {
    for (int i = 0; i < o.length; i++) {
      for (int j = i + 1; j < o.length; j++) {
        String dateString = o[i].createdAt.toString();
        //  print("Date1:");
        //  print(dateString);

        DateTime dateTimei = DateTime.parse(dateString);

        String dateStringj = o[j].createdAt.toString();
        //  print("Date2:");
        //   print(dateStringj);

        DateTime dateTimej = DateTime.parse(dateStringj);

        if (dateTimej.isAfter(dateTimei)) {
          var temp = o[i];
          o[i] = o[j];
          o[j] = temp;
        }
      }
    }
  }

  TextEditingController value = TextEditingController();

  // String balanceToShareOnWhatsapp = "";
  bool whatsappButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/teamwork.png",
              height: 30,
            ),
            Column(
              children: [
                Text(
                  widget.args.partName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.args.partyContactNo,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(width: 30,)
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // if (balanceToShareOnWhatsapp == "" && whatsappButtonPresssed == true)
          //   Center(
          //     child: CircularProgressIndicator(
          //       valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
          //     ),
          //   ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: BlocBuilder<SpecificPartyCubit, SpecificPartyState>(
              bloc: _specificpartyCubit,
              builder: (context, state) {
                if (state is SpecificPartyListRender) {
                  var activeMemberships = state.activeMemberships;
                  // sort(orders);

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: activeMemberships.length,
                    itemBuilder: (BuildContext context, int index) {
                      final activeMem = activeMemberships[index];
                      // print("line 177 in party credit");
                      // print(order.createdAt);
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      "${activeMem.membership?.plan}",
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                        onTap: () {
                                          //this varibale is used to  show the circular progress indicator  when button is pressed
                                          // whatsappButtonPressed = true;
                                          setState(() {});
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            _launchUrl(
                                                user!.businessName!,
                                                "+91" +
                                                    widget.args.partyContactNo,
                                                activeMem.due!);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Image.asset(
                                            "assets/images/whats.png",
                                            height: 30,
                                            width: 30,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Container(
                                color: Colors.black,
                                height: 1,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Plan validity: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${activeMem.membership!.validity}",
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Last Paid: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${currentdate(activeMem.lastPaid!)}",
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Active Membership validity: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${activeMem.validity}",
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Active status: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${activeMem.activeStatus}",
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text("Due: ",style:TextStyle(fontWeight: FontWeight.bold),),
                                  Text(
                                    "${activeMem.due}",
                                  )
                                ],
                              ),
                              if(activeMem.due!>0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                      paddingOutside: 10,
                                      title: "Pay Due",
                                      onTap: () {
                                        _onTotalChange(activeMem.membership!, activeMem.due?.toStringAsFixed(2));
                                        Order order = Order(
                                            orderItems: [
                                              OrderItemInput(
                                                quantity: 1,
                                                price: activeMem.due,
                                                  membership: activeMem.membership)
                                            ],
                                            party: Party(
                                                id: widget.args.partyId,
                                                name: widget.args.partName,
                                                phoneNumber:
                                                    widget.args.partyContactNo,
                                                type: "customer",
                                                address:
                                                    widget.args.partyAddress,
                                                guardianName:
                                                    widget.args.guardianName)
                                            //todo: for bill like businessName etc (we have not sufficient data here for now)
                                            );
                                        Navigator.pushNamed(
                                            context, CheckoutPage.routeName,
                                            arguments: CheckoutPageArgs(
                                                invoiceType: OrderType.sale,
                                                order: order,
                                                payDue: true));
                                      }),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomAppBar(
      //   elevation: 100,
      //   color: Theme.of(context).scaffoldBackgroundColor,
      //   child: Container(
      //     height: 120,
      //     width: double.maxFinite,
      //     decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
      //     child: SingleChildScrollView(
      //       reverse: true,
      //       padding: const EdgeInsets.only(bottom: 20),
      //       child: Column(
      //         mainAxisSize: MainAxisSize.max,
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           BlocBuilder<SpecificPartyCubit, SpecificPartyState>(
      //             bloc: _specificpartyCubit,
      //             builder: (context, state) {
      //               double balance = 0;
      //               double negbalance = 0;
      //
      //               if (state is SpecificPartyListRender) {
      //                 balance = state.activeMemberships. ?? 0;
      //                 negbalance = balance * -1;
      //
      //                 Future.delayed(Duration(seconds: 3), () {
      //                   balanceToShareOnWhatsapp = balance.toString();
      //                   setState(() {});
      //                 });
      //               }
      //               return Padding(
      //                 padding: const EdgeInsets.only(left: 20),
      //                 child: balance >= 0
      //                     ? Row(
      //                         crossAxisAlignment: CrossAxisAlignment.center,
      //                         mainAxisAlignment: MainAxisAlignment.start,
      //                         children: [
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           const Text(
      //                             "Balance Due",
      //                             style: TextStyle(fontSize: 20),
      //                           ),
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           Text(
      //                             "₹ ${balance.toStringAsFixed(2)}",
      //                             style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
      //                           ),
      //                         ],
      //                       )
      //                     : Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                         children: [
      //                           const Text(
      //                             "Balance Advance",
      //                             textScaleFactor: 1.7,
      //                           ),
      //                           Text(
      //                             "${negbalance.toStringAsFixed(2)}",
      //                             textScaleFactor: 1.7,
      //                             style: const TextStyle(
      //                               color: Colors.green,
      //                               fontWeight: FontWeight.bold,
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //               );
      //             },
      //           ),
      //           Divider(),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //             children: [
      //               Card(
      //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Colors.green, width: 1)),
      //                 color: Color.fromRGBO(148, 255, 194, 100),
      //                 child: TextButton(
      //                   onPressed: () {
      //                     // modelOpen(context, "Settle");
      //                   },
      //                   child: Row(
      //                     children: [
      //                       Image.asset(
      //                         "assets/images/recieve.png",
      //                         height: 22,
      //                       ),
      //                       const Text(
      //                         "Received",
      //                         style: TextStyle(color: Color.fromRGBO(32, 150, 82, 100), fontSize: 19),
      //                       ),
      //                     ],
      //                   ),
      //                   style: ButtonStyle(
      //                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //                       const RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.all(Radius.circular(10)),
      //                       ),
      //                     ),
      //                     backgroundColor: MaterialStateProperty.all(
      //                       const Color.fromRGBO(255, 0, 0, 0),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               Card(
      //                 color: Color.fromRGBO(255, 209, 209, 10),
      //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Colors.red, width: 1)),
      //                 child: TextButton(
      //                   onPressed: () {
      //                     // modelOpen(context, "Credit");
      //                   },
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //                       SizedBox(
      //                         width: 15,
      //                       ),
      //                       Image.asset(
      //                         "assets/images/given.png",
      //                         height: 22,
      //                       ),
      //                       const Text(
      //                         "Given",
      //                         style: TextStyle(color: Colors.red, fontSize: 19),
      //                       ),
      //                       SizedBox(
      //                         width: 15,
      //                       ),
      //                     ],
      //                   ),
      //                   style: ButtonStyle(
      //                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //                       const RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.all(Radius.circular(10)),
      //                       ),
      //                     ),
      //                     backgroundColor: MaterialStateProperty.all(
      //                       const Color.fromRGBO(255, 0, 0, 0),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
  _onTotalChange(MembershipPlanModel membership, String? discountedPrice) {
    membership.sellingPrice = double.parse(discountedPrice!);
    // print(product.gstRate);

    double newBasePrice = (membership.sellingPrice! * 100.0) / (100.0 + double.parse(membership.gstRate == 'null' ? '0.0' : membership.gstRate!));

    membership.basePrice = newBasePrice.toString();

    double newGst = membership.sellingPrice! - newBasePrice;

    membership.igst = newGst.toStringAsFixed(2);

    membership.cgst = (newGst / 2).toStringAsFixed(2);
    // print(product.salecgst);

    membership.sgst = (newGst / 2).toStringAsFixed(2);
    // print(product.salesgst);
  }

  Future<void> _launchUrl(String name, String mobile, double due) async {
    String Message =
        "Dear customer, your credit balance with ${name} is rupees ${due.abs().toStringAsFixed(2)}. Please pay the amount as soon as possible. Thank you for your business.%0A%0A*Powered by BharatPOS*";

    final Uri _url = Uri.parse('https://wa.me/${mobile}?text=$Message');

    if (await canLaunchUrl(_url)) {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $_url');
    }
  }

// add settle and credit
//   modelOpen(context, String modeofPayment) {
//     return showModalBottomSheet(
//         isScrollControlled: true,
//         elevation: 5,
//         context: context,
//         builder: (BuildContext context) {
//           return SingleChildScrollView(
//             reverse: true,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: Container(
//                 decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const Text("Enter Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                     Padding(
//                       padding: const EdgeInsets.all(30),
//                       child: Container(
//                         decoration: BoxDecoration(border: Border.all(color: Colors.black38), borderRadius: BorderRadius.circular(10)),
//                         child: TextField(
//                           textAlign: TextAlign.center,
//                           keyboardType: TextInputType.number,
//                           controller: value,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                               hintText: "₹",
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: 2,
//                                 horizontal: 10,
//                               ),
//                               border: InputBorder.none),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 250,
//                       child: CustomButton(
//                         onTap: () {
//                           setState(() {
//                             print("line 494 in party credit");
//                             _specificPartyInput.modeOfPayment = modeofPayment;
//                             print("modeofPayment in line 497 is $modeofPayment");
//                             _specificPartyInput.total = double.parse(value.text);
//                             _specificPartyInput.id = widget.args.partyId;
//                             _specificPartyInput.createdAt = DateTime.now();
//
//                             value.clear();
//                           });
//                           if (widget.args.tabbarNo == 0) {
//                             print("line 502 in party credit");
//                             _specificpartyCubit.updateCreditHistory(_specificPartyInput);
//                           } else {
//                             print("line 505 in party credit");
//                             _specificpartyCubit.updatepurchaseHistory(_specificPartyInput);
//                           }
//                           Navigator.pop(context);
//                         },
//                         title: "    Confirm    ",
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }

// update settle and credit model
//   modelOpenUpdate(context, String id, String amount, List<Map<String,dynamic>> type) {
//     String newtotal = amount.toString();
//     return showModalBottomSheet(
//         barrierColor: Colors.transparent,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext context) {
//           return SingleChildScrollView(
//             reverse: true,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: Container(
//                 decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const Text("Enter Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
//                     Padding(
//                       padding: const EdgeInsets.all(30),
//                       child: Container(
//                         decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//                         child: TextFormField(
//                             textAlign: TextAlign.center,
//                             keyboardType: TextInputType.number,
//                             initialValue: amount,
//                             decoration: const InputDecoration(
//                               hintText: "₹",
//                             ),
//                             onChanged: (e) {
//                               setState(() {
//                                 newtotal = e;
//                               });
//                             }),
//                       ),
//                     ),
//                     CustomButton(
//                       onTap: () {
//                         double amountnew = double.parse(newtotal);
//
//                         widget.args.tabbarNo == 0
//                             ? _specificpartyCubit.updateAmountCustomer(id, amountnew, widget.args.partyId)
//                             : _specificpartyCubit.updateAmountSupplier(id, amountnew, widget.args.partyId);
//
//                         Navigator.pop(context);
//                       },
//                       title: "Confirm",
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }

// edit credit or settle
//   openEditModal(String id, String total, String createdAt, List<Map<String, dynamic>> type, context) {
//     Alert(
//         style: const AlertStyle(
//           animationType: AnimationType.grow,
//           isButtonVisible: false,
//         ),
//         context: context,
//         content: Column(
//           children: [
//             ListTile(
//               title: const Text("Edit"),
//               onTap: () async {
//                 var result = true;
//
//                 if (await _pinService.pinStatus() == true) {
//                   result = await _showPinDialog() as bool;
//                 }
//                 if (result!) {
//                   Navigator.pop(context);
//                   await modelOpenUpdate(context, id, total, type);
//                 } else {
//                   Navigator.pop(context);
//                   locator<GlobalServices>().errorSnackBar("Incorrect pin");
//                 }
//               },
//             ),
//             ListTile(
//               title: const Text("Delete"),
//               onTap: () async {
//                 var result = true;
//
//                 if (await _pinService.pinStatus() == true) {
//                   result = await _showPinDialog() as bool;
//                 }
//                 if (result!) {
//                   widget.args.tabbarNo == 0
//                       ? _specificpartyCubit.deleteCustomerExpense(id, widget.args.partyId)
//                       : _specificpartyCubit.deleteSupplierExpense(id, widget.args.partyId);
//                   Navigator.pop(context);
//                 } else {
//                   Navigator.pop(context);
//                   locator<GlobalServices>().errorSnackBar("Incorrect pin");
//                 }
//               },
//             ),
//           ],
//         )).show();
//   }

  String currentdate(DateTime createdAt) {
    var datereq = DateFormat.MMMM().format(createdAt);

    final String _inputTime = '${createdAt.hour}:${createdAt.minute}';
    final DateFormat _inputFormat = DateFormat('HH:mm');
    final DateFormat _outputFormat = DateFormat('h:mm a');

    DateTime inputDateTime = _inputFormat.parse(_inputTime);
    String outputTime = _outputFormat.format(inputDateTime);

    String pmAmFlag = "AM";

    if (createdAt.hour >= 13) {
      pmAmFlag = "PM";
    } else {
      pmAmFlag = "AM";
    }
    // return Text(
    //   '${createdAt.day.toString()}.${createdAt.month.toString()}.${createdAt.year.toString()} | $outputTime',
    //   style: const TextStyle(color: Colors.black45, fontSize: 13),
    // );
    return '${createdAt.day.toString()}.${createdAt.month.toString()}.${createdAt.year.toString()} | $outputTime';
  }

  Future<bool?> _showPinDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: pinCode.PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                animationType: pinCode.AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: pinCode.PinTheme(
                  shape: pinCode.PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 30,
                  inactiveColor: Colors.black45,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  selectedColor: Colors.black45,
                  disabledColor: Colors.black,
                  activeFillColor: Colors.white,
                ),
                cursorColor: Colors.black,
                controller: pinController,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              title: Text('Enter your pin'),
              actions: [
                Center(
                    child: CustomButton(
                        title: 'Verify',
                        onTap: () async {
                          bool status = await _pinService.verifyPin(
                              int.parse(pinController.text.toString()));
                          print(status);
                          if (status) {
                            pinController.clear();
                            Navigator.of(ctx).pop(true);
                          } else {
                            Navigator.of(ctx).pop(false);
                            pinController.clear();

                            return;
                          }
                        }))
              ],
            ));
  }
}
