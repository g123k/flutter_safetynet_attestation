package fr.g123k.fluttersafetynetattestation;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class Utils {

    private Utils() {}

    @Nullable
    public static String getMetadataFromManifest(@NonNull Context context, @NonNull String key) {
        try {
            ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            return bundle.getString(key);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

}
