//
//  StateMachineCompilerPlugin.swift
//  StateMachineCompiler
//
//  Created by 森下 健 on 2014/10/25.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation

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