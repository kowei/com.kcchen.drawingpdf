#!/usr/bin/env node

/**
 * https://github.com/alunny/node-xcode/tree/master/test
 * 
 * see node_modules/xcode/pbxProject.js
 *     cordova/lib/projectFile.ks
 * 
 * Context {
  hook: 'after_plugin_install',
  opts:
   { cordova: { platforms: [Object], plugins: [Object], version: '6.5.0' },
     plugin:
      { id: 'com.kcchen.drawingpdf',
        pluginInfo: [Object],
        platform: 'ios',
        dir: '/Users/kowei/WebstormProjects/DrawingApp2/plugins/com.kcchen.drawingpdf' },
     nohooks: undefined,
     projectRoot: '/Users/kowei/WebstormProjects/DrawingApp2' },
  cmdLine: '/usr/local/Cellar/nvm/0.32.1/versions/node/v6.9.1/bin/node /usr/local/opt/nvm/versions/node/v6.9.1/bin/cordova plugin add ./custom_plugins/com.kcchen.drawingpdf',
  cordova:
   { binname: [Getter/Setter],
     on: [Function: on],
     off: [Function: off],
     removeListener: [Function: off],
     removeAllListeners: [Function: removeAllListeners],
     emit: [Function: emit],
     trigger: [Function: emit],
     raw: {},
     findProjectRoot: [Function],
     prepare: [Function],
     build: [Function],
     create: [Function],
     emulate: [Function],
     plugin: [Function],
     plugins: [Function],
     platform: [Function],
     platforms: [Function],
     compile: [Function],
     run: [Function],
     info: [Function],
     targets: [Function],
     requirements: [Function],
     projectMetadata: [Function],
     clean: [Function] },
  scriptLocation: '/Users/kowei/WebstormProjects/DrawingApp2/plugins/com.kcchen.drawingpdf/hooks/add_xcconfig.js' }
 */
var fs = require('fs'),
    path = require('path'),
    exec = require('child_process').exec,
    xcode = require('xcode'),
    plist = require('plist'),
    _ = require('underscore'),
    util = require('util');
const encoding = 'utf-8',
    swiftVersion = "3.0",
    COMMENT_KEY = /_comment$/,
    LIBRARY_PATTERN = /([\s\S]*)(LIBRARY_SEARCH_PATHS)[\s|\t]*=[\s|\t]*(.*)([\s\S]*)/,
    HEADER_PATTERN = /([\s\S]*)(HEADER_SEARCH_PATHS)[\s|\t]*=[\s|\t]*(.*)([\s\S]*)/,
    swiftPattern = /([\s\S]*)(SWIFT_VERSION)[\s|\t]*=[\s|\t]*([0-9|\.]*)([\s\S]*)/,
    swiftOldPattern = /([\s\S]*)(SWIFT_OLD_VERSION)[\s|\t]*=[\s|\t]*([0-9|\.]*)([\s\S]*)/,
    lockPath = './custom_plugins/com.kcchen.drawingpdf/hooks/lock',
    cordovaRoot = "$(PROJECT_DIR)/$(PROJECT_NAME)/../cordova",
    pluginRoot = "$(PROJECT_DIR)/$(PROJECT_NAME)/Plugins",
    headerIds = [
        "com.kcchen.drawingpdf",
        // "com.kcchen.drawingpdf/wrapper"
    ],
    libIds = [
        "com.kcchen.drawingpdf/lib"
    ],
    bridgeHeaderImport = [
        '#include "mupdf/fitz.h"',
        '#include "mupdf/pdf.h"',
        // '#include "MuDocumentController.h"',
        '#include "mupdf/z/z_pdf.h"'
    ],


    namePattern = /[\s\S]*PBXProject[\s|\t]*\"(.*)\"/,
    sep = "--------------------------------------------------------------------------------------------------------------------\n";
var xcBuildConfiguration,
    pbx,
    plistValue,
    f = util.format,
    projectName,
    xcconfigPath,
    xcconfig,
    bridgeHeader,
    bridgeHeaderPath,
    headerPath,
    libPath,
    xcodeCordovaProj;


