import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import './UDP.dart';

class SetTxData {
  // static List<int> TxData = List<int>.filled(15, 0);
  static List<int> TxData = List<int>.filled(27, 0);

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

  static void setPivot(int xvalue, int yvalue, double height) {
    GraphicVariables.selectColor11x11[yvalue][xvalue] = Colors.red;
    SetTxData.Button_Pedal = 7;
    SetTxData.Pivot_Rcx = (xvalue - 5);
    SetTxData.Pivot_Rcy = -(yvalue - 5);
    GraphicVariables.circlepoint = Offset(
        (xvalue * height) + (height / 2), (yvalue * height) + (height / 2));
  }
}

class AnimationVariables {
  static bool isRotateVisible = false;
  static bool isRotateshow = false;
  static bool isArrowshow = false;
  static bool isArrowVisible = false;
  static late AnimationController rotateanimationController;
  static late AnimationController streatanimationController;
  static int drive_selectedButtonIndex = -1;
  static List<String> driveModes = ['P', 'R', 'N', 'D']; // 드라이브 모드 리스트

  static bool isScrollDragging = false; // 클래스에 포함된 변수
  static bool isJoyLeftDragging = false; // 클래스에 포함된 변수
  static bool isJoyRightDragging = false; // 클래스에 포함된 변수
  static bool isControlSelect = false;
}

class GlobalVariables {
  static bool showContainer = false; // 클래스에 포함된 변수
  static bool isWifiConnected = false;
  static bool isUDPConnected = false;
  static DateTime nowDateTime = DateTime.now();

  static String PADIp = "";
  static int PADPort = 0;
  static String TargetIp = "";
  static int TargetPort = 0;

  static double LeftCrab_Threshold = 2.5;
  static double RightCrab_Threshold = -2.5;
  static double FWSCrab_Threshold = 4.5;
  static double D4Crab_Threshold = -4.5;

  static TextEditingController leftcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.LeftCrab_Threshold).toString());
  static TextEditingController rightcrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.RightCrab_Threshold).toString());
  static TextEditingController fwscrabthresholdController =
      TextEditingController(
          text: (GlobalVariables.FWSCrab_Threshold).toString());
  static TextEditingController d4crabthresholdController =
      TextEditingController(
          text: (GlobalVariables.D4Crab_Threshold).toString());

  static List<String> DriveMode = [
    "Parking",
    "Reverse",
    "Neutral",
    "Drive",
    "Left Crab",
    "Right Crab",
    "Spin",
    "PIVOT",
    "None",
    "None",
    "FWS",
    "D4",
    "Reset"
  ];
}

class TimerMonitor {
  StreamController<bool> _wifiStreamController = StreamController<bool>();
  Stream<bool> get wifiStream => _wifiStreamController.stream;
  final UDP udp = UDP();

  void startMonitoring() {
    Timer.periodic(Duration(milliseconds: 50), (timer) async {
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
          SetTxData.Pivot_Rcx = 0;
          SetTxData.Pivot_Rcy = 0;

          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            AnimationVariables.streatanimationController.stop();
          }
          break;
        case 4:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();
          SetTxData.Pivot_Rcx = 0;
          SetTxData.Pivot_Rcy = 0;
          AnimationVariables.isArrowVisible = true;
          if (!AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = true;
            AnimationVariables.streatanimationController.repeat();
          }
          break;
        case 5:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();
          SetTxData.Pivot_Rcx = 0;
          SetTxData.Pivot_Rcy = 0;
          AnimationVariables.isArrowVisible = false;
          if (!AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = true;
            AnimationVariables.streatanimationController.repeat();
          }
          break;
        case 6:
        case 7:
          AnimationVariables.drive_selectedButtonIndex = -1;
          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            AnimationVariables.streatanimationController.stop();
          }
          break;
        default:
          AnimationVariables.drive_selectedButtonIndex = -1;
          GraphicVariables.resetColor();
          SetTxData.Pivot_Rcx = 0;
          SetTxData.Pivot_Rcy = 0;

          if (AnimationVariables.isArrowshow) {
            AnimationVariables.isArrowshow = false;
            AnimationVariables.streatanimationController.stop();
          }
          break;
      }

      // Date & Time
      GlobalVariables.nowDateTime = DateTime.now();
      if (GlobalVariables.isUDPConnected) {
        udp.bind(GlobalVariables.PADIp, GlobalVariables.PADPort);
        udp.send(
            SetTxData.TxData,
            GlobalVariables.PADIp,
            GlobalVariables.PADPort,
            GlobalVariables.TargetIp,
            GlobalVariables.TargetPort);
      } else {}
    });
  }

  void dispose() {
    _wifiStreamController.close();
  }
}
