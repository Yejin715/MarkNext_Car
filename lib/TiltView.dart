import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:math';

import './main.dart';
import './DriveModeButton.dart';
import './SettingView.dart';
import './global.dart';
import './LinePainter.dart';

class TiltView extends StatefulWidget {
  const TiltView({super.key});

  @override
  State<TiltView> createState() => _TiltViewState();
}

class _TiltViewState extends State<TiltView> {
  double ThrottleBarvalue = 0.0; // 쓰로틀 바의 현재 값
  double Pre_ThrottleBarvalue = 0.0; // 쓰로틀 바의 현재 값
  DateTime dragStartTime = DateTime.now();
  bool drag_fix = false;

  @override
  Widget build(BuildContext context) {
    final Size_Height = MediaQuery.of(context).size.height;
    final Size_Width = MediaQuery.of(context).size.width;
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
                Container(
                  width: (Size_Width / 5),
                  height: (Size_Height * 0.7),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onVerticalDragStart: (details) {
                      drag_fix = false;
                      Pre_ThrottleBarvalue = 0;
                      Haptics.vibrate(HapticsType.light);
                    },
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        AnimationVariables.isScrollDragging =
                            true; // 드래그 중임을 나타냄
                        // 드래그 위치에 따라 새 값 계산
                        double newValue = ThrottleBarvalue -
                            details.primaryDelta!; // 감도 조절 가능
                        // 값이 0에서 1000 사이에 유지되도록 함
                        ThrottleBarvalue =
                            newValue.clamp(0.0, (Size_Height * 0.56));
                        SetTxData.Accel_Pedal_Angle = mapValue(ThrottleBarvalue,
                                0, (Size_Height * 0.56), 0, 100)
                            .toInt();
                        if (((Pre_ThrottleBarvalue - 5) > ThrottleBarvalue) |
                            (ThrottleBarvalue > (Pre_ThrottleBarvalue + 5))) {
                          drag_fix = false;
                          dragStartTime = DateTime.now();
                          Pre_ThrottleBarvalue = ThrottleBarvalue;
                        } else {
                          Duration dragDuration =
                              DateTime.now().difference(dragStartTime);
                          if (dragDuration.inSeconds > 2) {
                            if (!drag_fix) {
                              Haptics.vibrate(HapticsType.error);
                            }
                            drag_fix = true;
                          }
                        }
                      });
                    },
                    onVerticalDragEnd: (details) {
                      // 드래그 종료됨
                      setState(() {
                        AnimationVariables.isScrollDragging = false;
                      });
                      if (!drag_fix) {
                        setState(() {
                          ThrottleBarvalue = 0;
                          SetTxData.Accel_Pedal_Angle = mapValue(
                            ThrottleBarvalue,
                            0,
                            (Size_Height * 0.56),
                            0,
                            100,
                          ).toInt();
                        });
                      }
                    },
                    child: Container(
                      width: (Size_Width * 0.5),
                      height: (Size_Height * 0.7),
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: Size_Width * 0.05,
                            height: Size_Height * 0.6,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular((Size_Width * 0.03)),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF212121),
                                  Color(0xFF272727),
                                  Color(0xFF212121),
                                ],
                                stops: [0.0, 0.5, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A2A2A),
                                borderRadius:
                                    BorderRadius.circular((Size_Width * 0.03)),
                                boxShadow: [
                                  // Inner shadow to give a concave effect
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(0, 0),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Color(0xFF2A2A2A).withOpacity(0.3),
                                    offset: Offset(0, 0),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2A2A2A),
                                    Color(0xFF2A2A2A),
                                    Color(0xFF2A2A2A),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: (Size_Height * 0.05), // 값에 따라 위치 조정
                            child: Container(
                              width: (Size_Width * 0.03),
                              height: (ThrottleBarvalue + (Size_Height * 0.01)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: drag_fix
                                      ? [
                                          Color.fromARGB(255, 82, 220, 86),
                                          Color.fromARGB(255, 161, 236, 163)
                                        ]
                                      : [
                                          const Color.fromARGB(
                                              255, 197, 70, 220),
                                          Color.fromARGB(255, 81, 153, 213)
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular((Size_Width * 0.03)),
                              ),
                            ),
                          ),
                          // 쓰로틀 바 표시
                          Positioned(
                            bottom: ThrottleBarvalue +
                                (Size_Height * 0.02), // 값에 따라 위치 조정
                            child: Container(
                              width: Size_Width * 0.1,
                              height: (Size_Height * 0.07),
                              child: Image.asset(
                                'assets/images/bar_button.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                    ),
                                  );
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
                                    ),
                                  );
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
                                // print(index);
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

class _SlideGradientTransform extends GradientTransform {
  final double percent;

  _SlideGradientTransform({required this.percent});
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(0, bounds.height * percent, 0);
  }
}
