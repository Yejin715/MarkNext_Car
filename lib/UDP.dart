import 'dart:io';
import 'dart:typed_data';

import './global.dart';

class UDP {
  // RawDatagramSocket? _socket;
  // InternetAddress? _targetAddress;
  // int? _targetPort;

  UDP();

  Future<void> bind(String ip, int port) async {
    try {
      RawDatagramSocket _socket = await RawDatagramSocket.bind(ip, port);

      if (_socket != null) {
        _socket.listen((RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            Datagram? datagram = _socket.receive();
            if (datagram != null) {
              SetRxData.RxData = datagram.data;
              // print(SetRxData.RxData);
              RxData_Check(SetRxData.RxData);
            }
            _socket.close();
          }
        });

        GlobalVariables.isUDPConnected = true;
        // print('UDP 소켓이 바인딩되었습니다.');
      } else {
        // print('UDP 소켓이 바인딩되지 않았습니다.');
        GlobalVariables.isUDPConnected = false;
      }
    } catch (e) {
      // print('UDP 소켓이 바인딩되지 않았습니다.');
      print("bind error, ${e}");
      GlobalVariables.isUDPConnected = false;
    }
  }

  void send(List<int> message, String tab_ip, int tab_port, String target_ip,
      int target_port) async {
    try {
      RawDatagramSocket _socket =
          await RawDatagramSocket.bind(tab_ip, tab_port);
      InternetAddress _targetAddress = InternetAddress(target_ip);
      int _targetPort = target_port;
      if (_targetAddress != null && _targetPort != null) {
        // 정수를 바이트로 변환하여 전송
        message = TxData_Check(message);
        if (_socket != null) {
          _socket.send(message, _targetAddress, _targetPort);
        } else {}
        // print('Sent: $message');
      } else {
        // print('Target address and port not set.');
      }
      _socket.close();
    } catch (e) {
      print("send error, ${e}");
    }
  }

  List<int> TxData_Check(List<int> Data) {
    //Little Endian 계산
    Data[0] = ((SetTxData.Msg2_SBW_Cmd_Tx / 0.01).toInt() & 0xFF);
    Data[1] = (((SetTxData.Msg2_SBW_Cmd_Tx / 0.01).toInt() >> 8) & 0xFF);
    Data[2] = ((SetTxData.Accel_Pedal_Angle / 0.5).toInt() & 0xFF);
    Data[3] = (SetTxData.Button_Pedal & 0xFF);
    Data[4] = ((SetTxData.Joystick_Input_Left_X / 0.1).toInt() & 0xFF);
    Data[5] = (((SetTxData.Joystick_Input_Left_X / 0.1).toInt() >> 8) & 0xFF);
    Data[6] = ((SetTxData.Joystick_Input_Left_Y / 0.1).toInt() & 0xFF);
    Data[7] = (((SetTxData.Joystick_Input_Left_Y / 0.1).toInt() >> 8) & 0xFF);
    Data[8] = ((SetTxData.Joystick_Input_Right_X / 0.1).toInt() & 0xFF);
    Data[9] = (((SetTxData.Joystick_Input_Right_X / 0.1).toInt() >> 8) & 0xFF);
    Data[10] = ((SetTxData.Joystick_Input_Right_Y / 0.1).toInt() & 0xFF);
    Data[11] = (((SetTxData.Joystick_Input_Right_Y / 0.1).toInt() >> 8) & 0xFF);
    Data[12] = (SetTxData.Drive_Mode_Switch & 0xFF);
    Data[13] = (SetTxData.Pivot_Rcx & 0xFF);
    Data[14] = (SetTxData.Pivot_Rcy & 0xFF);
    // Data[15] = (SetTxData.Accel_X & 0xFF);
    // Data[16] = ((SetTxData.Accel_X >> 8) & 0xFF);
    // Data[17] = (SetTxData.Accel_Y & 0xFF);
    // Data[18] = ((SetTxData.Accel_Y >> 8) & 0xFF);
    // Data[19] = (SetTxData.Accel_Z & 0xFF);
    // Data[20] = ((SetTxData.Accel_Z >> 8) & 0xFF);
    // Data[21] = (SetTxData.Gyro_Y & 0xFF);
    // Data[22] = ((SetTxData.Gyro_Y >> 8) & 0xFF);
    // Data[23] = (SetTxData.Gyro_P & 0xFF);
    // Data[24] = ((SetTxData.Gyro_P >> 8) & 0xFF);
    // Data[25] = (SetTxData.Gyro_R & 0xFF);
    // Data[26] = ((SetTxData.Gyro_R >> 8) & 0xFF);
    return Data;
    // ByteData byteData = ByteData.sublistView(Uint8List.fromList(Data));

    // ByteData를 사용하여 signed int 값을 바이트 배열에 쓰기
    // byteData.setInt16(0, SetTxData.Msg2_SBW_Cmd_Tx, Endian.little);
    // byteData.setUint8(2, SetTxData.Accel_Pedal_Angle);
    // byteData.setUint8(3, SetTxData.Button_Pedal);
    // byteData.setInt16(4, SetTxData.Joystick_Input_Left_X, Endian.little);
    // byteData.setInt16(6, SetTxData.Joystick_Input_Left_Y, Endian.little);
    // byteData.setInt16(8, SetTxData.Joystick_Input_Right_X, Endian.little);
    // byteData.setInt16(10, SetTxData.Joystick_Input_Right_Y, Endian.little);
    // byteData.setUint8(12, SetTxData.Drive_Mode_Switch);
    // byteData.setInt8(13, SetTxData.Pivot_Rcx);
    // byteData.setInt8(14, SetTxData.Pivot_Rcy);
    // print(byteData.buffer.asUint8List());
    // print(SetTxData.Button_Pedal);
    // return byteData.buffer.asUint8List();
  }

  void RxData_Check(List<int> Data) {
    //Little Endian 계산
    SetRxData.Corner_Mode = Data[0];
    SetRxData.Mode_Disable_Button_Blink = Data[1];
    SetRxData.Corner_Mode_Disable_Button =
        extract2BytesConvertToInt(Data, 2, 3).toInt();
    SetRxData.Measured_Steer_Angle_Fl =
        (extract2BytesConvertToInt(Data, 4, 5) * 0.02).toInt();

    SetRxData.Target_Steer_Current_Fl =
        (extract3BytesConvertToInt(Data, 6, 7, 8) * 0.001).toInt();
    SetRxData.Measured_Steer_Current_Fl =
        (extract3BytesConvertToInt(Data, 9, 10, 11) * 0.001).toInt();
    SetRxData.Measured_Steer_Angle_Fr =
        (extract2BytesConvertToInt(Data, 12, 13) * 0.02).toInt();
    SetRxData.Target_Steer_Current_Fr =
        (extract3BytesConvertToInt(Data, 14, 15, 16) * 0.001).toInt();
    SetRxData.Measured_Steer_Current_Fr =
        (extract3BytesConvertToInt(Data, 17, 18, 19) * 0.001).toInt();
    SetRxData.Measured_Steer_Angle_Rl =
        (extract2BytesConvertToInt(Data, 20, 21) * 0.02).toInt();
    SetRxData.Target_Steer_Current_Rl =
        (extract3BytesConvertToInt(Data, 22, 23, 24) * 0.001).toInt();
    SetRxData.Measured_Steer_Current_Rl =
        (extract3BytesConvertToInt(Data, 25, 26, 27) * 0.001).toInt();
    SetRxData.Measured_Steer_Angle_Rr =
        (extract2BytesConvertToInt(Data, 28, 29) * 0.02).toInt();
    SetRxData.Target_Steer_Current_Rr =
        (extract3BytesConvertToInt(Data, 30, 31, 32) * 0.001).toInt();
    SetRxData.Measured_Steer_Current_Rr =
        (extract3BytesConvertToInt(Data, 33, 34, 35) * 0.001).toInt();
    SetRxData.Vehicle_Speed = Data[36];
    SetRxData.Battery_Soc = (Data[37]);
    // ByteData byteData = ByteData.sublistView(Uint8List.fromList(Data));

    // SetRxData.Corner_Mode = byteData.getUint8(0);
    // SetRxData.Mode_Disable_Button_Blink = byteData.getUint8(1);
    // SetRxData.Corner_Mode_Disable_Button = byteData.getUint16(2, Endian.little);
    // SetRxData.Measured_Steer_Angle_Fl =
    //     (byteData.getInt16(4, Endian.little) / 0.02).toInt();
    // SetRxData.Target_Steer_Current_Fl =
    //     (byteData.getInt32(6, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Current_Fl =
    //     (byteData.getInt32(9, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Angle_Fr =
    //     (byteData.getInt16(12, Endian.little) / 0.02).toInt();
    // SetRxData.Target_Steer_Current_Fr =
    //     (byteData.getInt32(14, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Current_Fr =
    //     (byteData.getInt32(17, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Angle_Rl =
    //     (byteData.getInt16(20, Endian.little) / 0.02).toInt();
    // SetRxData.Target_Steer_Current_Rl =
    //     (byteData.getInt32(22, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Current_Rl =
    //     (byteData.getInt32(25, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Angle_Rr =
    //     (byteData.getInt(28, Endian.little) / 0.02).toInt();
    // SetRxData.Target_Steer_Current_Rr =
    //     (byteData.getInt32(30, Endian.little) / 0.001).toInt();
    // SetRxData.Measured_Steer_Current_Rr =
    //     (byteData.getInt32(33, Endian.little) / 0.001).toInt();
    // SetRxData.Vehicle_Speed = byteData.getUint8(36);
    // SetRxData.Battery_Soc = (byteData.getUint8(37) / 0.5).toInt();
  }

  int extract2BytesConvertToInt(List<int> byteData, int index1, int index2) {
    int value = (byteData[index2] << 8) | byteData[index1];

    // 부호를 올바르게 처리하여 음수인 경우, int로 변환
    if (byteData[index2] & 0x80 != 0) {
      value |= (~0 << 16); // 16비트 정수에서 부호를 올바르게 설정
    }

    return value;
  }

  int extract3BytesConvertToInt(
      List<int> byteData, int index1, int index2, int index3) {
    int value =
        (byteData[index3] << 16) | (byteData[index2] << 8) | byteData[index1];

    // 부호를 올바르게 처리하여 음수인 경우, int로 변환
    if (byteData[index3] & 0x80 != 0) {
      value |= (~0 << 24); // 24비트 정수에서 부호를 올바르게 설정
    }

    return value;
  }
}
