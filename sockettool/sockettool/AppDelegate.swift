//
//  AppDelegate.swift
//  sockettool
//
//  Created by Abu on 16/7/3.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

protocol SocketDelegate {
    func action(conn:Connection)
    func action(msg:String)
    func setButtonEnable(id:String,enable:Bool)
}
