//
//  StateMachineCompilerPlugin.swift
//  StateMachineCompiler
//
//  Created by 森下 健 on 2014/10/25.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import AppKit

private let API_BASE_URL = "http://goodparts.d.yumemi.jp"

private var instance_: StateMachineCompilerPlugin?

public class StateMachineCompilerPlugin : NSObject {
    public class func pluginDidLoad(bundle: NSBundle) {
        NSLog("++++++++++++++++++++++++ Swift Plugin! +++++++++++++++++++++++")
        if instance_ == nil {
            instance_ = StateMachineCompilerPlugin(bundle: bundle)
        }
    }
    
    let bundle: NSBundle
    
    init(bundle: NSBundle) {
        self.bundle = bundle
        super.init()
        setup()
    }
    
    func setup() {
        var editMenu_ = NSApp.mainMenu??.itemWithTitle("Edit")?.submenu
        var itemIndex : Int = editMenu_?.indexOfItemWithTitle("Refactor") ?? -1
        if let editMenu = editMenu_ {
            if itemIndex >= 0 {
                let smcMenuItem = NSMenuItem(title: "Generate SMC", action: "generateSMC:", keyEquivalent: "")
                smcMenuItem.target = self
                editMenu.insertItem(smcMenuItem, atIndex: itemIndex)
            }
        }
    }
    
    func generateSMC(sender: AnyObject) {
        NSLog("generateSMC Called")
        var url = currentFileURL()
        if let smc = loadCurrentSMFile(url) {
            let api = SMCAPI.Generate(baseUrl: API_BASE_URL)
            api.request(.Swift, smc: smc) { [unowned self] response in
                if !response.isSuccess() { return }
                if let body = response.data {
                    let json = NSJSONSerialization.JSONObjectWithData(body, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
                    if let code = json.objectForKey("impl") as? String {
                        let savePath = self.pathToSave(url!.path!)
                        let result = self.saveCode(code, path: savePath)
                        if result {
                            NSLog("create \(savePath)")
                        }
                    }
                }
            }
        }
    }
    
    func loadCurrentSMFile(u: NSURL?) -> NSData? {
        if let url = u {
            if url.pathExtension != "sm" {
                return nil
            }
            return NSData(contentsOfURL: url)
        }
        return nil
    }
    
    func saveCode(code: String, path: String) -> Bool {
        return code.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func pathToSave(smPath: String) -> String {
        return smPath.stringByDeletingPathExtension + ".swift"
    }
    
    func currentFileURL() -> NSURL? {
        if let currentWindowController = NSApp.keyWindow??.windowController() as? NSWindowController {
            if currentWindowController.isKindOfClass(NSClassFromString("IDEWorkspaceWindowController")) {
                if let editor: AnyObject = currentWindowController.valueForKeyPath("editorArea.lastActiveEditorContext.editor") {
                    var document : AnyObject?
                    if editor.isKindOfClass(NSClassFromString("IDESourceCodeEditor")) {
                        document = editor.valueForKey("sourceCodeDocument")
                    } else if editor.isKindOfClass(NSClassFromString("IDESourceCodeComparisonEditor")) {
                        if let primaryDocument: AnyObject = editor.valueForKey("primaryDocument") {
                            if primaryDocument.isKindOfClass(NSClassFromString("IDESourceCodeDocument")) {
                                document = primaryDocument
                            }
                        }
                    }
                    if let doc: AnyObject = document {
                        let fileReferences = doc.valueForKey("knownFileReferences") as? [AnyObject]
                        return fileReferences?.first?.valueForKeyPath("resolvedFilePath.fileURL") as? NSURL
                    }
                }
                
            }

        }
        return nil
    }
}



class SMCAPI {
    class Base {
        let baseUrl: String
        
        init(baseUrl: String) {
            self.baseUrl = baseUrl
        }
    }
    
    struct Response {
        var response: NSURLResponse?
        var data: NSData?
        var error: NSError?
        
        func isSuccess() -> Bool {
            return error == nil
        }
    }
    
    enum Language : String {
        case Swift="swift"
    }
    
    class Generate : Base {
        func request(lang: Language, smc: NSData, callback: (Response) -> Void) {
            let url = NSURL(string: baseUrl + "/generator/generate?lang=\(lang.rawValue)")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/smc", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = smc
            request.setValue("\(smc.length)", forHTTPHeaderField: "Content-Length")
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (res, data, error) in
                let r  = Response(response: res, data: data, error: error)
                callback(r)
            }
        }
    }
}




/*
public class PluginUtils : NSObject {
    public class func loggingAllNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(nil, object: nil, queue: nil) { note in
            if note.name.substringToIndex(2) != "NS" {
                return
            }
            NSLog("Notification: \(note.name)")
        }
    }
}

extension String {
    // MARK: - sub String
    func substringToIndex(index:Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
}
*/