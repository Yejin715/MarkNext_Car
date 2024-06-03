import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import './UDP.dart';

class SetTxData {
  static List<int> TxData = List<int>.filled(15, 0);
  // static List<int> TxData = List<int>.filled(27, 0);

  static int Msg2_SBW_Cmd_Tx = 0;
  static int Accel_Pedal_Angle = 0;
  static int Button_Pedal = 0;
  static int Joystick_Input_Left_X = 0;
  static int Joystick_Input_Left_Y = 0;
  static int Joystick_Input_Right_X = 0;
  static int Joystick_Input_Right_Y = 0;
  static int Drive_Mode_Switch = 0;
  static int Pivot_Rcx = 0;
  static int Pivot_Rcy = 0;
  static int Accel_X = 0;
  static int Accel_Y = 0;
  static int Accel_Z = 0;
  static int Gyro_Y = 0;
  static int Gyro_P = 0;
  static int Gyro_R = 0;
}

class SetRxData {
  static List<int> RxData = List<int>.filled(38, 0);

  static int Corner_Mode = 0;
  static int Mode_Disable_Button_Blink = 0;
  static int Corner_Mode_Disable_Button = 0;
  static int Measured_Steer_Angle_Fl = 0;
  static int Target_Steer_Current_Fl = 0;
  static int Measured_Steer_Current_Fl = 0;
  static int Measured_Steer_Angle_Fr = 0;
  static int Target_Steer_Current_Fr = 0;
  static int Measured_Steer_Current_Fr = 0;
  static int Measured_Steer_Angle_Rl = 0;
  static int Target_Steer_Current_Rl = 0;
  static int Measured_Steer_Current_Rl = 0;
  static int Measured_Steer_Angle_Rr = 0;
  static int Target_Steer_Current_Rr = 0;
  static int Measured_Steer_Current_Rr = 0;
  static int Vehicle_Speed = 0;
  static int Battery_Soc = 0;
}

