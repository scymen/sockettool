//
//  ViewController.swift
//  sockettool
//
//  Created by Abu on 16/7/3.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa
import Foundation
import Socks




class ViewController: NSViewController {
    
    let txt_cnn : String = "Connect"
    let txt_cnn_ing : String = "Connecting..."
    let txt_listen : String = "Listen"
    let txt_listening : String = "Listening.."
    let txt_stop : String = "Stop"
    
    let arr :[[String]] = [["1.1.1.1","80"],["2.2.2.2","81"],["3.3.3.3","82"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if outlet_radio_clientmodel.state == 1 {
            outlet_btn_ok.title = txt_cnn
        }
        
        outlet_tableview.delegate = self
        outlet_tableview.dataSource = self
        
      //  outlet_tableview.setDelegate(self)
      //  outlet_tableview.setDataSource(self)
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    @IBOutlet weak var outlet_tableview: NSTableView!
    
    @IBOutlet weak var outlet_txt_port: NSTextField!
    
    @IBOutlet weak var outlet_txt_ip: NSTextField!
    
    @IBOutlet weak var outlet_radio_servermodel: NSButton!
    
    @IBOutlet weak var outlet_radio_clientmodel: NSButton!
    
    @IBOutlet weak var outlet_btn_ok: NSButton!
    
    @IBOutlet weak var outlet_btn_save_as: NSButton!
    
    @IBOutlet weak var outlet_btn_clear: NSButton!
    
    @IBOutlet weak var outlet_textview: NSScrollView!
    
    @IBAction func action_btn_clear(_ sender: AnyObject) {
        
        //  outlet_textview.text = ""
        //  outlet_textview.title = ""
        //  outlet_textview.stringValue = ""
        //  outlet_textview.contentView.storage
        
        let fuckapple :NSClipView =   outlet_textview.contentView
        var shit : NSTextView? = nil
        
        for n  in fuckapple.subviews {
            if n.className == "NSTextView" {
                shit = n as? NSTextView
                break
            }
        }
        
        if shit != nil {
            shit?.string = "wft apple"
        }
        
        
    }
    
    @IBAction func action_radSelected(_ sender: AnyObject) {
        
        let btn = sender as! NSButton
        
        if btn == outlet_radio_clientmodel {
            outlet_btn_ok.title = txt_cnn
        }else {
            outlet_btn_ok.title = txt_listen
        }
        // outlet_btn_ok.autoresizesSubviews = true
        //  if btn == outlet_radio_servermodel {
        //     NSLog("server 4")
        //
        //  }
    }
    
    
    
    @IBAction func action_btnOK(_ sender: AnyObject) {
        
        if outlet_radio_clientmodel.state==1{
            GParas.isClientMode = true
        } else {
            GParas.isClientMode = false
        }
        
        if  !GParas.isMatch(str: outlet_txt_port.stringValue,pattern: "^\\d{1,5}$")
            || !GParas.isMatch(str: outlet_txt_ip.stringValue, pattern: GParas.regular_ip){
            
            let a = NSAlert()
            a.messageText = "Error"
            a.informativeText = "IP or Port invalidated"
            a.addButton(withTitle: "OK")
            // a.addButton(withTitle: "Cancel")
            a.alertStyle = NSAlertStyle.warning
            
            a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                if modalResponse == NSAlertFirstButtonReturn {
                    NSLog(a.informativeText)
                }
            })
            
            
        } else {
            
            GParas.IP =  outlet_txt_ip.stringValue
            GParas.port = (Int32)( outlet_txt_port.stringValue)!
            GParas.checkParas()
            
            
        }
        
        // NSLog( "ok click")
        
    }
    
}


extension ViewController : NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        
//        // var image:NSImage?
//        var text:String = ""
//        var cellIdentifier: String = ""
//        
//        // 1
//        //        guard let item = arr[row] else {
//        //            return nil
//        //        }
//        
//        let item = arr[row]
//        
//        // 2
//        if tableColumn == tableView.tableColumns[0] {
//            // image = item.icon
//            text = item[0]
//            cellIdentifier = "NameCellID"
//        } else if tableColumn == tableView.tableColumns[1] {
//            text = item[1]
//            cellIdentifier = "DateCellID"
//        } else if tableColumn == tableView.tableColumns[2] {
//            text = "sizeeee"
//            cellIdentifier = "SizeCellID"
//        }
//        
//        // 3
//        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
//            cell.textField?.stringValue = text
//            // cell.imageView?.image = image ?? nil
//            return cell
//        }
        return nil
    }
    
    
      func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, for tableColumn: NSTableColumn?, row: Int){
        
        
    }
    
    //numberOfRowsInTableView
    func numberOfRows(in tableView: NSTableView) -> Int{
  //  func numberOfRows(tableView: NSTableView) -> Int {
        // return directoryItems?.count ?? 0
        
        return arr.count
    }
    
}

extension ViewController : NSTableViewDelegate {
    
    // called by the table view for every row and column to get the appropriate cell.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        // 1
        //        guard let item = arr[row] else {
        //            return nil
        //        }
        
        let item = arr[row]
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            // image = item.icon
            text = item[0]
            cellIdentifier = "ipcellID"
        } else if tableColumn == tableView.tableColumns[1] {
            text = item[1]
            cellIdentifier = "portcellID"
        } else if tableColumn == tableView.tableColumns[2] {
            text = "sizeeee"
            cellIdentifier = "statuscellID"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            // cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
}
