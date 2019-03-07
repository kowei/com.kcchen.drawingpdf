package com.kcchen.drawingpdf;

import android.Manifest;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;

import com.artifex.mupdf.fitz.Document;
import com.artifex.mupdf.fitz.PDFDocument;
import com.artifex.mupdf.fitz.Page;
import com.artifex.mupdf.fitz.Rect;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

// import java.io.File;

/**
 * DrawingPDF is a PhoneGap plugin that bridges Android intents and web
 * applications:
 * <p>
 * 1. web apps can spawn intents that call native Android applications. 2.
 * (after setting up correct intent filters for PhoneGap applications), Android
 * intents can be handled by PhoneGap web applications.
 *
 * @author boris@borismus.com
 */
public class DrawingPDF extends CordovaPlugin {
    private static final String TAG = DrawingPDF.class.getSimpleName();
    private static final int READ_EXTERNAL_REQUEST_CODE = 0;
    private static final int WRITE_EXTERNAL_REQUEST_CODE = 1;
    private static final int PERMISSION_DENIED_ERROR = 20;


    private CallbackContext openCallbackContext = null;
    private CallbackContext closeCallbackContext = null;
    private Uri pdfUri;
    private PDFDocument pdfDoc;
    private Document doc;
    private Document svgDoc;
    private String closeFilepath;