class DataClass {
  static void loadThresholdValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GlobalVariables.timer_duration = prefs.getInt('Timer_Duration') ?? 50;
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
  }

  static void saveDoubleValue(String key, double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

  static void saveIntValue(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
}

class GraphicVariables {
  static Offset? circlepoint = null;

  static List<List<Color>> selectColor11x11 = List.generate(
    11,
    (i) => List<Color>.filled(11, Colors.transparent),
  );

  static void resetColor() {
    GraphicVariables.selectColor11x11 = List.generate(
      11,
      (i) => List<Color>.filled(11, Colors.transparent),
    );
    GraphicVariables.circlepoint = null;
  }

  static void setPivot(int yvalue, int xvalue, double height) {
    GraphicVariables.selectColor11x11[xvalue][yvalue] = Colors.red;
    SetTxData.Button_Pedal = 7;
    SetTxData.Pivot_Rcx = -(xvalue - 5);
    SetTxData.Pivot_Rcy = (yvalue - 5);
    GraphicVariables.circlepoint = Offset(
        (yvalue * height) + (height / 2), (xvalue * height) + (height / 2));
  }
}

class AnimationVariables {
  static bool isSendPressed = false;
  static bool isRotateVisible = false;
  static bool isRotateshow = false;
  static bool isArrowshow = false;
  static bool isArrowVisible = false;
  static bool isOperatingshow = false;
  static late AnimationController rotateanimationController;
  // static late AnimationController streatanimationController;
  static late AnimationController OperatinganimationController;
  static late Animation<Color?> Operatinganimation;
  static int drive_selectedButtonIndex = -1;
  static List<String> driveModes = ['P', 'R', 'N', 'D']; // 드라이브 모드 리스트

  static bool isScrollDragging = false; // 클래스에 포함된 변수
  static bool isJoyLeftDragging = false; // 클래스에 포함된 변수
  static bool isJoyRightDragging = false; // 클래스에 포함된 변수
  static bool isControlSelect = false;
}

class MessageView {
  static void showOverlayMessage(
      BuildContext context, double Size_Width, String message) {
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: Size_Width * 0.02,
                  color: Color(0xFFF3F3F3),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // 일정 시간 후에 Overlay를 제거합니다.
    Future.delayed(Duration(milliseconds: 700), () {
      overlayEntry.remove();
    });
  }

  static void showInputModal(
      BuildContext context, String label, TextEditingController controller) {
    FocusNode focusNode = FocusNode();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(focusNode);
        });

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: label),
                  onSubmitted: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GlobalVariables {
  static int timer_duration = 50;
  static List<double> orientation = [0.0, 0.0, 0.0];
  static List<double> gyroorientation = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  static List<double> accorientation = [0.0, 0.0, 0.0];
  static List<double> gyroangle_x = [0, 0, 0];
  static List<double> gyroangle_xx = [0, 0, 0];
  static List<double> gyroangle_y = [0, 0, 0];
  static List<double> gyroangle_yy = [0, 0, 0];
  static List<double> gyroangle_yyy = [0, 0, 0];
  static List<double> accangle_x = [0, 0, 0];
  static List<double> accangle_xx = [0, 0, 0];
  static List<double> accangle_y = [0, 0, 0];
  static List<double> accangle_yy = [0, 0, 0];
  static List<double> accelerometerValues = [0.0, 0.0, 0.0];
  static List<double> gyroValues = [0.0, 0.0, 0.0];
  static bool showContainer = false; // 클래스에 포함된 변수
  static bool isWifiConnected = false;
  static bool isUDPConnected = false;
  static DateTime nowDateTime = DateTime.now();
  static DateTime sendDateTime = DateTime.now();

  static String PADIp = "";
  static int PADPort = 0;
  static String TargetIp = "";
  static int TargetPort = 0;

  static double LeftCrab_Threshold = -2.5;
  static double RightCrab_Threshold = 2.5;
  static double FWS_Threshold = -4.5;
  static double D4_Threshold = 4.5;

  static TextEditingController timerController =
      TextEditingController(text: (GlobalVariables.timer_duration).toString());
  static TextEditingController leftcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.LeftCrab_Threshold).toString());
  static TextEditingController rightcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.RightCrab_Threshold).toString());
  static TextEditingController fwsthresholdController =
      TextEditingController(text: (GlobalVariables.FWS_Threshold).toString());
  static TextEditingController d4thresholdController =
      TextEditingController(text: (GlobalVariables.D4_Threshold).toString());

  static List<String> DriveMode = [
    "Parking",
    "Parking",
    "Parking",
    "Parking",
    "Left Crab",
    "Right Crab",
    "Zero Spin",
    "PIVOT",
    "RP",
    "IP",
    "FWS",
    "D4",
    "Parking"
  ];
}

class TimerMonitor {
  StreamController<bool> _wifiStreamController = StreamController<bool>();
  Stream<bool> get wifiStream => _wifiStreamController.stream;
  final UDP udp = UDP();

  void startMonitoring() {
    Timer.periodic(Duration(milliseconds: 10), (timer) async {
      _calculateAngles();
      // Check Wifi
      final connectivityResult = await Connectivity().checkConnectivity();
      final isWifiConnected = connectivityResult == ConnectivityResult.wifi;
      _wifiStreamController.add(isWifiConnected);
      switch (SetTxData.Button_Pedal) {
        case 0:
        case 1:
        case 2:
        case 3:
          GraphicVariables.resetColor();

          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            // AnimationVariables.streatanimationController.stop();
          }
          break;
        case 4:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();
          AnimationVariables.isArrowVisible = true;
          if (!AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = true;
            // AnimationVariables.streatanimationController.repeat();
          }
          break;
        case 5:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();
          AnimationVariables.isArrowVisible = false;
          if (!AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = true;
            // AnimationVariables.streatanimationController.repeat();
          }
          break;
        case 6:
        case 7:
          AnimationVariables.drive_selectedButtonIndex = -1;
          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            // AnimationVariables.streatanimationController.stop();
          }
          break;
        default:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();

          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            // AnimationVariables.streatanimationController.stop();
          }
          break;
      }

