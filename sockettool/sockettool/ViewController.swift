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
import SocksCore


class ViewController: NSViewController ,SocketDelegate{
    
    let txt_cnn : String = "Connect"
    let txt_listen : String = "Listen"
    let txt_stop : String = "Stop"
    
    //  var arr :[[String]] = [["1.1.1.1","80"],["2.2.2.2","81"],["3.3.3.3","82"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if outlet_radio_clientmodel.state == 1 {
            outlet_btn_ok.title = txt_cnn
        }
        
        outlet_textview.string = "Ready"
        
        outlet_tableview.delegate = self
        outlet_tableview.dataSource = self
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
    
    @IBOutlet weak var outlet_btn_save_as: NSButton!
    
    @IBOutlet weak var outlet_btn_clear: NSButton!
    
    @IBOutlet var outlet_textview: NSTextView!
    
    
    func action(conn: Connection ){
        //http://stackoverflow.com/questions/37805885/how-to-create-dispatch-queue-in-swift-3
        DispatchQueue.main.sync {
            outlet_tableview.reloadData()
            outlet_textview.string = outlet_textview.string!+"\(conn) \r\n"
        }
        
    }
    
    
    @IBAction func action_btn_clear(_ sender: AnyObject) {
        
        //        let fuckapple :NSClipView =   outlet_textview.contentView
        //        var shit : NSTextView? = nil
        //
        //        for n  in fuckapple.subviews {
        //            if n.className == "NSTextView" {
        //                shit = n as? NSTextView
        //                break
        //            }
        //        }
        //
        //        if shit != nil {
        //            shit?.string = "wft apple"
        //        }
        
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
            
            if !GParas.parasValidated(ip:outlet_txt_ip.stringValue, port: outlet_txt_port.stringValue){
                
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
                GParas.isClientMode = true
            } else {
                GParas.isClientMode = false
            }
            
            outlet_btn_ok.title = txt_stop
            
            th.start2Work()
            
        } else { // socket is working
            
            if GParas.isClientMode {
                outlet_btn_ok.title = txt_cnn
            }else {
                outlet_btn_ok.title = txt_listen
            }
            
            th.stopWorking()
            
        }
        
        // NSLog( "ok click")
        
    }
    
}


extension ViewController : NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, for tableColumn: NSTableColumn?, row: Int){
        
        
    }
    
    //numberOfRowsInTableView
    func numberOfRows(in tableView: NSTableView) -> Int{
        return  th.socketList.count
        
    }
    
}

extension ViewController : NSTableViewDelegate {
    
    // called by the table view for every row and column to get the appropriate cell.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard th.socketList.count > 0 else { return nil}
        
        var text:String = ""
        var cellIdentifier: String = ""
        
        // Ambiguous reference to member 'subscript'
        var i = 0
        for (d:c) in th.socketList {
            if i == row {
                let  item:Connection = c.value
                
                if tableColumn == tableView.tableColumns[0] {
                    text =  item .socket.address.ipString()
                    cellIdentifier = "ipcellID"
                } else if tableColumn == tableView.tableColumns[1] {
                    text =  item .socket.address.port.description
                    cellIdentifier = "portcellID"
                } else if tableColumn == tableView.tableColumns[2] {
                    text = "R(\(item.receive)) S(\(item.send))"
                    cellIdentifier = "statuscellID"
                }
                
                break
            }
            i += 1
        }
        
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
