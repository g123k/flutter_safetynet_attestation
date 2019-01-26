package fr.g123k.fluttersafetynetattestation;

import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.text.TextUtils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.safetynet.SafetyNet;
import com.google.android.gms.safetynet.SafetyNetApi;
import com.google.android.gms.safetynet.SafetyNetClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.nimbusds.jose.JWSObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.security.SecureRandom;
import java.text.ParseException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterSafetynetAttestationPlugin implements MethodCallHandler {

    private final Activity activity;
    private final String ANDROID_MANIFEST_METADATA_SAFETY_API_KEY = "safetynet_api_key";

    private FlutterSafetynetAttestationPlugin(Activity context) {
        this.activity = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "g123k/flutter_safetynet_attestation");
        channel.setMethodCallHandler(new FlutterSafetynetAttestationPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "checkGooglePlayServicesAvailability":
                checkGooglePlayServicesAvailability(result);
                break;
            case "requestSafetyNetAttestation":
                requestSafetyNetAttestation(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void requestSafetyNetAttestation(final MethodCall call, final Result result) {
        if (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity)
                != ConnectionResult.SUCCESS) {
            result.error("Error", "Google Play Services are not available, please call the checkGooglePlayServicesAvailability() method to understand why", null);
            return;
        } else if (!checkApiKeyInManifest()) {
            result.error("Error", "The SafetyNet API Key is missing in the manifest", null);
            return;
        } else if (!call.hasArgument("nonce_bytes") && !call.hasArgument("nonce_string")) {
            result.error("Error", "Please include the nonce in the request", null);
            return;
        }

        // Check nonce
        byte[] nonce = getNonceFrom(call);
        if (nonce == null || nonce.length < 16) {
            result.error("Error", "The nonce should be larger than the 16 bytes", null);
            return;
        }

        SafetyNetClient client = SafetyNet.getClient(activity);
        Task<SafetyNetApi.AttestationResponse> task = client.attest(nonce, getSafetyNetApiKey());

        task.addOnSuccessListener(activity, new OnSuccessListener<SafetyNetApi.AttestationResponse>() {
            @Override
            public void onSuccess(SafetyNetApi.AttestationResponse attestationResponse) {
                if (call.hasArgument("include_payload") && call.argument("include_payload").equals(true)) {
                    try {
                        final JWSObject jwsObject = JWSObject.parse(attestationResponse.getJwsResult());
                        result.success(jwsObject.getPayload().toString());
                    } catch (ParseException e) {
                        e.printStackTrace();
                        result.error("Error", e.getMessage(), null);
                    }

                } else {
                    result.success(attestationResponse.getJwsResult());
                }
            }
        }).addOnFailureListener(activity, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                e.printStackTrace();

                if (e instanceof ApiException) {
                    ApiException apiException = (ApiException) e;
                    result.error("Error",
                            CommonStatusCodes.getStatusCodeString(apiException.getStatusCode()) + " : " +
                            apiException.getMessage(), null);
                } else {
                    result.error("Error", e.getMessage(), null);
                }
            }
        });
    }

    private byte[] getNonceFrom(MethodCall call) {
        if (call.hasArgument("nonce_bytes")) {
            return call.argument("nonce_bytes");
        } else if (call.hasArgument("nonce_string")) {
            return getRequestNonce((String) call.argument("nonce_string"));
        } else {
            return null;
        }
    }

    private byte[] getRequestNonce(String data) {
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
        byte[] bytes = new byte[24];
        new SecureRandom().nextBytes(bytes);
        try {
            byteStream.write(bytes);
            byteStream.write(data.getBytes());
        } catch (IOException e) {
            return null;
        }

        return byteStream.toByteArray();
    }

    private boolean checkApiKeyInManifest() {
        return !TextUtils.isEmpty(getSafetyNetApiKey());
    }

    @Nullable
    private String getSafetyNetApiKey() {
        return Utils.getMetadataFromManifest(activity, ANDROID_MANIFEST_METADATA_SAFETY_API_KEY);
    }

    private void checkGooglePlayServicesAvailability(Result result) {
        switch (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity)) {
            case ConnectionResult.SUCCESS:
                result.success("success");
                break;
            case ConnectionResult.SERVICE_MISSING:
                result.success("service_missing");
                break;
            case ConnectionResult.SERVICE_UPDATING:
                result.success("service_updating");
                break;
            case ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED:
                result.success("service_version_update_required");
                break;
            case ConnectionResult.SERVICE_DISABLED:
                result.success("service_disabled");
                break;
            case ConnectionResult.SERVICE_INVALID:
                result.success("service_invalid");
                break;
            default:
                result.error("Error", "Unknown error code", null);
        }
    }
}
