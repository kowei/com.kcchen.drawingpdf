exports.openPDF = function (params) {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(JSON.parse(decodeURIComponent(args)));
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'openPDF', [params]
        );
    });
};
exports.insertBase64Image = function (params) {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'insertBase64Image', [params]
        );
    });
};
exports.insertBase64SVG = function (params) {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'insertBase64SVG', [params]
        );
    });
};
exports.insertImagePath = function (path, pageIdx, x, y, w, h) {
    if (w === void 0) {
        w = 0;
    }
    if (h === void 0) {
        h = 0;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'insertImagePath', [path, pageIdx, x, y, w, h]
        );
    });
};
exports.insertSVGPath = function (path, pageIdx, x, y, w, h) {
    if (w === void 0) {
        w = 0;
    }
    if (h === void 0) {
        h = 0;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'insertSVGPath', [path, pageIdx, x, y, w, h]
        );
    });
};
exports.getTotalPages = function () {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'getTotalPages', []
        );
    });
};
exports.openPDFforExport = function (path, password, resolution, timeout) {
    if (path === void 0) {
        path = '';
    }
    if (password === void 0) {
        password = '';
    }
    if (resolution === void 0) {
        resolution = 72;
    }
    if (timeout === void 0) { // 9999: no auto close PDF context, 0: 15 secs
        timeout = 9999;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(JSON.parse(decodeURIComponent(args)));
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'openPDFforExport', [path, password, resolution, timeout]
        );
    });
};
exports.getPDFforExportDimension = function (pageIdx) {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(JSON.parse(decodeURIComponent(args)));
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'getPDFforExportDimension', [pageIdx]
        );
    });
};
exports.getPDFforExportSVG = function (pageIdx, outFilePath, resolution) {
    if (outFilePath === void 0) {
        outFilePath = '';
    }
    if (resolution === void 0) {
        resolution = 0;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                var decoded = decodeURIComponent(args)
                // console.log('> getPDFforExportSVG string:' + args.length)
                // console.log('> getPDFforExportSVG decoded:' + decoded.length)
                resolve(decoded);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'getPDFforExportSVG', [pageIdx, outFilePath, resolution]
        );
    });
};
exports.getPDFforExportPNG = function (pageIdx, outFilePath, resolution) {
    if (outFilePath === void 0) {
        outFilePath = '';
    }
    if (resolution === void 0) {
        resolution = 0;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'getPDFforExportPNG', [pageIdx, outFilePath, resolution]
        );
    });
};
exports.setPNGPathFullForExport = function (path, pageIdx, x, y, w, h) {
    if (path === void 0) {
        path = '';
    }
    if (w === void 0) {
        w = 0;
    }
    if (h === void 0) {
        h = 0;
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'setPNGPathFullForExport', [path, pageIdx, x, y, w, h]
        );
    });
};
exports.getPDFforExportTotalPages = function () {
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'getPDFforExportTotalPages', []
        );
    });
};
exports.closePDFforExport = function (path) {
    if (path === void 0) {
        path = '';
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'closePDFforExport', [path]
        );
    });
};
exports.closePDF = function (path) {
    if (path === void 0) {
        path = '';
    }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(
            function (args) {
                resolve(args);
            },
            function (args) {
                reject(args);
            },
            'DrawingPDF',
            'closePDF', [path]
        );
    });
};
