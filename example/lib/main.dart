import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safetynet_attestation/flutter_safetynet_attestation.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GooglePlayServicesAvailability _gmsStatus;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    GooglePlayServicesAvailability gmsAvailability;
    try {
      gmsAvailability =
          await FlutterSafetynetAttestation.googlePlayServicesAvailability();
    } on PlatformException {
      gmsAvailability = null;
    }

    if (!mounted) return;

    setState(() {
      _gmsStatus = gmsAvailability;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SafetyNet Attestation plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              'Google Play Services status: ${_gmsStatus ?? 'unknown'}',
              textAlign: TextAlign.center,
            ),
            Offstage(
              offstage: _gmsStatus != GooglePlayServicesAvailability.success,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: SafetyNetAttestationWidget(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SafetyNetAttestationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SafetyNetAttestationWidgetState();
}

class _SafetyNetAttestationWidgetState
    extends State<SafetyNetAttestationWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    } else {
      return RaisedButton(
        onPressed: () {
          requestSafetyNetAttestation();
          setState(() {
            isLoading = true;
          });
        },
        child: Text('Request SafetyNet Attestation'),
      );
    }
  }

  void requestSafetyNetAttestation() async {
    String dialogTitle, dialogMessage;
    try {
      JWSPayload res =
          await FlutterSafetynetAttestation.safetyNetAttestationPayload(
              'nonce');

      dialogTitle = 'SafetyNet Attestation Payload';
      dialogMessage = res?.toString();
    } catch (e) {
      dialogTitle = 'ERROR - SafetyNet Attestation Payload';

      if (e is PlatformException) {
        dialogMessage = e.message;
      } else {
        dialogMessage = e?.toString();
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: Text(dialogMessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });

    setState(() {
      isLoading = false;
    });
  }
}
