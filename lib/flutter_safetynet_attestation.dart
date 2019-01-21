import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Don't forget to add the API key in your AndroidManifest.xml file
/// Plugin only supporting Android
class FlutterSafetynetAttestation {
  static const MethodChannel _channel =
      const MethodChannel('g123k/flutter_safetynet_attestation');

  static Future<GooglePlayServicesAvailability>
      googlePlayServicesAvailability() async {
    final String result =
        await _channel.invokeMethod('checkGooglePlayServicesAvailability');

    switch (result) {
      case 'success':
        return GooglePlayServicesAvailability.success;
      case 'service_missing':
        return GooglePlayServicesAvailability.service_missing;
      case 'service_updating':
        return GooglePlayServicesAvailability.service_updating;
      case 'service_version_update_required':
        return GooglePlayServicesAvailability.service_version_update_required;
      case 'service_disabled':
        return GooglePlayServicesAvailability.service_disabled;
      case 'service_invalid':
        return GooglePlayServicesAvailability.service_invalid;
    }

    return null;
  }

  /// Request the Safety Net Attestation with a String nonce
  /// The response is formatted as a JSON Web Signature (JWS)
  static Future<String> safetyNetAttestationJwt(String nonce) async {
    final String result = await _channel.invokeMethod(
        'requestSafetyNetAttestation',
        {"nonce_string": nonce, "include_payload": false});
    return result;
  }

  /// Request the Safety Net Attestation with a list of bytes
  /// The response is formatted as a JSON Web Signature (JWS)
  static Future<String> safetyNetAttestationWithFormattedNonceJwt(
      Uint8List nonce) async {
    final String result = await _channel.invokeMethod(
        'requestSafetyNetAttestation',
        {"nonce_bytes": nonce, "include_payload": false});
    return result;
  }

  /// Request the Safety Net Attestation with a String nonce
  /// The response is the payload from the JSON Web Signature (JWS)
  static Future<JWSPayload> safetyNetAttestationPayload(String nonce) async {
    final String payload = await _channel.invokeMethod(
        'requestSafetyNetAttestation',
        {"nonce_string": nonce, "include_payload": true});

    return JWSPayload.fromJSON(jsonDecode(payload));
  }

  /// Request the Safety Net Attestation with a list of bytes
  /// The response is the payload from the JSON Web Signature (JWS)
  static Future<JWSPayload> safetyNetAttestationWithFormattedNoncePayload(
      Uint8List nonce) async {
    final String payload = await _channel.invokeMethod(
        'requestSafetyNetAttestation',
        {"nonce_bytes": nonce, "include_payload": true});

    return JWSPayload.fromJSON(jsonDecode(payload));
  }
}

enum GooglePlayServicesAvailability {
  success,
  service_missing,
  service_updating,
  service_version_update_required,
  service_disabled,
  service_invalid
}

class JWSPayload {
  final String nonce;
  final int timestampMs;
  final String apkPackageName;
  final List<dynamic> apkCertificateDigestSha256;
  final String apkDigestSha256;
  final bool ctsProfileMatch;
  final bool basicIntegrity;

  JWSPayload.fromJSON(Map<String, dynamic> json)
      : nonce = json["nonce"],
        timestampMs = json["timestampMs"],
        apkPackageName = json["apkPackageName"],
        apkCertificateDigestSha256 =
            List.from(json["apkCertificateDigestSha256"]),
        apkDigestSha256 = json["apkDigestSha256"],
        ctsProfileMatch = json["ctsProfileMatch"],
        basicIntegrity = json["basicIntegrity"];

  @override
  String toString() {
    return 'nonce: $nonce\n'
        'timestampMs: $timestampMs\n'
        'apkPackageName: $apkPackageName\n'
        'apkCertificateDigestSha256: $apkCertificateDigestSha256\n'
        'apkDigestSha256: $apkDigestSha256\n'
        'ctsProfileMatch: $ctsProfileMatch\n'
        'basicIntegrity: $basicIntegrity';
  }

  String toJSON() {
    return jsonEncode({
      'nonce': nonce,
      'timestampMs': timestampMs,
      'apkPackageName': apkPackageName,
      'apkCertificateDigestSha256': apkCertificateDigestSha256,
      'apkDigestSha256': apkDigestSha256,
      'ctsProfileMatch': ctsProfileMatch,
      'basicIntegrity': basicIntegrity
    });
  }
}
