package com.artifex.mupdf.fitz;

import android.util.Log;
import com.artifex.mupdf.fitz.Context;



public class Document
{
    public static String TAG = Document.class.getSimpleName();
    static {
        Context.init();
    }

    public static final String META_FORMAT = "format";
    public static final String META_ENCRYPTION = "encryption";
    public static final String META_INFO_AUTHOR = "info:Author";
    public static final String META_INFO_TITLE = "info:Title";

    protected long pointer;
    protected String path; /* for proofing */
    private boolean isSVG = false;

    protected native void finalize();

    public void destroy() {
        finalize();
        pointer = 0;
    }

    protected Document(long p) {
        pointer = p;
    }

    protected Document() {

    }

    public native static int setPNGPathFullForExport(String path, int pageNumber, int x, int y, int w, int h);
    public native static boolean getPDFforExportIsUnencryptedPDF();
    public native static boolean getPDFforExportNeedsPassword();
    private native static int closePDFforExportWithSave(String file);
    private native static int closePDFforExport();
    private native static int getPDFforExportTotalPages();
    private native static String getDimension(int pageNumber);
    private native static String getPDFforExportSVG(int pageNumber, String outFilePath, int resolution);
    private native static boolean getPDFforExportPNG(int pageNumber, String outFilePath, int resolution);
    protected native static int openPDFforExport(String filename, String password, int resolution, int timeout);
    protected native static Document openNativeWithPath(String filename);
    protected native static Document openNativeWithBuffer(byte buffer[], String magic);

    public static Document openDocument(String filename) {
        Document doc = openNativeWithPath(filename);
        doc.path = filename;
        return doc;
    }

    public static Document openDocumentForExport(String filename, String password, int resolution, int timeout) {

        int result = openPDFforExport(filename, password, resolution, timeout);
        if(result == 0){
            Document doc = new Document();
            doc.path = filename;
            doc.isSVG = true;
            return doc;
        }
        return null;
    }

    public int closeDocumentForExport(String file){
        if(this.isSVG) {
            isSVG = false;
            if(file.isEmpty()){
                return closePDFforExport();
            }else{
                return closePDFforExportWithSave(file);
            }
        }
        return 1;
    }

    public String getDocumentForSVG(int pageNumber, String outFilePath, int resolution){
        if(this.isSVG) {
            return getPDFforExportSVG(pageNumber, outFilePath, resolution);
        }
        return  "";
    }

    public String getDocumentDimension(int pageNumber){
        if(this.isSVG) {
            return getDimension(pageNumber);
        }
        return  "";
    }

    public boolean getDocumentForPNG(int pageNumber, String outFilePath, int resolution){
        if(this.isSVG) {
            return getPDFforExportPNG(pageNumber, outFilePath, resolution);
        }
        return  false;
    }

    public int getDocumentForExportTotalPages(){
        if(this.isSVG) {
            return getPDFforExportTotalPages();
        }
        return 0;
    }

    public static Document openDocument(byte buffer[], String magic) {
        return openNativeWithBuffer(buffer, magic);
    }

    public static native boolean recognize(String magic);

    public native boolean needsPassword();
    public native boolean authenticatePassword(String password);

    public native int countPages();
    public native Page loadPage(int number);
    public native Outline[] loadOutline();
    public native String getMetaData(String key);
    public native boolean isReflowable();
    public native void layout(float width, float height, float em);

    public native long makeBookmark(int page);
    public native int findBookmark(long mark);

    public native boolean isUnencryptedPDF();

    public native PDFDocument toPDFDocument();

    public boolean isPDF() {
        return false;
    }

    public String getPath() { return path; }
    protected native String proofNative (String currentPath, String printProfile, String displayProfile, int resolution);
    public String makeProof (String currentPath, String printProfile, String displayProfile, int resolution) {
        String proofFile = proofNative( currentPath,  printProfile,  displayProfile,  resolution);
        return proofFile;
    }

}