module.exports = function (context) {
    // console.log(context)

    console.log('> check ios... ' + (context.opts.cordova.platforms.indexOf('ios') != -1))
    if (context.opts.cordova.platforms.indexOf('ios') === -1) return;

    console.log('######################### ADD XCCONFIG #########################')


    if (prepare()) {
        console.log("> add Search Path...")
        addSwiftVersion()
        addSearchPath()
        addBridgeHeader()
        fs.writeFileSync(xcconfigPath, xcconfig, encoding);
        fs.writeFileSync(bridgeHeaderPath, bridgeHeader, encoding);
    }


    console.log('------------------------- ADD XCCONFIG  -------------------------')

    return





    function merge(list, itemList) {
        var items = list.split(" "),
            isExisted = false

        for (item of itemList) {
            isExisted = false
            for (entry of items) {
                if (entry === item) {
                    isExisted = true
                }
            }
            if (!isExisted) {
                items.push(item)
            }
        }

        return items.join(" ")
    }

    function addSearchPath() {
        console.log("> add Search Path...")
        try {
            var matches
            var lines = xcconfig.split("\n")
            var isLibExisted = false,
                isHeaderExisted = false
            for (lineKey in lines) {
                matches = lines[lineKey].match(/^(LIBRARY_SEARCH_PATHS[\s|\t]*=[\s|\t]*)(.*)/)
                if (matches) {
                    console.log("> found and modify LIBRARY_SEARCH_PATHS ... " + matches[1] + matches[2])
                    lines[lineKey] = matches[1] + merge(matches[2], libPath)
                    isLibExisted = true
                }
                matches = lines[lineKey].match(/^(HEADER_SEARCH_PATHS[\s|\t]*=[\s|\t]*)(.*)/)
                if (matches) {
                    console.log("> found and modify HEADER_SEARCH_PATHS ... " + matches[1] + matches[2])
                    lines[lineKey] = matches[1] + merge(matches[2], headerPath)
                    isHeaderExisted = true
                }
            }
            if (!isLibExisted) {
                lines.push('LIBRARY_SEARCH_PATHS = ' + libPath)
            }
            if (!isHeaderExisted) {
                lines.push('HEADER_SEARCH_PATHS = ' + headerPath)
            }
            xcconfig = lines.join("\n")

        } catch (ex) {
            console.error(ex);
        }
    }

    function addSwiftVersion() {

        xcconfig = xcconfig.replace(/^\s*[\r\n]/gm, '\n')
        var matches = xcconfig.match(swiftPattern)
        if (matches) {
            // printRegEx(matches)
            console.log('> check SWIFT_VERSION... ' + ((swiftVersion > matches[3]) ? "use " + swiftVersion + " instead of " + matches[3] : "use current " + matches[3]))
            // set SWIFT_VERSION, replace new
            if (swiftVersion > matches[3]) {
                var matchesOld = xcconfig.match(swiftOldPattern)
                if (matchesOld) {
                    xcconfig =
                        matches[1] +
                        matches[2] +
                        " = " +
                        swiftVersion +
                        matches[4]
                    matchesOld = xcconfig.match(swiftOldPattern)
                    console.log('> replace SWIFT_VERSION... ' + matches[2] + " = " + swiftVersion)
                    printRegEx(matchesOld)
                    xcconfig =
                        matchesOld[1] +
                        matchesOld[2] +
                        " = " +
                        matches[3] +
                        matchesOld[4]
                    console.log('> replace SWIFT_OLD_VERSION... ' + matchesOld[2] + " = " + matches[3])
                } else {
                    // not set SWIFT_OLD_VERSION, add new
                    xcconfig =
                        matches[1] +
                        'SWIFT_OLD_VERSION' +
                        " = " +
                        matches[3] +
                        "\n" +
                        matches[2] +
                        " = " +
                        swiftVersion +
                        matches[4]

                    console.log('> replace SWIFT_VERSION SWIFT_OLD_VERSION... ' + 'SWIFT_OLD_VERSION' +
                        " = " +
                        matches[3] +
                        "\n" +
                        matches[2] +
                        " = " +
                        swiftVersion)
                }
            } else {
                // that's what we need
                console.log('> NO CHANGES, use current version... ' + matches[3])
            }
        } else {
            // not set SWIFT_VERSION, add new
            xcconfig += '\n' + 'SWIFT_OLD_VERSION' + ' = ' + swiftVersion;
            xcconfig += '\n' + "SWIFT_VERSION" + ' = ' + swiftVersion;
            console.log('@ SET  SWIFT_VERSION = ' + swiftVersion)
        }
    }

    function addBridgeHeader() {
        console.log("> add Bridge Header...")
        try {

            var lines = bridgeHeader.split("\n")
            for (importEntry of bridgeHeaderImport) {
                var isExisted = false
                for (lineKey in lines) {
                    if (lines[lineKey] === importEntry) {
                        isExisted = true
                    }
                }
                if (!isExisted) {
                    lines.push(importEntry)
                }
            }
            bridgeHeader = lines.join("\n")
            // console.log(lines)

        } catch (ex) {
            console.error('\nThere was an error fetching your ../../build.json file.');
        }
    }

    function openXcConfig() {
        if (!xcconfigPath) xcconfigPath = getXcconfigPath(context)
        try {
            xcconfig = fs.readFileSync(xcconfigPath, encoding);
            console.log("> check xcconfigPath [" + xcconfigPath + "]... " + !(!xcconfig))
        } catch (e) {
            console.error("> check xcconfigPath [" + xcconfigPath + "]... NOT EXISTED.")
            console.error(e)
            return
        }
        return !(!xcconfig);
    }

    function openBridgeHeader() {
        if (!bridgeHeaderPath) bridgeHeaderPath = getBridgeHeaderPath(context)
        try {
            bridgeHeader = fs.readFileSync(bridgeHeaderPath, encoding);
            console.log("> check bridgeHeaderPath [" + bridgeHeaderPath + "]... " + !(!bridgeHeader))
        } catch (e) {
            console.error("> check bridgeHeaderPath [" + bridgeHeaderPath + "]... NOT EXISTED.")
            console.error(e)
            return
        }
        return !(!bridgeHeader);
    }

    function wrapPath(pathes) {
        var finalPathes = []
        for (p of pathes) {
            finalPathes.push("\"" + path.join(pluginRoot, p) + "\"")
        }
        return finalPathes
    }

    function prepare() {

        if (!openXcConfig()) return false;
        if (!openBridgeHeader()) return false;

        headerPath = wrapPath(headerIds)
        libPath = wrapPath(libIds)

        console.log("> prepared!")
        return true

    }

    function getXcodeProjectPath(context) {
        var root = path.join(context.opts.projectRoot, "platforms", 'ios')

        var xcodeProjDir;
        var xcodeCordovaProj;

        try {
            xcodeProjDir = fs.readdirSync(root).filter(function (e) {
                return e.match(/\.xcodeproj$/i);
            })[0];
            if (!xcodeProjDir) {
                throw new Error('The provided path "' + root + '" is not a Cordova iOS project.');
            }

            var cordovaProjName = xcodeProjDir.substring(xcodeProjDir.lastIndexOf(path.sep) + 1, xcodeProjDir.indexOf('.xcodeproj'));
            xcodeCordovaProj = path.join(root, cordovaProjName);
        } catch (e) {
            throw new Error('The provided path "' + root + '" is not a Cordova iOS project.');
        }

        return path.join(root, xcodeProjDir, 'project.pbxproj')
    }

    function getXcconfigPath(context) {
        var root = path.join(context.opts.projectRoot, "platforms", 'ios', 'cordova', 'build.xcconfig')

        return root
    }

    function getBridgeHeaderPath(context) {
        var root = path.join(context.opts.projectRoot, "platforms", 'ios')

        var xcodeProjDir;
        xcodeCordovaProj;

        try {
            xcodeProjDir = fs.readdirSync(root).filter(function (e) {
                return e.match(/\.xcodeproj$/i);
            })[0];
            if (!xcodeProjDir) {
                throw new Error('The provided path "' + root + '" is not a Cordova iOS project.');
            }

            var cordovaProjName = xcodeProjDir.substring(xcodeProjDir.lastIndexOf(path.sep) + 1, xcodeProjDir.indexOf('.xcodeproj'));
            xcodeCordovaProj = path.join(root, cordovaProjName);
        } catch (e) {
            throw new Error('The provided path "' + root + '" is not a Cordova iOS project.');
        }

        return path.join(xcodeCordovaProj, 'Bridging-Header.h')
    }

    function printRegEx(matches) {
        console.log('  -> matches: ' + matches.length)
        matches.forEach(function (element) {
            if (element) {
                if (element.length < 30) {
                    console.log('  -> matches element... ' + element)
                } else {
                    var short = element.substring(0, 30)
                    short.match(/(^[\s\S]*$)\n/m)
                    console.log('  -> matches element... ' + short.replace('/[\n|\r]+/', '                        \n'))
                }
            } else {
                console.log('  -> matches element... null')
            }
        }, this);
    }
};
