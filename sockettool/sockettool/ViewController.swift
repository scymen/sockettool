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

        showMsg(str:"Ready",clearFirstly: true)
        
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
//            switch conn.status {
//            case .close,.new,.connecting:
//                self.outlet_tableview.reloadData()
//            case .send,.receive:
//              
//                self.outlet_tableview.reloadData(forRowIndexes: <#T##IndexSet#>, columnIndexes: <#T##IndexSet#>)
//            }
            
            self.outlet_tableview.reloadData()
            if self.outlet_checkbox_hex.state == 1 {
                self.showMsg(str: "\(conn)")
            } else {
                self.showMsg(str: "\(try! conn.bytes.toString())")
            }
            
        }
        
    }
    
    // delegate
    func action(msg:String) {
        DispatchQueue.main.async {
            self.showMsg(str: msg)
        }
    }
    
    // delegate
    func setButtonEnable(id:String,enable:Bool) {
        if id == "btnOK" {
            outlet_btn_ok.isEnabled = true
            if enable {
                // endable editing
                outlet_txt_port.isEnabled = true
                outlet_txt_ip.isEnabled = true
                outlet_radio_clientmodel.isEnabled = true
                outlet_radio_servermodel.isEnabled = true
                if Paras.isClientMode {
                    outlet_btn_ok.title = txt_cnn
                }else {
                    outlet_btn_ok.title = txt_listen
                }
            } else {
                // disable editing
                outlet_txt_port.isEnabled = false
                outlet_txt_ip.isEnabled = false
                outlet_radio_clientmodel.isEnabled = false
                outlet_radio_servermodel.isEnabled = false
                outlet_btn_ok.title = txt_stop
            }
        }
    }
    
    @IBAction func action_btn_send(_ sender: AnyObject) {
        
        guard outlet_txt_send.stringValue.characters.count > 0 else { return }
        
        if Paras.isClientMode {
            
            th.send(b: getMsg2send())
            
        } else {
            
            
            let indexSet =  outlet_tableview.selectedRowIndexes
            
            if indexSet.count == 0 {
                let de = th.socketList.first?.value.descriptor
                th.send(descriptor: de! , b:  getMsg2send())
            } else {
                
                var d :[Descriptor] = []
                
                for i in indexSet.enumerated() {
                    let v = outlet_tableview.view(atColumn: 0, row: i.element, makeIfNecessary: false)
                    
                    let cellview = v as! NSTableCellView
                    let ob = cellview.objectValue as! Int
                    d.append(Descriptor( ob))
                }
                print("-->> index set = \(indexSet) , descriptor = \(d)")
                th.send(descriptor:d, b: getMsg2send())
            }
            
        }
        
    }
    
    func getMsg2send() -> [UInt8] {
        var b:[UInt8] = []
        if outlet_checkbox_hex.state == 1 {
            let hex = outlet_txt_send.stringValue.replacingOccurrences(of: " ", with: "")
            if hex.isHex() {
                b = try! hex.hex2Byte()
            } else {
                showMsg(str:  "Not a hex string")
            }
        } else {
            b = outlet_txt_send.stringValue.toBytes()
        }
        return b
    }
    
    
    func showMsg(str:String,clearFirstly:Bool = false,newLine:Bool = true) {
        let a : String = clearFirstly ? "":self.outlet_textview.string!
        self.outlet_textview.string = a + "\(Date().toString(fmt: "HH:mm:ss.SSS")) \(str)"
            + (newLine ? "\r" :"")
    }
    
    
    @IBAction func action_btn_clear(_ sender: AnyObject) {
        
        showMsg(str: "Clear",clearFirstly: true)
        
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
            
            Paras.IP = outlet_txt_ip.stringValue
            Paras.port = outlet_txt_port.stringValue
            if outlet_radio_clientmodel.state == NSOnState {
                Paras.isClientMode = true
            } else {
                Paras.isClientMode = false
            }
            
            if !Paras.validate(){
                
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
            
            // disable editing
            setButtonEnable(id: "btnOK", enable: false)
            
            outlet_btn_ok.isEnabled = false
            
            th.start2Work()
            
        } else { //stop working
            
            th.stopWorking()
            setButtonEnable(id: "btnOK", enable: true)
        }
        
    }
    
}
