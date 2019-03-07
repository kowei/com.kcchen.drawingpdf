interface Window {
    DrawingPDF: {
        openPDF: (url: string) => Promise<OpenPDFInfo>;
        insertBase64Image: (imageBase64Url: string) => Promise<any>;
        insertBase64SVG: (svgBase64Url: string) => Promise<any>;
        insertImagePath: (path: string, pageIdx: number, x: number, y: number, w?: number, h?: number) => Promise<any>;
        insertSVGPath: (path: string, pageIdx: number, x: number, y: number, w?: number, h?: number) => Promise<any>;
        getTotalPages: () => Promise<any>;
        openPDFforExport: (path: string, password?: string, resolution?: number, timeout?: number) => Promise<OpenPDFInfo>;
        getPDFforExportDimension: (pageIdx: number) => Promise<JSON>;
        getPDFforExportSVG: (pageIdx: number, outFilePath?:string, resolution?: number) => Promise<any>;
        getPDFforExportPNG: (pageIdx: number, outFilePath:string, resolution?: number) => Promise<boolean>;
        setPNGPathFullForExport: (path: string, pageIdx: number, x: number, y: number, w?: number, h?: number) => Promise<any>;
        getPDFforExportTotalPages: () => Promise<number>;
        closePDFforExport: (path?: string) => Promise<any>;
        closePDF: (path: string) => Promise<any>;
    }
}

declare interface OpenPDFInfo {
    isUnencryptedPDF: boolean;
    needsPassword: boolean;
    countPages: number;
}
