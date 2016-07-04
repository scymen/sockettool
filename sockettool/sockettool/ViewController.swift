//
//  ViewController.swift
//  sockettool
//
//  Created by Abu on 16/7/3.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var outlet_radio_servermodel: NSButton!
    
    @IBOutlet weak var outlet_radio_clientmodel: NSButton!
    
    
    @IBAction func action_radSelected(_ sender: AnyObject) {
        
        let btn = sender as! NSButton
        
        if btn == outlet_radio_clientmodel {
            NSLog("client")
        }
        
        if btn == outlet_radio_servermodel {
            NSLog("server 4")
           
        }
    }
    
    
    @IBAction func action_btnOK(_ sender: AnyObject) {
        
        NSLog( "ok click")
        
    }
    
}

