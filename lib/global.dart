import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import './UDP.dart';

class SetTxData {
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

class GlobalVariables {
  static double pitch = 0.0, roll = 0.0, yaw = 0.0;
  static double yaw_init = 0;
  static int drive_selectedButtonIndex = 0;

  static bool isScrollDragging = false; // 클래스에 포함된 변수
  static bool isJoyLeftDragging = false; // 클래스에 포함된 변수
  static bool isJoyRightDragging = false; // 클래스에 포함된 변수
  static bool showContainer = false; // 클래스에 포함된 변수
  static bool isWifiConnected = false;
  static bool isUDPConnected = false;
  static bool isControlSelect = false;
  static bool isDataSendFlag = false;
  static DateTime nowDateTime = DateTime.now();

  static String PADIp = "";
  static int PADPort = 0;
  static String TargetIp = "";
  static int TargetPort = 0;

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
  // static List<int> TxData = List<int>.filled(15, 0);
  static List<int> TxData = List<int>.filled(27, 0);
  static List<int> RxData = List<int>.filled(38, 0);

  static Future<String> getIpAddress() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        for (var interface in await NetworkInterface.list()) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4) {
              return addr.address;
            }
          }
        }
      } else {
        GlobalVariables.isUDPConnected = false;
        return 'No network connection';
      }
    } catch (e) {
      GlobalVariables.isUDPConnected = false;
      print("getIpAddress error, ${e}");
      return 'Failed to get IP address';
    }
    return '';
  }

  static Future<void> initializePADIp() async {
    PADIp = await getIpAddress();
  }
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

      // Date & Time
      GlobalVariables.nowDateTime = DateTime.now();
      if (GlobalVariables.isUDPConnected) {
        udp.bind(GlobalVariables.PADIp, GlobalVariables.PADPort);
        // if (GlobalVariables.isDataSendFlag) {
        // udp.setTarget(GlobalVariables.TargetIp, GlobalVariables.TargetPort);
        udp.send(
            GlobalVariables.TxData,
            GlobalVariables.PADIp,
            GlobalVariables.PADPort,
            GlobalVariables.TargetIp,
            GlobalVariables.TargetPort);
        // } else {}
      } else {}
      // print(
      //     "${SetTxData.Accel_X} , ${SetTxData.Accel_Y} , ${SetTxData.Accel_Z}, ${SetTxData.Gyro_P} , ${SetTxData.Gyro_R} , ${SetTxData.Gyro_Y}, ${GlobalVariables.roll} , ${GlobalVariables.pitch} , ${GlobalVariables.yaw}, ${SetTxData.Msg2_SBW_Cmd_Tx}");
    });
  }

  void dispose() {
    // udp.close();
    _wifiStreamController.close();
  }
}
