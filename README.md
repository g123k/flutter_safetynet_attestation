# Flutter SafetyNet Attestation plugin for Android

## What is SafetyNet?

>The SafetyNet Attestation API helps you assess the security and compatibility of the Android environments in which your apps run. You can use this API to analyze devices that have installed your app.'

Please check the [documentation here](https://developer.android.com/training/safetynet/attestation).

## Getting Started

### iOS

The plugin won't work iOS, because SafetyNet is only available for Android devices.

### Android

1. Open the [Google APIs console](https://console.developers.google.com/apis/library) and enable _Android Device Verification API_
2. Create your API key
3. In your Android project, please add the SafetyNet API key in your `AndroidManifest.xml`:


```xml
<meta-data android:name="safetynet_api_key"
            android:value="yourapikey"/>
```


### Dart

The _SafetyNet API_ is requiring a working version of the Google Play Services. A method is available to check if they are available on the device:

```dart
FlutterSafetynetAttestation.googlePlayServicesAvailability();
```

Then you have to pass a nonce (in a _String_ or a _byte array_) to the following method:

```dart
FlutterSafetynetAttestation.safetyNetAttestationJwt('<your-nonce>');
```

It will then return a JWT string. Google recommends to check this JWT on your server. Please read the [official documentation for more details](https://developer.android.com/training/safetynet/attestation#architecture).

If you want to get directly the payload from the JWT string, you can call instead:

```dart
FlutterSafetynetAttestation.safetyNetAttestationPayload('<your-nonce>');
```

You will then receive a _JWSPayload_ object with this kind of content:
```json
{
  "nonce": "R2Rra24fVm5xa2Mg",
  "timestampMs": 9860437986543,
  "apkPackageName": "com.package.name.of.requesting.app",
  "apkCertificateDigestSha256": ["base64 encoded, SHA-256 hash of the
                                  certificate used to sign requesting app"],
  "apkDigestSha256": ["base64 encoded, SHA-256 hash of
                      the APK installed on a user's device"],
  "ctsProfileMatch": true,
  "basicIntegrity": true,
}
```