      // Date & Time
      GlobalVariables.nowDateTime = DateTime.now();
      if (DateTime.now()
              .difference(GlobalVariables.sendDateTime)
              .inMilliseconds >=
          GlobalVariables.timer_duration) {
        if (GlobalVariables.isUDPConnected) {
          udp.bind(GlobalVariables.PADIp, GlobalVariables.PADPort);
          udp.send(
              SetTxData.TxData,
              GlobalVariables.PADIp,
              GlobalVariables.PADPort,
              GlobalVariables.TargetIp,
              GlobalVariables.TargetPort);
        } else {}
        GlobalVariables.sendDateTime = DateTime.now();
      }
    });
  }

  void dispose() {
    _wifiStreamController.close();
  }

  void _calculateAngles() {
    double dt = 0.001;
    List<double> low_filter_num = [
      0.0078,
      0.0156,
      0.0078
    ]; // 2차 저역 통과 필터의 분자 계수
    List<double> low_filter_den = [
      1.0000,
      -1.7347,
      0.7660
    ]; // 2차 저역 통과 필터의 분모 계수
    List<double> high_filter_num = [
      0.8752,
      -1.7504,
      0.8752
    ]; // 2차 고역 통과 필터의 분자 계수
    List<double> high_filter_den = [
      1.0000,
      -1.7347,
      0.7660
    ]; // 2차 고역 통과 필터의 분모 계수

// 자이로스코프 각속도 데이터를 라디안으로 변환
    GlobalVariables.gyroorientation[0] +=
        (GlobalVariables.gyroValues[0] * dt) * (180 / pi);
    GlobalVariables.gyroorientation[1] +=
        (GlobalVariables.gyroValues[1] * dt) * (180 / pi);
    GlobalVariables.gyroorientation[2] +=
        (GlobalVariables.gyroValues[2] * dt) * (180 / pi);

// 2차 고역 통과 필터의 필터링 과정
    GlobalVariables.gyroorientation[3] =
        high_filter_num[0] * GlobalVariables.gyroorientation[0] +
            high_filter_num[1] * GlobalVariables.gyroangle_x[0] +
            high_filter_num[2] * GlobalVariables.gyroangle_xx[0] -
            high_filter_den[1] * GlobalVariables.gyroangle_y[0] -
            high_filter_den[2] * GlobalVariables.gyroangle_yy[0];
    GlobalVariables.gyroorientation[4] =
        high_filter_num[0] * GlobalVariables.gyroorientation[1] +
            high_filter_num[1] * GlobalVariables.gyroangle_x[1] +
            high_filter_num[2] * GlobalVariables.gyroangle_xx[1] -
            high_filter_den[1] * GlobalVariables.gyroangle_y[1] -
            high_filter_den[2] * GlobalVariables.gyroangle_yy[1];
    GlobalVariables.gyroorientation[5] =
        high_filter_num[0] * GlobalVariables.gyroorientation[2] +
            high_filter_num[1] * GlobalVariables.gyroangle_x[2] +
            high_filter_num[2] * GlobalVariables.gyroangle_xx[2] -
            high_filter_den[1] * GlobalVariables.gyroangle_y[2] -
            high_filter_den[2] * GlobalVariables.gyroangle_yy[2];

    GlobalVariables.gyroangle_x = [
      GlobalVariables.gyroorientation[0],
      GlobalVariables.gyroorientation[1],
      GlobalVariables.gyroorientation[2]
    ];
    GlobalVariables.gyroangle_xx = [
      GlobalVariables.gyroangle_x[0],
      GlobalVariables.gyroangle_x[1],
      GlobalVariables.gyroangle_x[2]
    ];
    GlobalVariables.gyroangle_y = [
      GlobalVariables.gyroorientation[3],
      GlobalVariables.gyroorientation[4],
      GlobalVariables.gyroorientation[5]
    ];
    GlobalVariables.gyroangle_yy = [
      GlobalVariables.gyroangle_y[0],
      GlobalVariables.gyroangle_y[1],
      GlobalVariables.gyroangle_y[2]
    ];

// 가속도 데이터를 이용한 Roll, Pitch 계산
    double accelRoll = (atan2(
            GlobalVariables.accelerometerValues[0],
            sqrt(GlobalVariables.accelerometerValues[1] *
                    GlobalVariables.accelerometerValues[1] +
                GlobalVariables.accelerometerValues[2] *
                    GlobalVariables.accelerometerValues[2]))) *
        (180 / pi);
    double accelPitch = (atan2(
            GlobalVariables.accelerometerValues[1],
            sqrt(GlobalVariables.accelerometerValues[0] *
                    GlobalVariables.accelerometerValues[0] +
                GlobalVariables.accelerometerValues[2] *
                    GlobalVariables.accelerometerValues[2]))) *
        (180 / pi);
    double accelYaw = (atan2(
            sqrt(GlobalVariables.accelerometerValues[0] *
                    GlobalVariables.accelerometerValues[0] +
                GlobalVariables.accelerometerValues[1] *
                    GlobalVariables.accelerometerValues[1]),
            GlobalVariables.accelerometerValues[2])) *
        (180 / pi);

// 2차 저역 통과 필터의 필터링 과정
    GlobalVariables.accorientation[0] = low_filter_num[0] * accelRoll +
        low_filter_num[1] * GlobalVariables.accangle_x[0] +
        low_filter_num[2] * GlobalVariables.accangle_xx[0] -
        low_filter_den[1] * GlobalVariables.accangle_y[0] -
        low_filter_den[2] * GlobalVariables.accangle_yy[0];
    GlobalVariables.accorientation[1] = low_filter_num[0] * accelPitch +
        low_filter_num[1] * GlobalVariables.accangle_x[1] +
        low_filter_num[2] * GlobalVariables.accangle_xx[1] -
        low_filter_den[1] * GlobalVariables.accangle_y[1] -
        low_filter_den[2] * GlobalVariables.accangle_yy[1];
    GlobalVariables.accorientation[2] = low_filter_num[0] * accelYaw +
        low_filter_num[1] * GlobalVariables.accangle_x[2] +
        low_filter_num[2] * GlobalVariables.accangle_xx[2] -
        low_filter_den[1] * GlobalVariables.accangle_y[2] -
        low_filter_den[2] * GlobalVariables.accangle_yy[2];

    GlobalVariables.accangle_x = [accelRoll, accelPitch, accelYaw];
    GlobalVariables.accangle_xx = [
      GlobalVariables.accangle_x[0],
      GlobalVariables.accangle_x[1],
      GlobalVariables.accangle_x[2]
    ];
    GlobalVariables.accangle_y = [
      GlobalVariables.accorientation[0],
      GlobalVariables.accorientation[1],
      GlobalVariables.accorientation[2]
    ];
    GlobalVariables.accangle_yy = [
      GlobalVariables.accangle_y[0],
      GlobalVariables.accangle_y[1],
      GlobalVariables.accangle_y[2]
    ];

    GlobalVariables.orientation[0] =
        GlobalVariables.accorientation[0] + GlobalVariables.gyroorientation[3];
    GlobalVariables.orientation[1] =
        GlobalVariables.accorientation[1] + GlobalVariables.gyroorientation[4];
    GlobalVariables.orientation[2] = GlobalVariables
        .gyroorientation[5]; //  GlobalVariables.accorientation[2]
    print(
        '${GlobalVariables.orientation[0].toStringAsFixed(2)}, ${GlobalVariables.orientation[1].toStringAsFixed(2)}, ${GlobalVariables.orientation[2].toStringAsFixed(2)} ');
    // print(
    //     '${GlobalVariables.orientation[0].toStringAsFixed(2)}, ${GlobalVariables.orientation[1].toStringAsFixed(2)}, ${GlobalVariables.orientation[2].toStringAsFixed(2)}   :   ${GlobalVariables.accorientation[0].toStringAsFixed(2)}, ${GlobalVariables.accorientation[1].toStringAsFixed(2)}, ${GlobalVariables.accorientation[2].toStringAsFixed(2)}   :   ${GlobalVariables.gyroorientation[3].toStringAsFixed(2)}, ${GlobalVariables.gyroorientation[4].toStringAsFixed(2)}, ${GlobalVariables.gyroorientation[5].toStringAsFixed(2)}');
  }
}
