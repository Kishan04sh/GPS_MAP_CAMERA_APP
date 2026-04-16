//
//package com.gps.gps_map_camera;
//
//import android.app.DownloadManager;
//import android.content.Context;
//import android.net.Uri;
//import android.os.Environment;
//
//import androidx.annotation.NonNull;
//
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugin.common.MethodChannel;
//
//public class MainActivity extends FlutterActivity {
//
//    private static final String CHANNEL = "safe_downloader";
//
//    @Override
//    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//
//        new MethodChannel(
//                flutterEngine.getDartExecutor().getBinaryMessenger(),
//                CHANNEL
//        ).setMethodCallHandler((call, result) -> {
//
//            if (call.method.equals("download")) {
//                String url = call.argument("url");
//                String fileName = call.argument("fileName");
//
//                startDownload(url, fileName);
//                result.success(true);
//            } else {
//                result.notImplemented();
//            }
//        });
//    }
//
//    private void startDownload(String url, String fileName) {
//        DownloadManager.Request request =
//                new DownloadManager.Request(Uri.parse(url));
//
//        request.setTitle(fileName);
//        request.setDescription("Downloading media");
//        request.setNotificationVisibility(
//                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
//        );
//
//        request.setAllowedOverMetered(true);
//        request.setAllowedOverRoaming(true);
//
//        request.setDestinationInExternalPublicDir(
//                Environment.DIRECTORY_DOWNLOADS,
//                fileName
//        );
//
//        DownloadManager manager = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
//        manager.enqueue(request);
//    }
//}


package com.gps.gps_map_camera;

import android.app.DownloadManager;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "safe_downloader";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            switch (call.method) {

                case "download": {
                    String url = call.argument("url");
                    String fileName = call.argument("fileName");
                    startDownload(url, fileName);
                    result.success(true);
                    break;
                }

                case "saveLocal": {
                    String path = call.argument("path");
                    String type = call.argument("type"); // image | video
                    boolean success = saveLocalFile(path, type);
                    result.success(success);
                    break;
                }

                default:
                    result.notImplemented();
            }
        });
    }

    /// ==========================================================
    /// URL DOWNLOAD (UNCHANGED – WORKING)
    /// ==========================================================
//    private void startDownload(String url, String fileName) {
//        DownloadManager.Request request =
//                new DownloadManager.Request(Uri.parse(url));
//
//        request.setTitle(fileName);
//        request.setDescription("Downloading media");
//        request.setNotificationVisibility(
//                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
//        );
//
//        request.setAllowedOverMetered(true);
//        request.setAllowedOverRoaming(true);
//
//        request.setDestinationInExternalPublicDir(
//                Environment.DIRECTORY_DOWNLOADS,
//                fileName
//        );
//
//        DownloadManager manager =
//                (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
//        manager.enqueue(request);
//    }

    private void startDownload(String url, String fileName) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // ✅ Android 10+ (No permission needed)

            DownloadManager.Request request =
                    new DownloadManager.Request(Uri.parse(url));

            request.setTitle(fileName);
            request.setDescription("Downloading media");
            request.setNotificationVisibility(
                    DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
            );

            request.setAllowedOverMetered(true);
            request.setAllowedOverRoaming(true);

            request.setDestinationInExternalPublicDir(
                    Environment.DIRECTORY_DOWNLOADS,
                    fileName
            );

            DownloadManager manager =
                    (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
            manager.enqueue(request);

        } else {
            // ⚠️ Android 9 & below → Permission required

            if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != android.content.pm.PackageManager.PERMISSION_GRANTED) {

                requestPermissions(
                        new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE},
                        1001
                );
                return;
            }

            DownloadManager.Request request =
                    new DownloadManager.Request(Uri.parse(url));

            request.setTitle(fileName);
            request.setDescription("Downloading media");

            request.setDestinationInExternalPublicDir(
                    Environment.DIRECTORY_DOWNLOADS,
                    fileName
            );

            DownloadManager manager =
                    (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
            manager.enqueue(request);
        }
    }

    /// ==========================================================
    /// LOCAL FILE → GALLERY (IMAGE / VIDEO)
    /// ==========================================================
    private boolean saveLocalFile(String path, String type) {
        try {
            File file = new File(path);
            if (!file.exists()) return false;

            String fileName = file.getName();

            ContentValues values = new ContentValues();
            values.put(MediaStore.MediaColumns.DISPLAY_NAME, fileName);
            values.put(
                    MediaStore.MediaColumns.MIME_TYPE,
                    type.equals("video") ? "video/mp4" : "image/jpeg"
            );

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        type.equals("video")
                                ? Environment.DIRECTORY_MOVIES
                                : Environment.DIRECTORY_PICTURES
                );
            }

            Uri uri = getContentResolver().insert(
                    type.equals("video")
                            ? MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                            : MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    values
            );

            if (uri == null) return false;

            OutputStream out = getContentResolver().openOutputStream(uri);
            FileInputStream in = new FileInputStream(file);

            byte[] buffer = new byte[4096];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }

            in.close();
            out.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
