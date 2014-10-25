//
//  PluginUtils.swift
//  StateMachineCompiler
//
//  Created by 森下 健 on 2014/10/25.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation

public class PluginUtils : NSObject {
    public class func loggingAllNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(nil, object: nil, queue: NSOperationQueue.mainQueue()) { note in
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