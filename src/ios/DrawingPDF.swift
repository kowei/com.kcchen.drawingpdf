import Foundation
import UIKit
import Social
import MobileCoreServices


@objc(DrawingPDF) class DrawingPDF : CDVPlugin {
    
    private static var ResourceCacheMaxSize = 128<<20
    private var callbackId:String = ""
    private var originFilePath:String = ""
    private var originImagesPath:JSON = JSON.null
    private var doc:    UnsafeMutablePointer<fz_document>? = nil
    private var pdfDoc: UnsafeMutablePointer<pdf_document>? = nil
    private var ctx:    UnsafeMutablePointer<fz_context>? = nil
    
    override func pluginInitialize() {
        
        print("pluginInitialize");
        
        
    }
    
    
    override func onAppTerminate() {
        
        print("onAppTerminate");
        
    }
    
    
    func openPDF(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            print("openPDF")
            let filePath:String! = command.argument(at: 0) as! String
            
            file = (filePath == nil) ? "" : filePath
            print("openPDF file:\(file)")
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "openPDF no input path !!!"
                )
            }else{
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    print("openPDF path:\(path)")
                    if(fm.fileExists(atPath: path) && fm.isReadableFile(atPath: path)){
                        
                        self.originFilePath = path
                        self.ctx = fz_new_context_imp(nil, nil, DrawingPDF.ResourceCacheMaxSize, FZ_VERSION)
                        fz_register_document_handlers(self.ctx)
                        
                        
                        if let doc = fz_open_document(self.ctx, self.originFilePath){
                            
                            self.doc = doc
                            
                            self.pdfDoc = pdf_document_from_fz_document(self.ctx, self.doc)
                            let iDoc = pdf_specifics(self.ctx, self.doc);
                            
                            let pdfInfo:JSON = [
                                "isUnencryptedPDF" : ((pdf_crypt_version(self.ctx, iDoc) == 1) ? true:false),
                                "needsPassword" : ((fz_needs_password(self.ctx, self.doc) == 1) ? true:false),
                                "countPages" : JSON(fz_count_pages(self.ctx, self.doc))
                            ]
                            
                            
                            print("pdfInfo:\(String(describing: pdfInfo.rawString()))")
                            
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: pdfInfo.rawString()?.urlEncode()
                            )
                            
                            
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "openPDF input file invalid !!!"
                            );
                        }
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "openPDF input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "openPDF input file invalid !!!"
                    );
                }
            }
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "openPDF error !!!"
                );
            }
            print("openPDF status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("openPDF message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
        })
    }
    
    func insertImagePath(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            var error:Int32
            
            //            print("> param path: \(command.argument(at: 0))")
            //            print("> param page index: \(command.argument(at: 1))")
            //            print("> param x: \(command.argument(at: 2))")
            //            print("> param y: \(command.argument(at: 3))")
            //            print("> param width: \(command.argument(at: 4))")
            //            print("> param height: \(command.argument(at: 5))")
            //            print("> PDF version: \(String(describing: self.pdfDoc?.pointee.version))")
            //            print("> PDF dirty: \(String(describing: self.pdfDoc?.pointee.dirty))")
            //            print("> PDF length: \(String(describing: self.pdfDoc?.pointee.file_length))")
            //            print("> PDF size: \(String(describing: self.pdfDoc?.pointee.file_size))")
            //            print("> PDF xref: \(String(describing: self.pdfDoc?.pointee.has_xref_streams))")
            //            print("> PDF page: \(String(describing: self.pdfDoc?.pointee.hint_page))")
            //            print("> PDF has permission: \(String(describing: self.pdfDoc?.pointee.super.has_permission))")
            //            print("> PDF pages: \(String(describing: self.pdfDoc?.pointee.super.count_pages))")
            //            print("> PDF refs: \(String(describing: self.pdfDoc?.pointee.super.refs))")
            //            print("> PDF page_count: \(String(describing: self.pdfDoc?.pointee.page_count))")
            
            
            let imagePath:String! = command.argument(at: 0) as! String
            let pageIndex:Int32 = command.argument(at: 1) as! Int32
            let x:Int32 = command.argument(at: 2) as! Int32
            let y:Int32 = command.argument(at: 3) as! Int32
            let width:Int32 = command.argument(at: 4) as! Int32
            let height:Int32 = command.argument(at: 5) as! Int32
            
            file = (imagePath == nil) ? "" : imagePath
            
            print("insertImagePath")
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "insertImagePath no input path !!!"
                )
            }else{
                
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    print("insertImagePath path:\(path)")
                    if(fm.fileExists(atPath: path) && fm.isReadableFile(atPath: path)){
                        
                        
                        if let pageRef = fz_load_page(self.ctx, self.doc, pageIndex){
                            var rect:fz_rect = fz_rect_s()
                            fz_bound_page(self.ctx, pageRef, &rect);
                            print("insertImagePath rect:\(rect)")
                            var w = width;
                            var h = height;
                            if (w == 0 || h == 0) {
                                w = Int32(rect.x1 - rect.x0); // fit pdf page
                                h = Int32(rect.y1 - rect.y0);
                            }
                            let left = x;
                            let top = Int32(rect.y1 - rect.y0) - h - y;
                            
                            error = pdf_add_imagefile(self.ctx, self.pdfDoc, path, pageIndex, left, top, w, h)
                            
                            fz_drop_page(self.ctx, pageRef)
                            
                            if(error == 0){
                                
                                pluginResult = CDVPluginResult(
                                    status: CDVCommandStatus_OK,
                                    messageAs: "SUCCESS"
                                )
                                
                                
                            }else{
                                pluginResult = CDVPluginResult(
                                    status: CDVCommandStatus_ERROR,
                                    messageAs: "insertImagePath input file invalid !!!"
                                );
                            }
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "insertImagePath page can not load !!!"
                            );
                        }
                        
                        
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "insertImagePath input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "insertImagePath input file invalid !!!"
                    );
                }
            }
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "insertImagePath error !!!"
                );
            }
            print("insertImagePath status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("insertImagePath message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
        })
    }
    
    func insertBase64Image(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "insertBase64Image"
            );
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            print("insertBase64Image");
        })
    }
    
    func insertBase64SVG(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            
            var pluginResult:CDVPluginResult? = nil
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "insertBase64SVG"
            );
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            print("insertBase64SVG");
        })
    }
    
    func insertSVGPath(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            
            var pluginResult:CDVPluginResult? = nil
            
            self.callbackId = command.callbackId
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "insertSVGPath"
            );
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            print("insertSVGPath");
        })
    }
    
    func getTotalPages(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            
            var pluginResult:CDVPluginResult? = nil
            
            print("getTotalPages");
            
            if(self.doc != nil && self.doc != nil){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: fz_count_pages(self.ctx, self.doc)
                );
                
            }else{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Document or Context is invalid!!!"
                );
            }
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        })
    }
    
    func openPDFforExport(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            var error:Int32
            
            let filePath:String! = command.argument(at: 0) as! String
            let password:String = command.argument(at: 1) as! String
            let resolution:Int32 = command.argument(at: 2) as! Int32
            let timeoutOption:Int32 = command.argument(at: 3) as! Int32
            let timeout:Int32 = (timeoutOption == 9999) ? -1 : timeoutOption
                        
            file = (filePath == nil) ? "" : filePath
            
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "openPDFforExport no input path !!!"
                )
            }else{
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    print("openPDFforExport path:\(path)")
                    
                    if(fm.fileExists(atPath: path) && fm.isReadableFile(atPath: path)){
                        
                        error = pdf_draw_open(path, password, resolution, timeout)
                        
                        if(error == 0){
                            
                            let pdfInfo:JSON = [
                                "isUnencryptedPDF" : ((pdf_info_is_unencrypted() == 1) ? true:false),
                                "needsPassword" : ((pdf_info_need_password() == 1) ? true:false),
                                "countPages" : JSON(pdf_draw_get_total_pages())
                            ]
                            
                            print("pdfInfo:\(String(describing: pdfInfo.rawString()))")
                            
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: pdfInfo.rawString()?.urlEncode()
                            )
                            
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "openPDFforExport input file invalid !!!"
                            );
                        }
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "openPDFforExport input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "openPDFforExport input file invalid !!!"
                    );
                }
            }
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "openPDFforExport error !!!"
                );
            }
            print("openPDFforExport status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("openPDFforExport message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            
        })
    }
    
    func getPDFforExportDimension(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            
            print("> param page: \(command.argument(at: 0))")
            
            let page:Int32 = command.argument(at: 0) as! Int32
            
            
            
            let result:UnsafeMutablePointer<Int8> = pdf_info_dimension(page)
            let length = pdf_info_dimention_length()
            
            if(length != 0){
                
                let content:String = String.stringFromInt(bytes: result, count: Int(length)).urlEncode()
                
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: content
                )
                
            }else{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "> can not get dimention for page \(page).]"
                );
            }
            
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            
        })
    }
    
    func getPDFforExportSVG(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            
            let pageNumber:Int32 = command.argument(at: 0) as! Int32
            let filePath:String! = command.argument(at: 1) as! String
            let resolution:Int32 = command.argument(at: 2) as! Int32
            
            file = (filePath == nil) ? "" : filePath
            var svg:UnsafeMutablePointer<Int8>! = nil
            var svgLength:Int32
            
            if(file.isEmpty){
                svg = pdf_draw_svg_get(pageNumber, file, resolution)
                svgLength = pdf_draw_svg_get_length()
                if(svgLength != 0){
                    
                    let content:String = String.stringFromInt(bytes: svg!, count: Int(svgLength)).urlEncode()
                    
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK,
                        messageAs: content
                    )
                    
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "getPDFforExportSVG: no svg got!!!"
                    );
                }
            }else{
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    
                    if(fm.fileExists(atPath: path) && fm.isDeletableFile(atPath: path)){
                        do{
                            try fm.removeItem(atPath: path)
                        }catch{
                            print("getPDFforExportSVG remove \(path) failed!")
                        }
                    }
                    
                    fm.createFile(atPath: path, contents: nil)
                    if(fm.isWritableFile(atPath: path)){
                        pdf_draw_svg_get(pageNumber, path, resolution)
                        if(fm.fileExists(atPath: path)){
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "SUCCESS"
                            );
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "getPDFforExportSVG: no svg gexported!!!"
                            );
                        }
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "getPDFforExportSVG: file location can not write!!!"
                        );
                    }
                    
                    
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "getPDFforExportSVG: file is invalid!!!"
                    );
                }
            }
            
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "getPDFforExportSVG error!!!"
                );
            }
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            
        })
    }
    //    var uri = new Uri (url);
    //    var nsurl = new NSUrl (uri.GetComponents (UriComponents.HttpRequestUrl, UriFormat.UriEscaped));
    //    UIApplication.SharedApplication.OpenUrl (nsurl);
    
    func getPDFforExportPNG(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            var error:Int32 = -1
            
            let pageNumber:Int32 = command.argument(at: 0) as! Int32
            let filePath:String! = command.argument(at: 1) as! String
            let resolution:Int32 = command.argument(at: 2) as! Int32
            
            file = (filePath == nil) ? "" : filePath
            
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "getPDFforExportPNG no output path !!!"
                );
            }else{
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    
                    if(fm.fileExists(atPath: path) && fm.isDeletableFile(atPath: path)){
                        do{
                            try fm.removeItem(atPath: path)
                        }catch{
                            print("getPDFforExportPNG remove \(path) failed!")
                        }
                    }
                    fm.createFile(atPath: path, contents: nil)
                    if(fm.isWritableFile(atPath: path)){
                        error = pdf_draw_png_get(pageNumber, path, resolution)
                        if(fm.fileExists(atPath: path)){
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "SUCCESS"
                            );
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "getPDFforExportPNG: no png gexported!!!"
                            );
                        }
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "getPDFforExportPNG: file location can not write!!!"
                        );
                    }
                    
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "getPDFforExportPNG: file is invalid!!!"
                    );
                }
            }
            
            
            if (pluginResult == nil || error != 0) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "getPDFforExportPNG error!!!"
                );
            }
            print("getPDFforExportPNG status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("getPDFforExportPNG message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            
        })
    }
    
    func setPNGPathFullForExport(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            var error:Int32
            
            
            let imagePath:String! = command.argument(at: 0) as! String
            let pageIndex:Int32 = command.argument(at: 1) as! Int32
            let x:Int32 = command.argument(at: 2) as! Int32
            let y:Int32 = command.argument(at: 3) as! Int32
            let width:Int32 = command.argument(at: 4) as! Int32
            let height:Int32 = command.argument(at: 5) as! Int32
            
            file = (imagePath == nil) ? "" : imagePath
            
            
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "setPNGPathFullForExport no input path !!!"
                )
            }else{
                
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    if(fm.fileExists(atPath: path) && fm.isReadableFile(atPath: path)){
                        
                        
                        print("setPNGPathFullForExport \(pageIndex) path:\(path)")
                        error = pdf_draw_png_add_full(path, pageIndex, x, y, width, height)
                        
                        
                        if(error == 0){
                            
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "SUCCESS"
                            )
                            
                            
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "setPNGPathFullForExport input file invalid !!!"
                            );
                        }
                        
                        
                        
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "setPNGPathFullForExport input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "setPNGPathFullForExport input file invalid !!!"
                    );
                }
            }
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "setPNGPathFullForExport error !!!"
                );
            }
            print("setPNGPathFullForExport status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("setPNGPathFullForExport message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
        })
    }
    
    func getPDFforExportTotalPages(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            
            
            let result = pdf_draw_get_total_pages()
            
            
            if(result != 0){
                
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "\(result)"
                )
                
            }else{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "> get total pages failed."
                );
            }
            
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "getPDFforExportTotalPages error!!!"
                );
            }
            print("getPDFforExportTotalPages status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("getPDFforExportTotalPages message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
        })
    }
    
    func closePDFforExport(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var exportFile:NSURL
            var result:Int32 = -1
            //var :String
            let fm = FileManager()
            
            let filePath:String! = command.argument(at: 0) as! String
            
            file = (filePath == nil) ? "" : filePath
            print("closePDFforExport file:\(file)")
            
            
            
            if(file.isEmpty){
                result = pdf_draw_close()
                
                if(result == 0){
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK,
                        messageAs: "SUCCESS"
                    )
                }
            }else{
                exportFile = NSURL(string: file.pathEncode())!
                
                if let path = exportFile.pathWithoutFileScheme(){
                    print("closePDFforExport path:\(path)")
                    fm.createFile(atPath: path, contents: nil)
                    if(fm.isWritableFile(atPath: path)){
                        do{
                            try fm.removeItem(atPath: path)
                        }catch{
                            print("closePDFforExport remove \(path) failed!")
                        }
                        result = pdf_draw_close_with_save(path);
                        
                        if(result == 0 && fm.fileExists(atPath: path)){
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "SUCCESS"
                            )
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "closePDFforExport input file not saved !!!"
                            );
                        }
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "closePDFforExport input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "closePDFforExport input file invalid !!!"
                    );
                }
            }

            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "closePDFforExport error !!!"
                );
            }
            print("closePDFforExport status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("closePDFforExport message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
            
        })
    }
    
    func closePDF(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            var pluginResult:CDVPluginResult? = nil
            var file:String
            var importFile:NSURL
            let fm = FileManager()
            
            let filePath:String! = command.argument(at: 0) as! String
            
            file = (filePath == nil) ? "" : filePath
            print("closePDF file:\(file)")
            
            if(file.isEmpty){
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "closePDF no input path !!!"
                )
            }else{
                importFile = NSURL(string: file.pathEncode())!
                
                if let path = importFile.pathWithoutFileScheme(){
                    print("closePDF path:\(path)")
                    fm.createFile(atPath: path, contents: nil)
                    if(fm.isWritableFile(atPath: path)){
                        
                        pdf_save_document(self.ctx, self.pdfDoc, path, nil);
                        fz_drop_document(self.ctx, self.doc)
                        fz_drop_context(self.ctx)
                        
                        if(fm.fileExists(atPath: path)){
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "SUCCESS"
                            )
                        }else{
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_ERROR,
                                messageAs: "closePDF input file not saved !!!"
                            );
                        }
                        
                        
                    }else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "closePDF input file not accessible !!!"
                        );
                    }
                }else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: "closePDF input file invalid !!!"
                    );
                }
            }
            
            if (pluginResult == nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "closePDF error !!!"
                );
            }
            print("closePDF status:\(pluginResult?.status == 1 ? "OK":"ERROR")")
            print("closePDF message:\(String(describing: pluginResult?.message))")
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            );
        })
    }
    
    func listFiles(folder: String){
        let fm = FileManager.default;
        var isDirectory:ObjCBool = false
        if(fm.fileExists(atPath: folder)){
            do{
                let list = try fm.contentsOfDirectory(atPath: folder)
                for file in list{
                    let path = folder + "/" + file
                    if(fm.fileExists(atPath: path, isDirectory: &isDirectory)){
                        if isDirectory.boolValue{
                            print(">>> \(path)")
                            listFiles(folder: path)
                        }else{
                            print("- \(path)")
                        }
                    }
                }
            }catch{
                print("listFiles contentsOfDirectory \(folder) failed!")
            }
        }else{
            print("x \(folder)")
        }
    }
}

public extension NSURL {
    func pathWithoutFileScheme() -> String! {
        return self.path?.removingRegexMatches(pattern: "^file:/+")
    }
}

public extension String {
    func removingRegexMatches(pattern: String, replaceWith: String = "")-> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.characters.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
    // Convert String to UInt8 bytes
    static func bytesFromString(string: String) -> [UInt8] {
        return Array(string.utf8)
    }
    
    // Convert UInt8 bytes to String
    static func stringFromBytes(bytes: UnsafeMutablePointer<UInt8>, count: Int) -> String {
        return String((0..<count).map ({Character(UnicodeScalar(bytes[$0]))}))
    }
    
    static func stringFromInt(bytes: UnsafeMutablePointer<Int8>, count: Int) -> String {
        return String(cString: bytes, encoding: String.Encoding.utf8)!
    }
    //    static func bytesFromString(string: String) -> [Int8] {
    //        return UnsafeMutablePointer((string as NSString).UTF8String)
    //    }
    
    func escapeStr() -> (String) {
        let raw: NSString = self as NSString
        let str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,raw,"[]." as CFString,":/?&=;+!@#$()',*" as CFString,CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
        return str! as (String)
    }
    
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func pathEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
