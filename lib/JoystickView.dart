import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:math'; // dart:math 패키지 가져오기

import './main.dart';
import './DriveModeButton.dart';
import './SettingView.dart';
import './global.dart';
import './LinePainter.dart';

class JoystickView extends StatefulWidget {
  const JoystickView({super.key});

  @override
  State<JoystickView> createState() => _JoystickViewState();
}

class _JoystickViewState extends State<JoystickView> {
  double _leftcircleX = 0.0;
  double _leftcircleY = 0.0;
  double _rightcircleX = 0.0;
  double _rightcircleY = 0.0;

  @override
  Widget build(BuildContext context) {
    final Size_Height = MediaQuery.of(context).size.height;
    final Size_Width = MediaQuery.of(context).size.width;
    final cellWidth = (Size_Width / 2) / 11;
    final cellHeight = ((Size_Height * 0.6) - 5) / 11;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //vehicle Speed & View
        Container(
          height: Size_Height * 0.7,
          // decoration: BoxDecoration(
          //   color: Color.fromARGB(255, 146, 74, 74),
          // ),
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Vehicle Speed
                    Container(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: -2,
                          sigmaY: -2,
                        ),
                        child: Container(
                          width: ((Size_Height * 0.35) - 5),
                          height: ((Size_Height * 0.35) - 5),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular((Size_Height * 0.35)),
                            gradient: RadialGradient(
                              center: Alignment(0, 0),
                              radius: 0.5,
                              colors: <Color>[
                                Color(0xFF2A2A2A),
                                Color(0xFFE95861)
                              ],
                              stops: <double>[0.775, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE95861),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment(0.0, 0.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  child: Text(
                                    'Vehicle Speed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.015),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    '${SetRxData.Vehicle_Speed}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.05),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    'km/h',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.015),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ]),
                        ),
                      ),
                    ),
                    // Joystick

                    Container(
                      width: ((Size_Height * 0.35) - 5),
                      height: ((Size_Height * 0.35) - 5),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onPanStart: ((details) {
                          Haptics.vibrate(HapticsType.light);
                        }),
                        onPanUpdate: (details) {
                          setState(() {
                            AnimationVariables.isJoyLeftDragging =
                                true; // 드래그 중임을 나타냄

                            // 새로운 x, y 좌표 계산
                            double newX = _leftcircleX + details.delta.dx;
                            double newY = _leftcircleY + details.delta.dy;

                            // 원이 원형 경계 내에 있도록 제한
                            double radius =
                                ((Size_Height * 0.35) - (Size_Height * 0.1)) /
                                    2;
                            double distance = sqrt(newX * newX + newY * newY);
                            if (distance < radius) {
                              _leftcircleX = newX;
                              _leftcircleY = newY;
                            } else {
                              // 원의 경계를 벗어나면 최대 반지름 방향으로 이동
                              double angle = atan2(newY, newX);
                              _leftcircleX = radius * cos(angle);
                              _leftcircleY = radius * sin(angle);
                            }
                            SetTxData.Joystick_Input_Left_X =
                                mapValue(_leftcircleX, 0, (radius), 0, 100)
                                    .toInt();
                            SetTxData.Joystick_Input_Left_Y =
                                mapValue(_leftcircleY, 0, (radius), 0, 100)
                                    .toInt();
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            AnimationVariables.isJoyLeftDragging =
                                false; // 드래그 종료됨
                            _leftcircleX = 0;
                            _leftcircleY = 0;
                            SetTxData.Joystick_Input_Left_X = 0;
                            SetTxData.Joystick_Input_Left_Y = 0;
                          });
                        },
                        child: Container(
                          width: (Size_Height * 0.35),
                          height: (Size_Height * 0.35),
                          // padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: (Size_Height * 0.35),
                                height: (Size_Height * 0.35),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      (Size_Height * 0.35)),
                                  gradient: RadialGradient(
                                    center: Alignment(0, 0),
                                    radius: 0.5,
                                    colors: <Color>[
                                      Color(0xFF2A2A2A),
                                      Color(0xFF29439E)
                                    ],
                                    stops: <double>[0.775, 1],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF29439E),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                              // // Circle 표시
                              Positioned(
                                left: (Size_Height * 0.35) / 2 +
                                    _leftcircleX -
                                    (Size_Height * 0.05),
                                top: (Size_Height * 0.35) / 2 +
                                    _leftcircleY -
                                    (Size_Height * 0.05),
                                child: Container(
                                  width: Size_Height * 0.1,
                                  height: Size_Height * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: ((Size_Height * 0.6) - 5),
                          height: ((Size_Height * 0.6) - 5),
                          // decoration: BoxDecoration(
                          //     color: Color(0xFF424242),
                          //     boxShadow: [
                          //       BoxShadow(
                          //           color: Color(0x40000000),
                          //           offset: Offset(0, 4),
                          //           blurRadius: 2)
                          //     ]),
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                              child: RepaintBoundary(
                                child: Transform.rotate(
                                  angle: GlobalVariables.orientation[1] /
                                      (180 / pi),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                            child: AspectRatio(
                                          aspectRatio: 1 / 3,
                                          child: Image.asset(
                                            'assets/images/car.png',
                                          ),
                                        )),
                                        GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 7,
                                          ),
                                          itemCount: 7 * 7,
                                          itemBuilder: (context, index) {
                                            int row = index ~/ 7;
                                            int col = index % 7;
                                            Widget child;
                                            switch (col) {
                                              case 2:
                                                switch (row) {
                                                  case 2:
                                                    child = buildWheel(
                                                      Size_Width: Size_Width,
                                                      Size_Height: Size_Height,
                                                      angle: (SetRxData
                                                                  .Measured_Steer_Angle_Fl *
                                                              (-pi)) /
                                                          180,
                                                    );
                                                    break;
                                                  case 4:
                                                    child = buildWheel(
                                                      Size_Width: Size_Width,
                                                      Size_Height: Size_Height,
                                                      angle: (SetRxData
                                                                  .Measured_Steer_Angle_Rl *
                                                              (-pi)) /
                                                          180,
                                                    );
                                                    break;
                                                  default:
                                                    child = SizedBox
                                                        .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                                    break;
                                                }
                                                break;
                                              case 4:
                                                switch (row) {
                                                  case 2:
                                                    child = buildWheel(
                                                      Size_Width: Size_Width,
                                                      Size_Height: Size_Height,
                                                      angle: (SetRxData
                                                                  .Measured_Steer_Angle_Fr *
                                                              (-pi)) /
                                                          180,
                                                    );
                                                    break;
                                                  case 4:
                                                    child = buildWheel(
                                                      Size_Width: Size_Width,
                                                      Size_Height: Size_Height,
                                                      angle: (SetRxData
                                                                  .Measured_Steer_Angle_Rr *
                                                              (-pi)) /
                                                          180,
                                                    );
                                                    break;
                                                  default:
                                                    child = SizedBox
                                                        .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                                    break;
                                                }
                                                break;
                                              default:
                                                child = SizedBox
                                                    .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                                break;
                                            }

                                            return GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                // height: cellHeight,
                                                decoration: BoxDecoration(
                                                    // color: Colors.red,
                                                    // shape: BoxShape.circle,
                                                    ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                            GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                              ),
                              itemCount: 6 * 6,
                              itemBuilder: (context, index) {
                                int row = index ~/ 6;
                                int col = index % 6;
                                Widget child;
                                switch (col) {
                                  case 1:
                                    switch (row) {
                                      case 0:
                                        child = buildWheelInfo(
                                          Size_Width: Size_Width,
                                          Size_Height: Size_Height,
                                          angleText:
                                              '${SetRxData.Measured_Steer_Angle_Fl}',
                                          currentText:
                                              '${SetRxData.Measured_Steer_Current_Fl}',
                                        );
                                        break;
                                      case 5:
                                        child = buildWheelInfo(
                                          Size_Width: Size_Width,
                                          Size_Height: Size_Height,
                                          angleText:
                                              '${SetRxData.Measured_Steer_Angle_Rl}',
                                          currentText:
                                              '${SetRxData.Measured_Steer_Current_Rl}',
                                        );
                                        break;
                                      default:
                                        child = SizedBox
                                            .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                        break;
                                    }
                                    break;
                                  case 4:
                                    switch (row) {
                                      case 0:
                                        child = buildWheelInfo(
                                          Size_Width: Size_Width,
                                          Size_Height: Size_Height,
                                          angleText:
                                              '${SetRxData.Measured_Steer_Angle_Fr}',
                                          currentText:
                                              '${SetRxData.Measured_Steer_Current_Fr}',
                                        );
                                        break;
                                      case 5:
                                        child = buildWheelInfo(
                                          Size_Width: Size_Width,
                                          Size_Height: Size_Height,
                                          angleText:
                                              '${SetRxData.Measured_Steer_Angle_Rr}',
                                          currentText:
                                              '${SetRxData.Measured_Steer_Current_Rr}',
                                        );
                                        break;
                                      default:
                                        child = SizedBox
                                            .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                        break;
                                    }
                                    break;
                                  default:
                                    child = SizedBox
                                        .shrink(); // 나머지 경우에는 빈 상태로 설정합니다.
                                    break;
                                }

                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    // height: cellHeight,
                                    decoration: BoxDecoration(
                                        // color: Colors.red,
                                        // shape: BoxShape.circle,
                                        ),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                            ClipRect(
                              // Overflow 속성 사용
                              child: CustomPaint(
                                foregroundPainter:
                                    LinePainter(GraphicVariables.circlepoint),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 11,
                                  ),
                                  itemCount: 11 * 11,
                                  itemBuilder: (context, index) {
                                    int row = index ~/ 11;
                                    int col = index % 11;

                                    return GestureDetector(
                                      onTap: () {
                                        // print('${row}, ${col}');
                                        setState(() {
                                          if ((row == 5) & (col == 5)) {
                                            Haptics.vibrate(HapticsType.light);
                                            GraphicVariables.resetColor();
                                            GraphicVariables
                                                    .selectColor11x11[row]
                                                [col] = Colors.green;
                                            SetTxData.Button_Pedal = 6;
                                            SetTxData.Pivot_Rcx = 0;
                                            SetTxData.Pivot_Rcy = 0;
                                          } else {
                                            switch (row) {
                                              case 0:
                                              case 10:
                                                if ((col < 2) | (col > 8)) {
                                                  Haptics.vibrate(
                                                      HapticsType.light);
                                                  GraphicVariables.resetColor();
                                                  GraphicVariables.setPivot(
                                                      col, row, cellHeight);
                                                } else {}
                                                break;
                                              case 1:
                                              case 9:
                                                if ((col < 3) | (col > 7)) {
                                                  Haptics.vibrate(
                                                      HapticsType.light);
                                                  GraphicVariables.resetColor();
                                                  GraphicVariables.setPivot(
                                                      col, row, cellHeight);
                                                } else {}
                                                break;
                                              case 2:
                                              case 3:
                                              case 7:
                                              case 8:
                                                if ((col < 4) | (col > 6)) {
                                                  Haptics.vibrate(
                                                      HapticsType.light);
                                                  GraphicVariables.resetColor();
                                                  GraphicVariables.setPivot(
                                                      col, row, cellHeight);
                                                } else {}
                                                break;
                                              case 4:
                                              case 5:
                                              case 6:
                                                if (col != 5) {
                                                  Haptics.vibrate(
                                                      HapticsType.light);
                                                  GraphicVariables.resetColor();
                                                  GraphicVariables.setPivot(
                                                      col, row, cellHeight);
                                                } else {}
                                                break;
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: cellHeight,
                                        decoration: BoxDecoration(
                                          color: GraphicVariables
                                              .selectColor11x11[row][col],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (AnimationVariables.isArrowVisible &
                                AnimationVariables.isArrowshow)
                              Positioned(
                                left: -50, // 가운데에서 오른쪽으로 10만큼 떨어진 위치
                                child: Icon(Icons.navigate_before,
                                    size: (Size_Width * 0.2)),
                                // child: ShaderMask(
                                //   shaderCallback: (Rect bounds) {
                                //     return LinearGradient(
                                //       begin: Alignment(
                                //           -1 -
                                //               AnimationVariables
                                //                   .streatanimationController
                                //                   .value,
                                //           0),
                                //       end: Alignment(
                                //           1 -
                                //               AnimationVariables
                                //                   .streatanimationController
                                //                   .value,
                                //           0),
                                //       colors: [
                                //         Colors.transparent,
                                //         Colors.white,
                                //         Colors.transparent,
                                //       ],
                                //     ).createShader(bounds);
                                //   },
                                //   blendMode: BlendMode.modulate,
                                //   child: Icon(Icons.navigate_before,
                                //       size: (Size_Width * 0.2)),
                                // ),
                              )
                            else if (!AnimationVariables.isArrowVisible &
                                AnimationVariables.isArrowshow)
                              Positioned(
                                right: -50, // 가운데에서 오른쪽으로 10만큼 떨어진 위치
                                child: Icon(Icons.navigate_next,
                                    size: (Size_Width * 0.2)),
                                // child: ShaderMask(
                                //   shaderCallback: (Rect bounds) {
                                //     return LinearGradient(
                                //       begin: Alignment(
                                //           -1 +
                                //               AnimationVariables
                                //                   .streatanimationController
                                //                   .value,
                                //           0),
                                //       end: Alignment(
                                //           1 +
                                //               AnimationVariables
                                //                   .streatanimationController
                                //                   .value,
                                //           0),
                                //       colors: [
                                //         Colors.transparent,
                                //         Colors.white,
                                //         Colors.transparent,
                                //       ],
                                //     ).createShader(bounds);
                                //   },
                                //   blendMode: BlendMode.modulate,
                                //   child: Icon(Icons.navigate_next,
                                //       size: (Size_Width * 0.2)),
                                // ),
                              ),
                            if (AnimationVariables.isRotateVisible &
                                AnimationVariables.isRotateshow)
                              AnimatedBuilder(
                                animation: AnimationVariables
                                    .rotateanimationController,
                                builder: (context, child) {
                                  return RepaintBoundary(
                                      child: Transform.rotate(
                                    angle: AnimationVariables
                                            .rotateanimationController.value *
                                        2.0 *
                                        pi,
                                    child: child,
                                  ));
                                },
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.red,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.rotate_right,
                                    size: (Size_Width * 0.2),
                                  ),
                                ),
                              )
                            else if (!AnimationVariables.isRotateVisible &
                                AnimationVariables.isRotateshow)
                              AnimatedBuilder(
                                animation: AnimationVariables
                                    .rotateanimationController,
                                builder: (context, child) {
                                  return RepaintBoundary(
                                      child: Transform.rotate(
                                    angle: AnimationVariables
                                            .rotateanimationController.value *
                                        -2.0 *
                                        pi,
                                    child: child,
                                  ));
                                },
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.red,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.rotate_left,
                                    size: (Size_Width * 0.2),
                                  ),
                                ),
                              ),
                          ])),
                      Container(
                        width: (Size_Width / 2),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: (Size_Width * 0.15),
                                height: ((Size_Height * 0.09)),
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (SetTxData.Drive_Mode_Switch == 0) {
                                      SetTxData.Drive_Mode_Switch = 1;
                                    } else {
                                      SetTxData.Drive_Mode_Switch = 0;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF212121), // 버튼 색상
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
                                      SetTxData.Drive_Mode_Switch == 0
                                          ? GlobalVariables
                                              .Drive_Mode_Switch_Label[0]
                                          : GlobalVariables
                                              .Drive_Mode_Switch_Label[1],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: (Size_Width * 0.015),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: (Size_Width * 0.15),
                                height: ((Size_Height * 0.09)),
                                decoration: BoxDecoration(
                                  color: Color(0xFF212121),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Text(
                                    'X : ${SetTxData.Pivot_Rcx}, Y : ${SetTxData.Pivot_Rcy}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.015),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: (Size_Width * 0.15),
                                height: ((Size_Height * 0.09)),
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Haptics.vibrate(HapticsType.light);
                                    // print('Reset Button Click');
                                    GraphicVariables.resetColor();
                                    SetTxData.Pivot_Rcx = 0;
                                    SetTxData.Pivot_Rcy = 0;
                                    SetTxData.Button_Pedal = 12;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF212121), // 버튼 색상
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
                                      'Reset Button',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: (Size_Width * 0.015),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Operating Mode
                    Container(
                      child: AnimatedBuilder(
                        animation:
                            AnimationVariables.OperatinganimationController,
                        builder: (context, child) {
                          return Container(
                            width: ((Size_Height * 0.35) - 5),
                            height: ((Size_Height * 0.35) - 5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Size_Height * 0.35),
                              gradient: RadialGradient(
                                center: Alignment(0, 0),
                                radius: 0.5,
                                colors: AnimationVariables.isOperatingshow
                                    ? <Color>[
                                        Color(0xFF2A2A2A),
                                        Color.fromARGB(255, 146, 255, 159),
                                      ]
                                    : <Color>[
                                        Color(0xFF2A2A2A),
                                        AnimationVariables
                                            .Operatinganimation.value!
                                      ],
                                stops: <double>[0.775, 1],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AnimationVariables.isOperatingshow
                                      ? Color.fromARGB(255, 146, 255, 159)
                                      : AnimationVariables
                                          .Operatinganimation.value!,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            alignment: Alignment(0.0, 0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  child: Text(
                                    'Operating Mode',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.015),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    '${(SetRxData.Corner_Mode >= 0 && SetRxData.Corner_Mode < GlobalVariables.DriveMode.length) ? GlobalVariables.DriveMode[SetRxData.Corner_Mode] : 'Parking'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (Size_Width * 0.03),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Joystick
                    Container(
                      width: ((Size_Height * 0.35) - 5),
                      height: ((Size_Height * 0.35) - 5),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onPanStart: ((details) {
                          Haptics.vibrate(HapticsType.light);
                        }),
                        onPanUpdate: (details) {
                          setState(() {
                            AnimationVariables.isJoyRightDragging =
                                true; // 드래그 중임을 나타냄

                            // 새로운 x, y 좌표 계산
                            double newX = _rightcircleX + details.delta.dx;
                            double newY = _rightcircleY + details.delta.dy;

                            // 원이 원형 경계 내에 있도록 제한
                            double radius =
                                ((Size_Height * 0.35) - (Size_Height * 0.1)) /
                                    2;
                            double distance = sqrt(newX * newX + newY * newY);
                            if (distance < radius) {
                              _rightcircleX = newX;
                              _rightcircleY = newY;
                            } else {
                              // 원의 경계를 벗어나면 최대 반지름 방향으로 이동
                              double angle = atan2(newY, newX);
                              _rightcircleX = radius * cos(angle);
                              _rightcircleY = radius * sin(angle);
                            }
                            SetTxData.Joystick_Input_Right_X =
                                mapValue(_rightcircleX, 0, (radius), 0, 100)
                                    .toInt();
                            SetTxData.Joystick_Input_Right_Y =
                                mapValue(_rightcircleY, 0, (radius), 0, 100)
                                    .toInt();
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            AnimationVariables.isJoyRightDragging =
                                false; // 드래그 종료됨
                            _rightcircleX = 0;
                            _rightcircleY = 0;
                            SetTxData.Joystick_Input_Right_X = 0;
                            SetTxData.Joystick_Input_Right_Y = 0;
                          });
                        },
                        child: Container(
                          width: (Size_Height * 0.35),
                          height: (Size_Height * 0.35),
                          // padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: (Size_Height * 0.35),
                                height: (Size_Height * 0.35),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      (Size_Height * 0.35)),
                                  gradient: RadialGradient(
                                    center: Alignment(0, 0),
                                    radius: 0.5,
                                    colors: <Color>[
                                      Color(0xFF2A2A2A),
                                      Color(0xFF29439E)
                                    ],
                                    stops: <double>[0.775, 1],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF29439E),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                              // // Circle 표시
                              Positioned(
                                left: (Size_Height * 0.35) / 2 +
                                    _rightcircleX -
                                    (Size_Height * 0.05),
                                top: (Size_Height * 0.35) / 2 +
                                    _rightcircleY -
                                    (Size_Height * 0.05),
                                child: Container(
                                  width: Size_Height * 0.1,
                                  height: Size_Height * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ]),
        ),
        //Drive Mode
        Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                width: (Size_Width * 0.15),
                alignment: Alignment(0.0, 0.0),
                child: Image.asset('assets/images/mobis.png'),
              ),
              Container(
                  height: (Size_Height * 0.15),
                  decoration: BoxDecoration(
                    color: Color(0xFF212121),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (Size_Width * 0.55),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(
                        AnimationVariables.driveModes.length,
                        (index) {
                          return DriveModeButton(
                            driveMode: AnimationVariables.driveModes[index],
                            isSelected: index ==
                                AnimationVariables.drive_selectedButtonIndex,
                            onPressed: () {
                              setState(() {
                                Haptics.vibrate(HapticsType.light);
                                AnimationVariables.drive_selectedButtonIndex =
                                    index;
                                // print('Drive Button Click');
                                SetTxData.Button_Pedal = AnimationVariables
                                    .drive_selectedButtonIndex;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  )),
              Container(
                width: (Size_Width * 0.15),
                height: (Size_Height * 0.15),
                // color: Color(0xFF212121),
              ),
            ]))
      ],
    );
  }

  double mapValue(
      double value, double inMin, double inMax, double outMin, double outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  Widget buildWheel({
    required double Size_Width,
    required double Size_Height,
    required double angle,
  }) {
    return Container(
      width: Size_Height * 0.07,
      height: Size_Height * 0.07,
      child: RepaintBoundary(
        child: Transform.rotate(
          angle: angle,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.asset('assets/images/wheel.png'),
          ),
        ),
      ),
    );
  }

  Widget buildWheelInfo({
    required double Size_Width,
    required double Size_Height,
    required String angleText,
    required String currentText,
  }) {
    return Column(
      children: [
        SizedBox(
            height: Size_Height * 0.01), // Add space between wheel and info
        buildInfoContainer(
          Size_Width: Size_Width,
          Size_Height: Size_Height,
          text: angleText,
          color: Color(0xFFEECCCC),
          unit: 'Deg',
        ),
        SizedBox(height: Size_Height * 0.01), // Add space between containers
        buildInfoContainer(
          Size_Width: Size_Width,
          Size_Height: Size_Height,
          text: currentText,
          color: Color(0xFFC6D3EE),
          unit: 'A',
        ),
      ],
    );
  }

  Widget buildInfoContainer({
    required double Size_Width,
    required double Size_Height,
    required String text,
    required Color color,
    required String unit,
  }) {
    return Container(
      width: Size_Width * 0.05,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Size_Width * 0.012,
                color: Color(0xFF212121),
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Size_Width * 0.006,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
