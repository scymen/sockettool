//
//  ViewController.swift
//  sockettool
//
//  Created by Abu on 16/7/3.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa
import Foundation
import SocksCore
import Socks

class ViewController: NSViewController ,SocketDelegate{
    
    let txt_cnn : String = "Connect"
    let txt_listen : String = "Listen"
    let txt_stop : String = "Stop"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if outlet_radio_clientmodel.state == 1 {
            outlet_btn_ok.title = txt_cnn
        }
        
        outlet_textview.string = "Ready\r\n"
        
        outlet_tableview.delegate = self
        outlet_tableview.dataSource = self
       
//        outlet_tableview.target = self
//        outlet_tableview.doubleAction = Selector(("tableViewDoubleClick"))
       
//        let descriptorIP = SortDescriptor(key: "ip", ascending: true)
//        let descriptorPort = SortDescriptor(key: "port", ascending: true)
//        let descriptorStatus = SortDescriptor(key: "status", ascending: true)
//  
//        outlet_tableview.tableColumns[0].sortDescriptorPrototype = descriptorIP;
//        outlet_tableview.tableColumns[1].sortDescriptorPrototype = descriptorPort;
//        outlet_tableview.tableColumns[2].sortDescriptorPrototype = descriptorStatus;
        
        th.socketDelegate = self

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
    
    @IBOutlet weak var outlet_checkbox_hex: NSButton!
    
    @IBOutlet weak var outlet_checkbox_echo: NSButton!
    
    @IBOutlet weak var outlet_combo_echo_ms: NSComboBoxCell!
    
    @IBOutlet weak var outlet_btn_send: NSButton!
    
    @IBOutlet weak var outlet_btn_clear: NSButton!
    
    @IBOutlet var outlet_textview: NSTextView!
    
    @IBOutlet weak var outlet_txt_send: NSTextField!
    
    // delegate
    func action(conn: Connection ){
        //http://stackoverflow.com/questions/37805885/how-to-create-dispatch-queue-in-swift-3
        DispatchQueue.main.async {
            self.outlet_tableview.reloadData()
            self.outlet_textview.string = self.outlet_textview.string!+"\(conn) \r\n"
        }
        
    }
    
    @IBAction func action_btn_send(_ sender: AnyObject) {
        
        guard outlet_txt_send.stringValue.characters.count > 0 else { return }
        
        if Paras.isClientMode {
            
            do {
                try th.thisSocket?.send(data: getMsg2send())
            }catch {
                self.outlet_textview.string = self.outlet_textview.string!+"\(error) \r\n"
            }
            
        } else {
            
            let aa:IndexSet =  outlet_tableview.selectedRowIndexes
            
            print("-->> index set = \(aa)")
            th.send(descriptor: Descriptor(3), b: getMsg2send())
        }
        
    }
    
    func getMsg2send() -> [UInt8] {
        var b:[UInt8] = []
        if outlet_checkbox_hex.state == 1 {
            let hex = outlet_txt_send.stringValue.replacingOccurrences(of: " ", with: "")
            if hex.isHex() {
                b = try! hex.hex2Byte()
            } else {
                self.outlet_textview.string = self.outlet_textview.string!+"Not a hex string \r\n"
            }
        } else {
            b = outlet_txt_send.stringValue.toBytes()
        }
        return b
    }
    
    
    @IBAction func action_btn_clear(_ sender: AnyObject) {
        
        outlet_textview.string = "Clear"
        
        // outlet_tableview.beginUpdates()
        
        //   outlet_tableview.insertRows(at: IndexSet, withAnimation: NSTableViewAnimationOptions)
        
        //var IndexPathOfLastRow = NSIndexPath(forRow: self.arr.count - 1, inSection: 0)
        //var IndexPathOfLastRow = NSIndexPath(index:  1)
        // outlet_tableview.insertRows(at: IndexPathOfLastRow, withAnimation: NSTableViewAnimationOptions.slideDown)
        // self.outlet_tableview.insertRowsAtIndexPaths([IndexPathOfLastRow], withRowAnimation: UITableViewRowAnimation.Left)
        
        //  outlet_tableview.endUpdates()
        
        // outlet_tableview.insertRows(at: 2, withAnimation: NSTableViewAnimationOptions.slideDown)
        
        //        self.arr.append(["9.9.9.9","test"])
        //        outlet_tableview.reloadData()
        
        
    }
    
    @IBAction func action_radSelected(_ sender: AnyObject) {
        
        let btn = sender as! NSButton
        
        if btn == outlet_radio_clientmodel {
            outlet_btn_ok.title = txt_cnn
        }else {
            outlet_btn_ok.title = txt_listen
        }
        
    }
    
    var th : MySocket = MySocket()
    
    
    
    @IBAction func action_btnOK(_ sender: AnyObject) {
        
        if !th.isWorking {
            
            if !Paras.parasValidated(ip:outlet_txt_ip.stringValue, port: outlet_txt_port.stringValue){
                
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
                
                return
            }
            
            if outlet_radio_clientmodel.state==1{
                Paras.isClientMode = true
            } else {
                Paras.isClientMode = false
            }
            
            outlet_btn_ok.title = txt_stop
            
           // disable editing
            outlet_txt_port.isEnabled = false
            outlet_txt_ip.isEnabled = false
            outlet_radio_clientmodel.isEnabled = false
            outlet_radio_servermodel.isEnabled = false
 
            th.start2Work()
            
        } else { // socket is working
            
            if Paras.isClientMode {
                outlet_btn_ok.title = txt_cnn
            }else {
                outlet_btn_ok.title = txt_listen
            }
            
            th.stopWorking()
            
            // endable editing
            outlet_txt_port.isEnabled = true
            outlet_txt_ip.isEnabled = true
            outlet_radio_clientmodel.isEnabled = true
            outlet_radio_servermodel.isEnabled = true
        }
        
        // NSLog( "ok click")
        
    }
    
}
