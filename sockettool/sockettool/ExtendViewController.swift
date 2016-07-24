//
//  ExtendViewController.swift
//  sockettool
//
//  Created by Abu on 16/7/20.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Cocoa
import Foundation



extension ViewController : NSTableViewDataSource {

    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, for tableColumn: NSTableColumn?, row: Int){
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int{
        return  th.socketList.count
    }
    
}

extension ViewController : NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {

    }
    
    func tableViewDoubleClick(sender: AnyObject) {

    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [SortDescriptor]) {
      //  print("sort")

    }
    
    
    // called by the table view for every row and column to get the appropriate cell.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard th.socketList.count > 0 else { return nil}
        
        var text:String = ""
        var cellIdentifier: String = ""
        var objV = -1
        
        // Ambiguous reference to member 'subscript'
        var i = 0
        for (d:c) in th.socketList {
            if i == row {
                let  item:Connection = c.value

                if tableColumn == tableView.tableColumns[0] {
                    text =  item .socket.address.ipString()
                    cellIdentifier = "IP"
                    objV = Int(item.descriptor)
                } else if tableColumn == tableView.tableColumns[1] {
                    text =  item .socket.address.port.description
                    cellIdentifier = "Port"
                } else if tableColumn == tableView.tableColumns[2] {
                    text = "R(\(item.receive)) S(\(item.send))"
                    cellIdentifier = "Status"
                }
                
                break
            }
            i += 1
        }
        
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.identifier = cellIdentifier
            cell.objectValue = objV
            return cell
        }
        return nil
    }
    
}

