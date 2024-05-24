import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

import './global.dart';
import './UDP.dart';
import './toggle_button.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final UDP udp = UDP();
  final TextEditingController padIpController = TextEditingController(
    text: GlobalVariables.PADIp != "" ? GlobalVariables.PADIp : '',
  );
  final TextEditingController padPortController = TextEditingController(
    text: (GlobalVariables.PADPort).toString() != "0"
        ? (GlobalVariables.PADPort).toString()
        : '',
  );
  final TextEditingController targetIpController = TextEditingController(
    text: GlobalVariables.TargetIp != "" ? GlobalVariables.TargetIp : '',
  );
  final TextEditingController targetPortController = TextEditingController(
    text: (GlobalVariables.TargetPort).toString() != "0"
        ? (GlobalVariables.TargetPort).toString()
        : '',
  );

  final TextEditingController leftcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.LeftCrab_Threshold).toString());
  final TextEditingController rightcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.RightCrab_Threshold).toString());
  final TextEditingController fwscrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.FWSCrab_Threshold).toString());
  final TextEditingController d4crabthresholdController = TextEditingController(
      text: (GlobalVariables.D4Crab_Threshold).toString());

  @override
  Widget build(BuildContext context) {
    final Size_Height = MediaQuery.of(context).size.height;
    final Size_Width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
              (Size_Width * 0.3), 10, (Size_Width * 0.3), 0),
          child: Text(
            'Network Configure',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: (Size_Width * 0.02),
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'PAD IP : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.25,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  decoration: InputDecoration(
                      hintText: 'PAD IP(Def.192.168.0.5)',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 162, 162, 162),
                      )),
                  keyboardType: TextInputType.number,
                  controller: padIpController,
                ),
              ),
              Container(
                width: Size_Width * 0.17,
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'PAD PORT : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.25,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, (Size_Width * 0.1), 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  decoration: InputDecoration(
                      hintText: 'PORT(Def. 2020)',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 162, 162, 162),
                      )),
                  keyboardType: TextInputType.number,
                  controller: padPortController,
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'Target IP : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.25,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  decoration: InputDecoration(
                      hintText: 'Target IP(Def.192.168.0.3)',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 162, 162, 162),
                      )),
                  keyboardType: TextInputType.number,
                  controller: targetIpController,
                ),
              ),
              Container(
                width: Size_Width * 0.17,
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'Target PORT : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.25,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, (Size_Width * 0.1), 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  decoration: InputDecoration(
                      hintText: 'PORT(Def. 3030)',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 162, 162, 162),
                      )),
                  keyboardType: TextInputType.number,
                  controller: targetPortController,
                ),
              ),
            ],
          ),
        ),
        Container(
          // decoration: BoxDecoration(
          //   color: Color.fromARGB(255, 146, 74, 74),
          // ),
          child: SizedBox(
            width: (Size_Width * 0.7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2,
                        sigmaY: 2,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (GlobalVariables.isWifiConnected) {
                            GlobalVariables.PADIp =
                                padIpController.text.isNotEmpty
                                    ? padIpController.text
                                    : "192.168.0.5";
                            GlobalVariables.PADPort =
                                int.tryParse(padPortController.text) ?? 2020;
                            GlobalVariables.TargetIp =
                                targetIpController.text.isNotEmpty
                                    ? targetIpController.text
                                    : "192.168.0.3";
                            GlobalVariables.TargetPort =
                                int.tryParse(targetPortController.text) ?? 3030;

                            if (GlobalVariables.PADIp.isNotEmpty &&
                                GlobalVariables.TargetIp.isNotEmpty &&
                                GlobalVariables.TargetPort > 0 &&
                                GlobalVariables.PADPort > 0) {
                              udp.bind(GlobalVariables.PADIp,
                                  GlobalVariables.PADPort);
                              // udp.setTarget(GlobalVariables.TargetIp,
                              //     GlobalVariables.TargetPort);
                              udp.send(
                                  GlobalVariables.TxData,
                                  GlobalVariables.PADIp,
                                  GlobalVariables.PADPort,
                                  GlobalVariables.TargetIp,
                                  GlobalVariables.TargetPort);
                              // print('setTarget');
                            } else {
                              // print('Invalid input');
                            }
                          } else {
                            // print("Please Connect Wifi");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF748FC2), // 버튼 색상
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Container(
                          width: (Size_Width * 0.3),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: (Size_Width * 0.02),
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  // width: (Size_Width * 0.3),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    GlobalVariables.isUDPConnected
                        ? 'Status OK'
                        : 'Status Fail',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.02),
                      color: GlobalVariables.isUDPConnected
                          ? Color(0xFFF3F3F3)
                          : Color.fromARGB(255, 210, 121, 121),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              (Size_Width * 0.3), 10, (Size_Width * 0.3), 0),
          child: Text(
            'Threshold Setting',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: (Size_Width * 0.02),
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
        Container(
          width: Size_Width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'LeftCrab : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.07,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 20, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  keyboardType: TextInputType.number,
                  controller: leftcrabthresholdController,
                ),
              ),
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'RightCrab : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.07,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 20, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  keyboardType: TextInputType.number,
                  controller: rightcrabthresholdController,
                ),
              ),
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'FWSCrab : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.07,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 20, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  keyboardType: TextInputType.number,
                  controller: fwscrabthresholdController,
                ),
              ),
              Container(
                height: Size_Height * 0.1,
                alignment: Alignment.centerRight,
                child: Text(
                  'D4Crab : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (Size_Width * 0.015),
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Container(
                width: Size_Width * 0.07,
                height: Size_Height * 0.1,
                margin: EdgeInsets.fromLTRB(0, 5, 20, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 1),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (Size_Width * 0.015),
                      color: Color(0xFF2A2A2A)),
                  keyboardType: TextInputType.number,
                  controller: d4crabthresholdController,
                ),
              ),
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 2,
                      sigmaY: 2,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        GlobalVariables.LeftCrab_Threshold =
                            double.tryParse(leftcrabthresholdController.text) ??
                                2.5;
                        GlobalVariables.RightCrab_Threshold = double.tryParse(
                                rightcrabthresholdController.text) ??
                            -2.5;
                        GlobalVariables.FWSCrab_Threshold =
                            double.tryParse(fwscrabthresholdController.text) ??
                                4.5;
                        GlobalVariables.D4Crab_Threshold =
                            double.tryParse(d4crabthresholdController.text) ??
                                -4.5;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF748FC2), // 버튼 색상
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Container(
                        width: (Size_Width * 0.1),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(
                          'Set',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: (Size_Width * 0.02),
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin:
              EdgeInsets.fromLTRB((Size_Width * 0.3), 0, (Size_Width * 0.3), 0),
          child: Text(
            'Operating Mode',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: (Size_Width * 0.02),
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),

        //Drive Mode
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: (Size_Width * 0.15),
                    alignment: Alignment(0.0, 0.0),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  Container(
                    child: ToggleButton(
                      width: (Size_Width * 0.5),
                      height: 60.0,
                      toggleBackgroundColor: Colors.white,
                      toggleBorderColor: (Color.fromARGB(255, 214, 214, 214)),
                      toggleColor: (Color.fromARGB(255, 121, 210, 134)),
                      activeTextColor: Color(0xFF2A2A2A),
                      inactiveTextColor: Colors.grey,
                      leftDescription: 'Phone Tilt',
                      rightDescription: 'Joystick',
                      onLeftToggleActive: () {
                        // print('Joystick activated');
                        SetTxData.Button_Pedal = 13;
                        GlobalVariables.isDataSendFlag = true;
                      },
                      onRightToggleActive: () {
                        // print('Phone Tilt activated');
                      },
                    ),
                  ),
                  Container(
                    width: (Size_Width * 0.15),
                    height: (Size_Height * 0.15),
                    // color: Color(0xFF212121),
                  ),
                ])),
      ],
    );
  }
}
