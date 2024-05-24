import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:ui';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

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

class _Main extends State<Main> {
  final List<String> driveModes = ['P', 'R', 'N', 'D']; // 드라이브 모드 리스트
  int selectedButtonIndex = 0; // 선택된 버튼의 인덱스, 초기값은 0
  late TimerMonitor _TimerMonitor;
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  List<double> _gyroValues = [0.0, 0.0, 0.0];
  List<double> _orientaionValues = [0.0, 0.0, 0.0];
  DateTime _lastUpdateTime = DateTime.now();

  final currentDate = DateTime.now(); // 현재 날짜 가져오기

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // 앱이 초기화될 때 Future가 완료되도록 보장
    Wakelock.enable();
    // GlobalVariables.TxData = List<int>.filled(15, 0);
    GlobalVariables.TxData = List<int>.filled(27, 0);
    GlobalVariables.RxData = List<int>.filled(38, 0);
    // GlobalVariables.initializePADIp().then((_) {
    //   // 이 시점에서 PADIp가 설정되었으므로 사용 가능
    //   // print('PAD IP Address: ${GlobalVariables.PADIp}');
    // });
    _TimerMonitor = TimerMonitor();
    _TimerMonitor.startMonitoring();
    _TimerMonitor.wifiStream.listen((isConnected) {
      setState(() {
        GlobalVariables.isWifiConnected = isConnected;
      });
    });
    SensorsPlusValue();
  }

  void SensorsPlusValue() {
    // 중력을 반영하지 않은 순수 사용자의 힘에 의한 가속도계 값
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen(
      (AccelerometerEvent event) {
        SetTxData.Accel_X = (event.x).toInt();
        SetTxData.Accel_Y = (event.y).toInt();
        SetTxData.Accel_Z = (event.z).toInt();
        setState(() {
          _accelerometerValues = [event.x, event.y, event.z];
          double temp = _accelerometerValues[1] * -36;
          if (temp >= 360) {
            SetTxData.Msg2_SBW_Cmd_Tx = 359;
          } else if (temp <= -360) {
            SetTxData.Msg2_SBW_Cmd_Tx = -359;
          } else {
            SetTxData.Msg2_SBW_Cmd_Tx = temp.toInt();
          }
        });
      },
      onError: (error) {},
      cancelOnError: true,
    );

    // 자이로 값
    gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((GyroscopeEvent event) {
      SetTxData.Gyro_P = (event.x / 0.01).toInt();
      SetTxData.Gyro_R = (event.y / 0.01).toInt();
      SetTxData.Gyro_Y = (event.z / 0.01).toInt();
      setState(() {
        _gyroValues = [event.x, event.y, event.z];
        if (!GlobalVariables.isControlSelect) {
          if (_gyroValues[0] > 2.5) {
            SetTxData.Button_Pedal = 4;
            // GlobalVariables.drive_selectedButtonIndex = 0;
          } else if (_gyroValues[0] < -2.5) {
            SetTxData.Button_Pedal = 5;
          } else {}

          if (_gyroValues[1] > 4.5) {
            SetTxData.Button_Pedal = 10;
            // GlobalVariables.drive_selectedButtonIndex = 0;
          } else if (_gyroValues[1] < -4.5) {
            SetTxData.Button_Pedal = 11;
          } else {}
        }
      });
    });
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
                                onPressed: () {},
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
                                        onPressed: () {},
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
                                  setState(() {
                                    GlobalVariables.showContainer =
                                        !GlobalVariables.showContainer;
                                  });
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => SettingView()),
                                  // );
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
                        ? (GlobalVariables.isControlSelect
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
            ? SpeedDial(
                icon: Icons.send,
                activeIcon: Icons.close,
                visible: true,
                curve: Curves.bounceIn,
                backgroundColor: const Color.fromARGB(255, 27, 62, 94),
                children: [
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Left Crab',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("Left Crab Button");
                        SetTxData.Button_Pedal = 4;
                      },
                    ),
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Right Crab',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("Right Crab Button");
                        SetTxData.Button_Pedal = 5;
                      },
                    ),
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Zero Spin',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("Zero Spin Button");
                        SetTxData.Button_Pedal = 6;
                      },
                    ),
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Pivot',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("Pivot Button");
                        SetTxData.Button_Pedal = 7;
                      },
                    ),
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'FWS',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("FWS Button");
                        SetTxData.Button_Pedal = 10;
                      },
                    ),
                    SpeedDialChild(
                      labelWidget: Container(
                        width: (Size_Width * 0.15),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'D4',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Size_Width * 0.015,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                      ),
                      onTap: () {
                        // print("D4 Button");
                        SetTxData.Button_Pedal = 11;
                      },
                    ),
                  ])
            : null,
      ),
    );
  }
}
