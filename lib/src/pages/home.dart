// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/AboutOptionPage.dart';
import 'package:shopos/src/pages/SwitchAccountPage.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/online_order_list.dart';

import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/preferences_page.dart';

import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/pages/set_pin.dart';
import 'package:shopos/src/pages/sign_in.dart';

import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/background_service.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';

import 'package:shopos/src/widgets/custom_button.dart';

import '../widgets/pin_validation.dart';

class HomePage extends StatefulWidget {
  BuildContext context;
  HomePage(this.context, {Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  bool shopOpen = true;

  final PinService _pinService = PinService();
  final TextEditingController pinController = TextEditingController();

  ///
  @override
  void initState() {
    // _checkUpdate();
    _homeCubit = HomeCubit()..currentUser();
    super.initState();
    initializeService();
    getDataFromDatabase();
  }

  //LocalDatabase
  getDataFromDatabase() async {
    print("sssssssss");

    final provider = Provider.of<Billing>(
      widget.context,
    );
    var data = await DatabaseHelper().getOrderItems();
    print("data form database");
    // print(data[0].orderItems?[0].product?.quantityToBeSold!);
    provider.removeAll();

    data.forEach((element) {
      // print("element:${element.orderItems![0].product!.name} and ${element.id}");
      // print("element:${element.orderItems![0].product!.sellingPrice} and ${element.id}");
      provider.addSalesBill(element, element.id.toString());
    });
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: _homeCubit,
        builder: (context, state) {
          if (state is HomeRender) {
            return Scaffold(
              appBar: AppBar(
                // toolbarHeight: MediaQuery.of(context).size.height * 0.07,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hi ${state.user.businessName ?? ""}!"),
                        SizedBox(
                          width: 35,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome back",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 35,
                        ),
                      ],
                    )
                  ],
                ),
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*  Container(
                        height: 30,
                        child: Switch(
                            activeColor: Colors.green,
                            value: shopOpen,
                            onChanged: (bool status) async {
                              await UserService.shopStatus();
                              shopOpen = status;
                              setState(() {});
                            }),
                      ),
                      Text(
                        shopOpen ? 'Online' : 'Offline',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),*/
                      // Padding(
                      //   padding: const EdgeInsets.all(10),
                      //   child: GestureDetector(
                      //     onTap: () {},
                      //     child: Image.asset(
                      //       "assets/images/bell.png",
                      //       height: 30,
                      //     ),
                      //   ),
                      // )
                    ],
                  )
                ],
              ),
              drawer: Drawer(
                backgroundColor: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          "assets/images/bharat.png",
                          height: 30,
                        ),
                        title: Title(
                          color: Colors.black,
                          child: Text(
                            "",
                            textScaleFactor: 1.4,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Divider(),
                      // ListTile(
                      //   leading: Icon(Icons.upload_file),
                      //   title: Text("Bulk Product Upload",
                      //       style: TextStyle(color: Colors.black)),
                      //   onTap: () async {
                      //     await launchUrl(
                      //       Uri.parse(
                      //           'http://65.0.7.20:8001/api/v1/renderweblogin'),
                      //       mode: LaunchMode.externalApplication,
                      //     );
                      //     Navigator.pop(context);
                      //   },
                      // ),

                      ListTile(
                        leading: Image.asset(
                          "assets/images/shop.png",
                          height: 32,
                        ),
                        title: Title(
                          color: Colors.black,
                          child: Text(
                            state.user.businessName ?? "",
                          ),
                        ),
                        subtitle: Text(
                          state.user.email ?? "",
                          textScaleFactor: 1.2,
                        ),
                        onTap: () async {
                          Navigator.pushNamed(
                              context, SwitchAccountPage.rountName); //
                        },
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/keyy.png",
                          height: 28,
                        ),
                        title: Title(
                            color: Colors.black, child: Text("Set/Change pin")),
                        onTap: () async {
                          bool status = await _pinService.pinStatus();
                          print(status);
                          Navigator.of(context).pushNamed(SetPinPage.routeName,
                              arguments: status);
                        },
                      ),

                      ListTile(
                        leading: Image.asset(
                          "assets/images/lock.png",
                          height: 30,
                        ),
                        title: Title(
                            color: Colors.black,
                            child: Text("Change Password")),
                        onTap: () async {
                          await Navigator.pushNamed(context, 'changepassword',
                              arguments: state.user);
                          Navigator.pop(context);
                        },
                      ),

                      // ListTile(
                      //   leading: Image.asset(
                      //     "assets/icon/preferences_icon.png",
                      //     height: 28,
                      //   ),
                      //   title: Title(color: Colors.black, child: Text("Preferences")),
                      //   onTap: () async {
                      //     var result = true;
                      //
                      //     if (await _pinService.pinStatus() == true) {
                      //       result = await PinValidation.showPinDialog(context) as bool;
                      //     }
                      //     if(result){
                      //       Navigator.of(context).pushNamed(DefaultPreferences.routeName);
                      //     }
                      //   },
                      // ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/about.png",
                          height: 30,
                        ),
                        title: Title(color: Colors.black, child: Text("About")),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              AboutOptionPage
                                  .routeName); // Navigate to the PrivacyPolicyPage
                        },
                      ),

                      /*  ListTile(
                        leading: Icon(Icons.control_point),
                        title: Title(
                            color: Colors.black,
                            child: Text("Terms and Conditions")),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              TermsAndConditionsPage
                                  .routeName); // Navigate to the PrivacyPolicyPage
                        },
                      ),*/
                      ListTile(
                        leading: Image.asset(
                          "assets/images/logout.png",
                          height: 30,
                        ),
                        title:
                            Title(color: Colors.black, child: Text("Logout")),
                        onTap: () async {
                          await const AuthService().signOut();
                          // final provider =
                          //     Provider.of<Billing>(context, listen: false);
                          // provider.removeAll();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SignInPage.routeName,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GridView(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 30.0,
                              mainAxisExtent: 166),
                      padding: const EdgeInsets.all(10),
                      children: [
                        HomeCard(
                          color: 0XFF48AFFF,
                          icon: 'assets/images/Plans.png',
                          decreaseSizeOfIcon: 18,
                          title: "Plans",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SearchProductListScreen.routeName,
                              arguments: PlanListPageArgs(
                                  isSelecting: false,
                                  orderType: OrderType.none,
                                  membershipPlanList: []),
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFFFFC700,
                          icon: 'assets/images/party.png',
                          title: "Party",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PartyListPage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFFFF5959,
                          icon: 'assets/images/expense.png',
                          title: "Expense",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ExpensePage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFF5642A6,
                          icon: 'assets/images/reports.png',
                          title: "Reports",
                          onTap: () {
                            Navigator.pushNamed(context, ReportsPage.routeName);
                          },
                        ),
                      ],
                    ),
                    /*OnlineStoreWidget(
                      activeOrders: 5,
                      onTap: () {
                        Navigator.pushNamed(context, ReportsPage.routeName);
                      },
                    ),*/
                    const Spacer(),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     "Create Invoice",
                    //     textAlign: TextAlign.left,
                    //     style: Theme.of(context).textTheme.headline6,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        // Expanded(
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       // Navigator.pushNamed(
                        //       //   context,
                        //       //   CreatePurchase.routeName,
                        //       // );
                        //       attendancePageNotAvailable(context);
                        //     },
                        //     child: Column(
                        //       children: [
                        //         Card(
                        //           color: Color.fromARGB(255, 255, 101, 122)
                        //               .withOpacity(0.5),
                        //           elevation: 5,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(12),
                        //             side: BorderSide(
                        //               color: Color.fromARGB(255, 175, 76,
                        //                   76), // Set the border color
                        //               width: 2.0, // Set the border width
                        //             ),
                        //           ),
                        //           child: Padding(
                        //               padding: const EdgeInsets.all(18),
                        //               child: Image.asset(
                        //                 "assets/images/planning.png",
                        //                 height: 80,
                        //                 width: 90,
                        //               )),
                        //         ),
                        //         Text(
                        //           "Attendance",
                        //           style: TextStyle(
                        //               fontSize: 20,
                        //               fontWeight: FontWeight.w600),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, CreateSale.routeName,
                              //     arguments: BillingPageArgs(
                              //         editOrders: []));
                              Navigator.pushNamed(
                                context,
                                SearchProductListScreen.routeName,
                                arguments: PlanListPageArgs(isSelecting: true, orderType: OrderType.sale, membershipPlanList: []),
                              );
                            },
                            child: Column(
                              children: [
                                Card(
                                  color:
                                      const Color.fromARGB(255, 101, 255, 106)
                                          .withOpacity(0.5),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          Colors.green, // Set the border color
                                      width: 2.0, // Set the border width
                                    ),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        "assets/images/sale.png",
                                        height: 100,
                                        width: 110,
                                      )),
                                ),
                                Text(
                                  "Sale",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: ColorsConst.primaryColor,
            ),
          );
        },
      ),
    );
  }
  attendancePageNotAvailable(context) {
    Alert(
        title: "Attendance Coming Soon",
        style: const AlertStyle(
          animationType: AnimationType.grow,
          // isCloseButton: false,,
          isOverlayTapDismiss: true,
          isButtonVisible: false,
        ),
        context: context,
        closeFunction: (){
            Navigator.pop(context);
        },

        content: Column(
          children: [
            SizedBox(height: 20,),
            Text(
              'Attendance Feature will be coming soon in future updates',style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )).show();
  }
  // Future<bool?> showRestartAppDialouge() {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (ctx) => AlertDialog(
  //             content: Text('App needed to restart'),
  //             title: Text('Alert'),
  //             actions: [
  //               Center(
  //                   child: CustomButton(
  //                       title: 'ok',
  //                       onTap: () async {
  //                         Navigator.of(context).pop();
  //                         //await DatabaseHelper().deleteTHEDatabase();
  //                         // runApp(MyApp());
  //                       }))
  //             ],
  //           ));
  // }
}

class HomeCard extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final String title;
  final int color;
  final double? decreaseSizeOfIcon;
  const HomeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.decreaseSizeOfIcon = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Card(
            color: Color(color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(15 + decreaseSizeOfIcon!/2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    icon,
                    height: 100 - decreaseSizeOfIcon!,
                    width: 100 - decreaseSizeOfIcon!,
                  ),
                ],
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnlineStoreWidget extends StatelessWidget {
  final int activeOrders;
  final VoidCallback onTap;

  const OnlineStoreWidget({
    Key? key,
    this.activeOrders = 0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, OnlineOrderList.routeName);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0), // Add vertical padding
          child: Row(
            children: [
              SizedBox(width: 20.0),
              Icon(
                Icons.storefront_rounded,
                size: 50.0,
                color: ColorsConst.primaryColor,
              ),
              SizedBox(width: 35.0),
              Text(
                "Online Store",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
