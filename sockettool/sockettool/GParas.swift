//
//  GParas.swift
//  sockettool
//
//  Created by Abu on 16/7/5.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Foundation
import Socks
import SocksCore

public class GParas {
    
    static var isClientMode :Bool = true
    static var isWorking:Bool = false
    static var IP:String? = ""
    static var port:Int32 = 8080
    
    var addr :InternetAddress? = nil
    
    deinit {
        
    }
    
    
    func checkParas( ) -> Bool {
        if GParas.IP == nil {
            return false
        }
        
        self.addr = try InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),
                                        addressFamily: AddressFamily.inet)
        
        return true
    }
    
    
    
    func startServer( )
    {
        
        do {
            let server = try SynchronousTCPServer(port: 8080)
            print("Listening on \"\(server.address.hostname)\" (\(server.address.addressFamily)) \(server.address.port)")
            
            try server.startWithHandler { (client) in
                //echo
                let data = try client.receiveAll()
                try client.send(bytes: data)
                try client.close()
                print("Echoed: \(try data.toString())")
            }
        } catch {
            print("Error \(error)")
        }
        
        
    }
    
}
