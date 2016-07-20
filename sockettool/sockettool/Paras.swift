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
    static var IP:String? = "127.0.0.1"
    static var port:Int32 = 8070
    static var addr :InternetAddress?
    
    override init() {
        //  GParas.addr =  InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port), addressFamily: AddressFamily.inet)
    }
    
    deinit {
        
    }
    
    
    static func parasValidated(ip:String,port:String) -> Bool {
        
        if  !port.isMatch( pattern: "^\\d{1,5}$")  || !ip.isMatch(pattern: String.reExpr_ip){
            return false
        }
        
        Paras.IP = ip
        Paras.port = Int32(port)!
        Paras.addr =  InternetAddress(hostname: Paras.IP!, port: (UInt16)(Paras.port),
                                       addressFamily: AddressFamily.inet)
        
        return true
    }
    
       
    
    
}



