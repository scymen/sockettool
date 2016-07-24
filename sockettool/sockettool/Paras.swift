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

public class Paras:NSObject {
    
    static var isClientMode :Bool = true
    static var IP:String = "0.0.0.0"
    static var port:String = "1080"
    static var addr :InternetAddress?
    
    override init() {

    }
    
    deinit {
        
    }
    
    
    static func validate() -> Bool {
 
        if !Paras.port.isMatch(pattern:"^\\d{1,5}$") || !Paras.IP.isMatch(pattern:String.reExpr_ip) {
            return false
        }
        
        Paras.addr =  InternetAddress(hostname: Paras.IP, port: UInt16(  Paras.port )!,
                                       addressFamily: AddressFamily.inet)
        
        return true
    }
    
       
    
    
}



