import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:ui';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import './global.dart';
import './TiltView.dart';
import './JoystickView.dart';
import './DriveModeButton.dart';
import './SettingView.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> with TickerProviderStateMixin {
  late TimerMonitor _TimerMonitor;

  final currentDate = DateTime.now(); // 현재 날짜 가져오기

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // 앱이 초기화될 때 Future가 완료되도록 보장
    _loadThresholdValues();
    Wakelock.enable();
    // SetTxData.TxData = List<int>.filled(15, 0);
    SetTxData.TxData = List<int>.filled(27, 0);
    SetRxData.RxData = List<int>.filled(38, 0);
    _TimerMonitor = TimerMonitor();
    _TimerMonitor.startMonitoring();
    _TimerMonitor.wifiStream.listen((isConnected) {
      setState(() {
        GlobalVariables.isWifiConnected = isConnected;
      });
    });
    SensorsPlusValue();
    AnimationVariables.rotateanimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 애니메이션 반복
    // AnimationVariables.streatanimationController = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // )..repeat(); // 애니메이션 반복

    AnimationVariables.OperatinganimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    AnimationVariables.Operatinganimation = ColorTween(
      begin: Color(0xFF2A2A2A),
      end: Color(0xFFC358E9),
    ).animate(AnimationVariables.OperatinganimationController);
  }

  _loadThresholdValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      GlobalVariables.LeftCrab_Threshold =
          prefs.getDouble('LeftCrab_Threshold') ?? -2.5;
      GlobalVariables.RightCrab_Threshold =
          prefs.getDouble('RightCrab_Threshold') ?? 2.5;
      GlobalVariables.FWS_Threshold = prefs.getDouble('FWS_Threshold') ?? -4.5;
      GlobalVariables.D4_Threshold = prefs.getDouble('D4_Threshold') ?? 4.5;

      GlobalVariables.leftcrabthresholdController.text =
          (GlobalVariables.LeftCrab_Threshold).toString();
      GlobalVariables.rightcrabthresholdController.text =
          (GlobalVariables.RightCrab_Threshold).toString();
      GlobalVariables.fwsthresholdController.text =
          (GlobalVariables.FWS_Threshold).toString();
      GlobalVariables.d4thresholdController.text =
          (GlobalVariables.D4_Threshold).toString();
    });
  }

  void SensorsPlusValue() {
    // 중력을 반영하지 않은 순수 사용자의 힘에 의한 가속도계 값
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen(
      (AccelerometerEvent event) {
        SetTxData.Accel_X = (event.x).toInt();
        SetTxData.Accel_Y = -(event.y).toInt();
        SetTxData.Accel_Z = (event.z).toInt();
        setState(() {
          GlobalVariables.accelerometerValues = [
            event.x,
            -event.y,
            event.z,
          ];
          //yejin table = _accelerometerValues[0], another table = _accelerometerValues[1]
          double temp = GlobalVariables.orientation[1] * 3.4;
          double tilt_angle = GlobalVariables.orientation[1];
          // print(
          //     '${GlobalVariables.orientation[1].toStringAsFixed(2)}, ${temp.toStringAsFixed(2)}');
          if ((SetTxData.Button_Pedal == 6) & (GlobalVariables.showContainer)) {
            if (tilt_angle >= 15) {
              AnimationVariables.isRotateVisible = false;
              if (!AnimationVariables.isRotateshow) {
                AnimationVariables.isRotateshow = true;
                AnimationVariables.rotateanimationController.repeat();
              }
            } else if (tilt_angle <= -15) {
              AnimationVariables.isRotateVisible = true;
              if (!AnimationVariables.isRotateshow) {
                AnimationVariables.isRotateshow = true;
                AnimationVariables.rotateanimationController.repeat();
              }
            } else {
              if (AnimationVariables.isRotateshow) {
                AnimationVariables.isRotateshow = false;
                AnimationVariables.rotateanimationController.stop();
              }
            }
          } else {
            if (AnimationVariables.isRotateshow) {
              AnimationVariables.isRotateshow = false;
              AnimationVariables.rotateanimationController.stop();
            }
          }

          if (temp >= 300) {
            SetTxData.Msg2_SBW_Cmd_Tx = 300;
          } else if (temp <= -300) {
            SetTxData.Msg2_SBW_Cmd_Tx = -300;
          } else {
            SetTxData.Msg2_SBW_Cmd_Tx = temp.toInt();
          }
        });
      },
      onError: (error) {},
      cancelOnError: true,
    );

    // 자이로 값
    gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (GyroscopeEvent event) {
        setState(() {
          GlobalVariables.gyroValues = [-event.y, event.z, event.x];
          SetTxData.Gyro_R = (GlobalVariables.gyroValues[0] / 0.01).toInt();
          SetTxData.Gyro_P = (GlobalVariables.gyroValues[1] / 0.01).toInt();
          SetTxData.Gyro_Y = (GlobalVariables.gyroValues[2] / 0.01).toInt();
          // print(
          //     '${GlobalVariables.gyroValues[0].toStringAsFixed(2)}   ${GlobalVariables.gyroValues[1].toStringAsFixed(2)}   ${GlobalVariables.gyroValues[2].toStringAsFixed(2)}');

          if (GlobalVariables.showContainer) {
            if ((GlobalVariables.gyroValues[2] <
                GlobalVariables.LeftCrab_Threshold)) {
              SetTxData.Button_Pedal = 4;
              AnimationVariables.isArrowVisible = true;
              if (!AnimationVariables.isArrowshow) {
                AnimationVariables.isArrowshow = true;
                // AnimationVariables.streatanimationController.repeat();
              }
            } else if ((GlobalVariables.gyroValues[2] >
                GlobalVariables.RightCrab_Threshold)) {
              SetTxData.Button_Pedal = 5;
              AnimationVariables.isArrowVisible = false;
              if (!AnimationVariables.isArrowshow) {
                AnimationVariables.isArrowshow = true;
                // AnimationVariables.streatanimationController.repeat();
              }
            } else {}

            if (GlobalVariables.gyroValues[0] < GlobalVariables.FWS_Threshold) {
              SetTxData.Button_Pedal = 10;
            } else if (GlobalVariables.gyroValues[0] >
                GlobalVariables.D4_Threshold) {
              SetTxData.Button_Pedal = 11;
            } else {}
          }
        });
      },
      onError: (error) {},
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _TimerMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    final Size_Height = MediaQuery.of(context).size.height;
    final Size_Width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2A2A2A),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: SizedBox(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: SizedBox(
                      height: (Size_Height * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // View Change
                          Container(
                            child: SizedBox(
                              height: (Size_Height * 0.1),
                              child: IconButton(
                                icon: Icon(Icons.flip_camera_ios),
                                onPressed: () {
                                  Haptics.vibrate(HapticsType.light);
                                },
                              ),
                            ),
                          ),
                          // UDP & Date & Time
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF212121),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: SizedBox(
                              width: (Size_Width / 3) * 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: SizedBox(
                                      height: (Size_Height * 0.1),
                                      child: IconButton(
                                        icon: GlobalVariables.isWifiConnected
                                            ? Icon(Icons.wifi) // Wi-Fi가 연결된 경우
                                            : Icon(Icons
                                                .wifi_off), // Wi-Fi가 연결되지 않은 경우
                                        onPressed: () {
                                          Haptics.vibrate(HapticsType.light);
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(
                                      '${GlobalVariables.nowDateTime.year}.${GlobalVariables.nowDateTime.month.toString().padLeft(2, '0')}.${GlobalVariables.nowDateTime.day.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: (Size_Width * 0.015),
                                        color: Color(0xFFF3F3F3),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(
                                      '${GlobalVariables.nowDateTime.hour.toString().padLeft(2, '0')}:${GlobalVariables.nowDateTime.minute.toString().padLeft(2, '0')}:${GlobalVariables.nowDateTime.second.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: (Size_Width * 0.015),
                                        color: Color(0xFFF3F3F3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Setting
                          Container(
                            child: SizedBox(
                              height: (Size_Height * 0.1),
                              child: IconButton(
                                icon: GlobalVariables.showContainer
                                    ? Icon(Icons.settings)
                                    : Icon(Icons.drive_eta),
                                onPressed: () {
                                  Haptics.vibrate(HapticsType.light);
                                  setState(() {
                                    GlobalVariables.showContainer =
                                        !GlobalVariables.showContainer;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: (Size_Height * 0.9),
                    child: GlobalVariables.showContainer
                        ? (AnimationVariables.isControlSelect
                            ? JoystickView()
                            : TiltView())
                        : SettingView(),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: GlobalVariables.showContainer
            ? Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () {
                    Haptics.vibrate(HapticsType.light);
                    AnimationVariables.isSendPressed = true; // Toggle isPressed
                    print(AnimationVariables.isSendPressed);
                    showDialog(
                        context: context,
                        barrierDismissible: true, // 이 부분을 true로 설정합니다.
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Send Message"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: buildButton(context, Size_Width,
                                            "Left Crab", 4),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: buildButton(context, Size_Width,
                                            "Right Crab", 5),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(
                                            context, Size_Width, "FWS", 10),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(
                                            context, Size_Width, "D4", 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(context, Size_Width,
                                            "Zero Spin", 6),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(
                                            context, Size_Width, "Pivot", 7),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(
                                            context, Size_Width, "RP", 8),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: buildButton(
                                            context, Size_Width, "IP", 9),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).then((value) {
                      setState(() {
                        AnimationVariables.isSendPressed = false;
                      });
                    });
                  },
                  child: Icon(AnimationVariables.isSendPressed
                      ? Icons.close
                      : Icons.send),
                ),
              )
            : null,
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: GlobalVariables.showContainer
        //     ? SpeedDial(
        //         icon: Icons.send,
        //         activeIcon: Icons.close,
        //         visible: true,
        //         curve: Curves.bounceIn,
        //         backgroundColor: const Color.fromARGB(255, 27, 62, 94),
        //         children: [
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'Left Crab',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("Left Crab Button");
        //                 SetTxData.Button_Pedal = 4;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'Right Crab',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("Right Crab Button");
        //                 SetTxData.Button_Pedal = 5;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'Zero Spin',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("Zero Spin Button");
        //                 SetTxData.Button_Pedal = 6;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'Pivot',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("Pivot Button");
        //                 SetTxData.Button_Pedal = 7;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'RP',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("D4 Button");
        //                 SetTxData.Button_Pedal = 8;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'IP',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("FWS Button");
        //                 SetTxData.Button_Pedal = 9;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'FWS',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("FWS Button");
        //                 SetTxData.Button_Pedal = 10;
        //               },
        //             ),
        //             SpeedDialChild(
        //               labelWidget: Container(
        //                 width: (Size_Width * 0.15),
        //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //                 alignment: Alignment.center,
        //                 decoration: BoxDecoration(
        //                   color: Color(0xFF424242),
        //                   borderRadius: BorderRadius.circular(8.0),
        //                 ),
        //                 child: Text(
        //                   'D4',
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: Size_Width * 0.015,
        //                     color: Color(0xFFF3F3F3),
        //                   ),
        //                 ),
        //               ),
        //               onTap: () {
        //                 // print("D4 Button");
        //                 SetTxData.Button_Pedal = 11;
        //               },
        //             ),
        //           ])
        //     : null,
      ),
    );
  }
}

Widget buildButton(
    BuildContext context, double Size_Width, String text, int num) {
  return ElevatedButton(
    onPressed: () {
      Haptics.vibrate(HapticsType.light);
      SetTxData.Button_Pedal = num;
      print(text);
      Navigator.pop(context); // Close the AlertDialog
      MessageView.showOverlayMessage(context, Size_Width, text);
    },
    child: Container(
      width: (Size_Width * 0.07),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: Size_Width * 0.015,
          color: Color(0xFFF3F3F3),
        ),
      ),
    ),
  );
}
