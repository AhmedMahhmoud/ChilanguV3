import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/permissions_data.dart';

import '../../../main.dart';
import 'CameraPickerScreen.dart';

class SystemScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SystemScanPageState();
}

class _SystemScanPageState extends State<SystemScanPage> {
  var qrText = '';
  AudioCache player = AudioCache();
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  flipCamera() async {
    setState(() {
      if (cameraLensDirection == CameraLensDirection.back) {
        cameraLensDirection = CameraLensDirection.front;
      } else {
        cameraLensDirection = CameraLensDirection.back;
      }
    });

    await controller.flipCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NotificationItem(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(flex: 1, child: _buildQrView(context)),
            ],
          ),
          Positioned(
            left: 4.0,
            top: 4.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  locator.locator<PermissionHan>().isEnglishLocale()
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const NavScreenTwo(1)),
                      (Route<dynamic> route) => false);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 4.0,
            right: 4.0,
            child: SafeArea(
                child: FloatingActionButton(
              backgroundColor: ColorManager.primary,
              onPressed: () {
                flipCamera();
              },
              child: const Icon(
                Icons.swap_horizontal_circle_sharp,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  var shiftQrCode;
  void _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      try {
        log(scanData.code);
        qrText = scanData.code;

        shiftQrCode =
            Provider.of<ShiftApi>(context, listen: false).qrShift.shiftQrCode;

        if (cameraLensDirection == CameraLensDirection.back) {
          await flipCamera();
          controller?.pauseCamera();

          player.play("cap.wav");
          await Future.delayed(
            const Duration(seconds: 1),
          ).then((value) {
            secondPageRoute();
          });
        } else {
          controller?.pauseCamera();
          player.play("cap.wav");
          secondPageRoute();
        }
      } catch (e) {
        print(e);
      }
    });
  }

  secondPageRoute() async {
    if (shiftQrCode != null && qrText != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPicker(
              qrText: qrText,
              shiftQrcode: shiftQrCode,
            ),
          ));
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
