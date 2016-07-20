//
//  ExtendThem.swift
//  sockettool
//
//  Created by Abu on 16/7/20.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa
import Foundation


extension String :ErrorProtocol{
    
    func sub(start:Int,end:Int) throws -> String  {
        guard (end >= start && start >= 0 && end <= (self.characters.count-1) ) else { throw "range of index error" }
        var res:[Character] = []
        var self2 = Array(self.characters)
        for i in start...end {
            res.append(self2[i])
        }
        return String(res)
    }
    
    func hex2Byte() throws -> [UInt8] {
        guard self.characters.count > 0 else { return [] }
        var b:[UInt8] = []
        var hex = self
        if hex.characters.count % 2 != 0 {
            hex += "0"
        }
        for i in 0...((hex.characters.count/2)-1){
            let s = try hex.sub(start: i*2, end: i*2+1)
            let a:Int = Int(s,radix: 16)!
            b .append(UInt8(a))
        }
        return b
    }
    
    func insert(step:Int,ch:Character) -> String {
        guard (step > 0 && self.characters.count >= step) else { return self }
        let b = Array(self.characters)
        var d:[Character] = []
        var s = 0
        for c in b {
            d.append(c)
            s += 1
            if s >= step {
                d.append(ch)
                s = 0
            }
        }
        return String(d)
    }
    
    
    
    func isHex() -> Bool {
        if self.characters.count == 0 {
            return false
        }
        let reg:String = "^([0-9a-fA-F]+)$"
        return isMatch(pattern: reg)
    }
    
    func isIP() -> Bool {
        return isMatch(pattern: String.reExpr_ip)
    }
    
    func isMatch(pattern :String) -> Bool{
        do {
            let regex = try RegularExpression(pattern: pattern, options: RegularExpression.Options.caseInsensitive)
            let res = regex.matches(in: self, options: RegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count))
            
            if res.count > 0 {
                return true
            }else {
                return false
            }
            //  for checkingRes in res {
            //      print((str as NSString).substring(with: checkingRes.range))
            //  }
        }
        catch {
            print(error)
            return false
        }
    }
    
    static let reExpr_ip : String = "((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))"
    
    
}

extension Collection where  Iterator.Element == UInt8 {
    
    func toHex() -> String {
        let _hex = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        guard self.count > 0 else { return "" }
        var s = ""
        for b in self {
            s += _hex[ (Int)((b & 0xf0)>>4)]
            s += _hex[(Int)(b & 0x0f)]
        }
        return s
    }
    
}



extension ViewController : NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, for tableColumn: NSTableColumn?, row: Int){
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int{
        return  th.socketList.count
        
    }
    
}

extension ViewController : NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        //        var mySelectedRows = [Int]()
        //        let myTableViewFromNotification = notification.object as! NSTableView
        //        // In this example, the TableView allows multiple selection
        //        let indexes = myTableViewFromNotification.selectedRowIndexes
        //        var index = indexes.first
        //        while (index != nil && index != NSNotFound) {
        //            mySelectedRows.append(index!)
        //            index = indexes.integerGreaterThan(index!)
        //        }
        //
        //        print(mySelectedRows)
    }
    
    func tableViewDoubleClick(sender: AnyObject) {
        print("doubleclick")
        //        guard outlet_tableview.selectedRow >= 0  else {
        //            return
        //        }
        //
        //        if item.isFolder {
        //            self.representedObject = item.url
        //        } else {
        //            NSWorkspace.sharedWorkspace().openURL(item.url)
        //        }
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [SortDescriptor]) {
        print("sort")

        //        guard let sortDescriptor = tableView.sortDescriptors.first else {
        //            return
        //        }
        //        if let order = Directory.FileOrder(rawValue: sortDescriptor.key! ) {
        //            sortOrder = order
        //            sortAscending = sortDescriptor.ascending
        //            reloadFileList()
        //        }
    }
    
    
    // called by the table view for every row and column to get the appropriate cell.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard th.socketList.count > 0 else { return nil}
        
        var text:String = ""
        var cellIdentifier: String = ""
        // var descriptor :AnyObject = -1
        // Ambiguous reference to member 'subscript'
        var i = 0
        for (d:c) in th.socketList {
            if i == row {
                let  item:Connection = c.value
                
                //  descriptor =  item.descriptor as! AnyObject
                
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
            //  cell.objectValue = descriptor
            return cell
        }
        return nil
    }
}

