#import "FlutterSafetynetAttestationPlugin.h"

@implementation FlutterSafetynetAttestationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"g123k/flutter_safetynet_attestation"
            binaryMessenger:[registrar messenger]];
  FlutterSafetynetAttestationPlugin* instance = [[FlutterSafetynetAttestationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}

@end
