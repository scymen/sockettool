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
    
    //    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
    //        return nil
    //    }
    
    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, for tableColumn: NSTableColumn?, row: Int){
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int{
        return  th.socketList.count
    }
    
}

extension ViewController : NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
//        let selects = outlet_tableview.selectedRowIndexes
//        
//        let a =  outlet_tableview.accessibilityCell(forColumn: 0, row: selects.first!)
//        let b = a as! NSTableCellView
//        let c = b.objectValue
//        //        var mySelectedRows = [Int]()
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
        
        // Ambiguous reference to member 'subscript'
        var i = 0
        for (d:c) in th.socketList {
            if i == row {
                let  item:Connection = c.value

                if tableColumn == tableView.tableColumns[0] {
                    text =  item .socket.address.ipString()
                    cellIdentifier = "IP"
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
            cell.objectValue = 9
            return cell
        }
        return nil
    }
    
}