    /**
     * @param action          The action to execute.
     * @param args            The exec() arguments.
     * @param callbackContext The callback context used when calling back into JavaScript.
     * @return true: comsume  false: reject if using Promise
     */
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        try {
            Log.w(TAG, "execute " + "action:" + action + " args:" + args + " callbackContext:" + callbackContext);
//             openPDF: (url: string) => Promise<OpenPDFInfo>;
//             insertBase64Image: (imageBase64Url: string) => Promise<any>;
//             insertBase64SVG: (svgBase64Url: string) => Promise<any>;
//             insertImagePath: (path: string, pageIdx: number, x: number, y: number, w?: number, h?: number) => Promise<any>;
//             insertSVGPath: (path: string, pageIdx: number, x: number, y: number, w?: number, h?: number) => Promise<any>;
//             getTotalPages: () => Promise<any>;
//             closePDF: () => Promise<any>;
            if (action.equals("openPDF")) {
                String pdfPath = args.getString(0);
                if (pdfPath == null) {
                    callbackContext.error("missing pdf file.");
                    return true;
                }

                pdfUri = Uri.parse(pdfPath);
                if(pdfUri == null){
                    pdfUri = Uri.parse(EscapeUtils.encodeURIComponent(pdfPath));
                }

                if (!PermissionHelper.hasPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    openCallbackContext = callbackContext;
                    PermissionHelper.requestPermission(this, READ_EXTERNAL_REQUEST_CODE, Manifest.permission.READ_EXTERNAL_STORAGE);
                } else {
                    openPDF(callbackContext);
                }
                return true;
            } else if (action.equals("insertBase64Image")) {

                return true;
            } else if (action.equals("insertBase64SVG")) {

                return true;
            } else if (action.equals("insertImagePath")) {
                String imgFile = args.getString(0);
                int pageIdx = args.getInt(1);
                int x = args.getInt(2);
                int y = args.getInt(3);
                int w = args.getInt(4);
                int h = args.getInt(5);
                insertImagePath(callbackContext, imgFile, pageIdx, x, y, w, h);
                return true;
            } else if (action.equals("insertSVGPath")) {

                return true;
            } else if (action.equals("openPDFforExport")) {

                String filepath = (args.getString(0) == null) ? "" : args.getString(0);
                String password = (args.getString(1) == null) ? "" : args.getString(1);
                int resolution = args.getInt(2);
                int timeout = args.getInt(3);
                timeout = timeout == 9999 ? -1 : timeout;

                if (filepath.isEmpty()) {
                    callbackContext.error("> openPDFforExport missing pdf file.");
                    return true;
                }


                if (!PermissionHelper.hasPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    openCallbackContext = callbackContext;
                    PermissionHelper.requestPermission(this, READ_EXTERNAL_REQUEST_CODE, Manifest.permission.READ_EXTERNAL_STORAGE);
                } else {
                    openPDFforExport(callbackContext, filepath, password, resolution, timeout);
                }

                return true;

            } else if (action.equals("getPDFforExportDimension")) {
                int pageNumber = args.getInt(0);


                getDimension(callbackContext, pageNumber);
                return true;

            } else if (action.equals("getPDFforExportSVG")) {
                int pageNumber = args.getInt(0);
                String filepath = (args.getString(1) == null) ? "" : args.getString(1);
                int resolution = args.getInt(2);


                getPDFforExportSVG(callbackContext, pageNumber, filepath, resolution);
                return true;

            } else if (action.equals("getPDFforExportPNG")) {
                int pageNumber = args.getInt(0);
                String filepath = (args.getString(1) == null) ? "" : args.getString(1);
                int resolution = args.getInt(2);


                getPDFforExportPNG(callbackContext, pageNumber, filepath, resolution);
                return true;

            } else if (action.equals("setPNGPathFullForExport")) {
                String imgFile = args.getString(0);
                int pageIdx = args.getInt(1);
                int x = args.getInt(2);
                int y = args.getInt(3);
                int w = args.getInt(4);
                int h = args.getInt(5);
                setPNGPathFullForExport(callbackContext, imgFile, pageIdx, x, y, w, h);
                return true;
            } else if (action.equals("getPDFforExportTotalPages")) {

                getPDFforExportTotalPages(callbackContext);
                return true;

            } else if (action.equals("closePDFforExport")) {
                closeFilepath = (args.getString(0) == null) ? "" : args.getString(0);

                if (!PermissionHelper.hasPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    closeCallbackContext = callbackContext;
                    PermissionHelper.requestPermission(this, WRITE_EXTERNAL_REQUEST_CODE, Manifest.permission.WRITE_EXTERNAL_STORAGE);
                } else {
                    closePDFforExport(callbackContext);
                }
                return true;

            } else if (action.equals("getTotalPages")) {
                getTotalPages(callbackContext);
                return true;

            } else if (action.equals("closePDF")) {
                closeFilepath = (args.getString(0) == null) ? "" : args.getString(0);

                if (!PermissionHelper.hasPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    closeCallbackContext = callbackContext;
                    PermissionHelper.requestPermission(this, WRITE_EXTERNAL_REQUEST_CODE, Manifest.permission.WRITE_EXTERNAL_STORAGE);
                } else {
                    closePDF(callbackContext);
                }
                return true;
            }
            //return new PluginResult(PluginResult.Status.INVALID_ACTION);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.INVALID_ACTION));
            return false;
        } catch (JSONException e) {
            e.printStackTrace();
            String errorMessage = e.getMessage();
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION, errorMessage));
            return false;
        }
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                if (openCallbackContext != null) {
                    openCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
                    openCallbackContext = null;
                } else if (closeCallbackContext != null) {
                    closeCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
                    closeCallbackContext = null;
                }
                return;
            }
        }

        switch (requestCode) {
            case READ_EXTERNAL_REQUEST_CODE:
                openPDF(openCallbackContext);
                break;
            case WRITE_EXTERNAL_REQUEST_CODE:
                closePDF(closeCallbackContext);
                break;
        }
    }


    private void openPDFforExport(final CallbackContext callbackContext, final String filepath, final String password, final int resolution, final int timeout) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                PluginResult pluginResult = null;
                String file = ((filepath == null) ? "" : filepath);
                String svg = null;
                Uri importFile;
                String error = null;

                if (file.isEmpty()) {
                    svgDoc = null;
                    error = "openPDFforExport no input path !!!";
                } else {
                    importFile = Uri.parse(file);
                    Log.d(TAG, "path:" + importFile.getPath());
                    File importedFile = new File(importFile.getPath());

                    if (importedFile.exists() && importedFile.length() != 0 && importedFile.canRead()) {
                        svgDoc = Document.openDocumentForExport(importedFile.getPath(), password, resolution, timeout);
                    } else {
                        svgDoc = null;
                        error = "openPDFforExport input file invalid !!!";
                    }
                }

                if (svgDoc != null) {
                    try {
                        JSONObject info = new JSONObject();

                        info.put("isUnencryptedPDF", svgDoc.getPDFforExportIsUnencryptedPDF());
                        info.put("needsPassword", svgDoc.getPDFforExportNeedsPassword());
                        info.put("countPages", svgDoc.getDocumentForExportTotalPages());

                        Log.e(TAG, "pdfInfo:" + info.toString());
                        String encoded = EscapeUtils.encodeURIComponent(info.toString());
                        pluginResult = new PluginResult(PluginResult.Status.OK, encoded);
                    } catch (Exception e) {
                        pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                    }
                } else {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, error);
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "openPDFforExport error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }


    private void getDimension(final CallbackContext callbackContext, final int pageNumber) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                PluginResult pluginResult = null;
                String dimString = null;

                if (svgDoc != null) {

                    dimString = svgDoc.getDocumentDimension(pageNumber);

                    if (dimString != null && !dimString.isEmpty()) {
                        JSONArray dim = null;
                        try {
                            dim = new JSONArray(dimString);
                            String encoded = EscapeUtils.encodeURIComponent(dim.toString());
                            pluginResult = new PluginResult(PluginResult.Status.OK, encoded);
                        } catch (Exception e) {
                            e.printStackTrace();
                            pluginResult = new PluginResult(PluginResult.Status.OK, dimString);
                        }

                    }

                } else {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getDimension document invalid!!!");
                }


                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getDimension error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }


    private void getTotalPages(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PluginResult pluginResult = null;
                if (doc == null) {
                    callbackContext.error("need open a pdf file");
                    return;
                }

                int pages = doc.countPages();

                pluginResult = new PluginResult(PluginResult.Status.OK, pages);

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getTotalPages error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    private void getPDFforExportSVG(final CallbackContext callbackContext, final int pageNumber, final String filepath, final int resolution) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                PluginResult pluginResult = null;
                String file = ((filepath == null) ? "" : filepath);
                String svg = null;
                Uri exportFile;

                if (svgDoc != null) {

                    if (file.isEmpty()) {
                        svg = svgDoc.getDocumentForSVG(pageNumber, file, resolution);
                        if (svg == null || svg.isEmpty()) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG: no svg got!!!");
                        } else {

                            Log.e(TAG, "> getPDFforExportSVG svg:\n" + ((svg != null && svg.length() > 250) ? svg.substring(0, 250) : svg));
                            try {
                                String encoded = EscapeUtils.encodeURIComponent(svg);
                                Log.e(TAG, "> getPDFforExportSVG string:" + svg.length());
                                Log.e(TAG, "> getPDFforExportSVG encoded:" + encoded.length());
                                pluginResult = new PluginResult(PluginResult.Status.OK, encoded);
                            } catch (Exception e) {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG: svg url encode error!!!");
                                e.printStackTrace();
                            }
                        }
                    } else {
                        exportFile = Uri.parse(file);
                        File exportedFile = new File(exportFile.getPath());

                        try {
                            if (!exportedFile.exists()) exportedFile.createNewFile();
                            if (exportedFile.canWrite()) {
                                svgDoc.getDocumentForSVG(pageNumber, exportFile.getPath(), resolution);

                                if (exportedFile.exists() && exportedFile.length() != 0) {
                                    Log.e(TAG, "> SVG length:" + exportedFile.length());
                                    pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                                } else {
                                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG: no svg gexported!!!");
                                }
                            } else {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG: file location can not write!!!");
                            }
                        } catch (IOException e) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG: file location can not write!!!");
                            e.printStackTrace();
                        }
                    }
                }else{
                    Log.e(TAG, "> svgDoc missing!!");
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportSVG error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    private void getPDFforExportPNG(final CallbackContext callbackContext, final int pageNumber, final String filepath, final int resolution) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                PluginResult pluginResult = null;
                String file = ((filepath == null) ? "" : filepath);
                Uri exportFile;

                if (svgDoc != null) {

                    if (file.isEmpty()) {
                        pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportPNG no output path !!!");
                    } else {

                        exportFile = Uri.parse(file);
                        File exportedFile = new File(exportFile.getPath());
                        try {
                            if (!exportedFile.exists()) exportedFile.createNewFile();
                            if (exportedFile.canWrite()) {
                                svgDoc.getDocumentForPNG(pageNumber, exportFile.getPath(), resolution);

                                if (exportedFile.exists() && exportedFile.length() != 0) {
                                    Log.e(TAG, "> PNG length:" + exportedFile.length());
                                    pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                                } else {
                                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportPNG: no png gexported!!!");
                                }
                            } else {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportPNG: file location can not write!!!");
                            }
                        } catch (IOException e) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportPNG: file location can not write!!!");
                            e.printStackTrace();
                        }
                    }
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportPNG error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }


    private void getPDFforExportTotalPages(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PluginResult pluginResult;
                int pages = 0;
                if (svgDoc != null) {
                    pages = svgDoc.getDocumentForExportTotalPages();

                    pluginResult = new PluginResult(PluginResult.Status.OK, pages);

                } else {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "PDF not opened!!!");
                }


                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "getPDFforExportTotalPages error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    private void closePDFforExport(final CallbackContext callbackContext) {

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                PluginResult pluginResult = null;
                String file = ((closeFilepath == null) ? "" : closeFilepath);
                Uri exportFile = null;
                File exportedFile = null;
                int result = -1;

                if (svgDoc != null) {


                    if (!file.isEmpty()) {

                        exportFile = Uri.parse(file);
                        exportedFile = new File(exportFile.getPath());

                        try {
                            if (!exportedFile.exists()) exportedFile.createNewFile();
                            if (exportedFile.canWrite()) {

                            } else {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport: file location can not write!!!");
                            }
                        } catch (IOException e) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport: file location can not write!!!");
                            e.printStackTrace();
                        }

                    }

                    if(exportFile != null){
                        Log.e(TAG, "> closePDFforExport to "+exportFile.getPath());
                        result = svgDoc.closeDocumentForExport(exportFile.getPath());
                        Log.e(TAG, "> closePDFforExport");
                    }else{
                        result = svgDoc.closeDocumentForExport("");
                    }

                    if (result == 0) {
                        if (!file.isEmpty() && exportFile != null && exportedFile != null) {

                            try {

                                if (exportedFile.exists() && exportedFile.length() != 0) {
                                    Log.e(TAG, "> PDF length:" + exportedFile.length());
                                    pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                                } else {
                                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport: no pdf gexported!!!");
                                }

                            } catch (Exception e) {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport: file location can not write!!!");
                                e.printStackTrace();
                            }
                        }else{
                            pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                        }
                        svgDoc = null;
                    } else {
                        pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport: PDF write error!!!");
                    }

                }else{
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport svgDoc error!!!");
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDFforExport error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });

    }

    public void openPDF(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PluginResult pluginResult;
                if(pdfUri != null){
                    if (doc != null) {
                        doc.destroy();
                        doc = null;
                    }
                    doc = Document.openDocument(pdfUri.getPath());

                    if (doc == null) {
                        callbackContext.error("Can not open pdf: " + pdfUri.getPath());
                        return;
                    }

                    JSONObject pdfInfo = new JSONObject();
                    try {
                        pdfInfo.put("isUnencryptedPDF", doc.isUnencryptedPDF());
                        pdfInfo.put("needsPassword", doc.needsPassword());
                        pdfInfo.put("countPages", doc.countPages());
                    } catch (JSONException e) {
                        callbackContext.error("JSON Exception: " + e.getMessage());
                        return;
                    }

                    String encoded = EscapeUtils.encodeURIComponent(pdfInfo.toString());

                    pluginResult = new PluginResult(PluginResult.Status.OK, encoded);
                }else{
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "openPDF path error!!!");
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "openPDF error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    private void setPNGPathFullForExport(final CallbackContext callbackContext, final String imgFile, final int pageNumber, final int x, final int y, final int w, final int h) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PluginResult pluginResult = null;

                String file = ((imgFile == null) ? "" : imgFile);
                Uri importFile;

                if (svgDoc != null) {

                    if (file.isEmpty()) {
                        pluginResult = new PluginResult(PluginResult.Status.ERROR, "setPNGPathFullForExport no output path !!!");
                    } else {

                        importFile = Uri.parse(file);
                        File importedFile = new File(importFile.getPath());
                        try {
                            if (importedFile.exists() && importedFile.canRead()) {

                                int result = svgDoc.setPNGPathFullForExport(importFile.getPath(), pageNumber, x, y, w, h);

                                if (result == 0) {
                                    pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                                } else {
                                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "setPNGPathFullForExport: write png error!!!");
                                }
                            } else {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "setPNGPathFullForExport: file location can not read or not existed!!!");
                            }
                        } catch (Exception e) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "setPNGPathFullForExport: file location can not write!!!");
                            e.printStackTrace();
                        }
                    }
                }


                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "setPNGPathFullForExport error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    public void insertImagePath(final CallbackContext callbackContext, final String imgFile, final int pageIdx, final int x, final int y, final int w, final int h) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                if (imgFile == null) {
                    callbackContext.error("missing img file.");
                    return;
                }

                if (doc == null) {
                    callbackContext.error("need open a pdf file");
                    return;
                }

                Uri imgUri = Uri.parse(imgFile);
                Log.d(TAG, "insertImage: " + imgUri.getPath());

                Page mPage = doc.loadPage(pageIdx);
                Rect rect = mPage.getBounds();
                Log.d(TAG, "pageIdx: " + pageIdx + ", pageRect: " + rect.toString());

                int width = w;
                int height = h;
                if (width == 0 || height == 0) {
                    width = (int) (rect.x1 - rect.x0); // fit pdf page
                    height = (int) (rect.y1 - rect.y0);
                }
                int left = x;
                int top = (int) (rect.y1 - rect.y0) - height - y;

                pdfDoc = doc.toPDFDocument();
                pdfDoc.insertImage(imgUri.getPath(), pageIdx, left, top, width, height);
                pdfDoc.destroy();
                pdfDoc = null;
                mPage.destroy();
                mPage = null;

                callbackContext.success();
            }
        });
    }

    public void closePDF(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PluginResult pluginResult = null;
                String file = ((closeFilepath == null) ? "" : closeFilepath);
                Uri exportFile;

                if (doc != null) {

                    if (file.isEmpty()) {
                        pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDF no output path !!!");
                    } else {

                        exportFile = Uri.parse(file);
                        File exportedFile = new File(exportFile.getPath());
                        try {
                            if (!exportedFile.exists()) exportedFile.createNewFile();
                            if (exportedFile.canWrite()) {
                                doc.toPDFDocument().save(exportFile.getPath(), "decompress=no,compress-images=yes");

                                Log.d(TAG, "closePDF: " + pdfUri.getPath());
                                Log.d(TAG, "saveTo: " + exportFile.getPath());

                                if (pdfDoc != null) pdfDoc.destroy();
                                if (doc != null) doc.destroy();
                                pdfDoc = null;
                                doc = null;
                                pdfUri = null;

                                if (exportedFile.exists() && exportedFile.length() != 0) {
                                    Log.e(TAG, "> PDF length:" + exportedFile.length());
                                    pluginResult = new PluginResult(PluginResult.Status.OK, "SUCCESS");
                                } else {
                                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDF: no pdf gexported!!!");
                                }
                            } else {
                                pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDF: file location can not write!!!");
                            }
                        } catch (IOException e) {
                            pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDF: file location can not write!!!");
                            e.printStackTrace();
                        }
                    }
                }

                if (pluginResult == null) {
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, "closePDF error!!!");
                }
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);

            }
        });
    }
}
