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
    
    static var addr :InternetAddress? = nil
    
    deinit {
        
    }
    
    
    static  func checkParas( ) -> Bool {
        if GParas.IP == nil {
            return false
        }
        
        GParas.addr = try InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),
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
    
    static let regular_ip : String = "((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))"
    
    static func isMatch(str :String, pattern :String) -> Bool{
        
        do {
            // - 1、创建规则
            // let pattern = "[1-9][0-9]{1,5}"
            // - 2、创建正则表达式对象
            let regex = try RegularExpression(pattern: pattern, options: RegularExpression.Options.caseInsensitive)
            // - 3、开始匹配
            let res = regex.matches(in: str, options: RegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            
            if res.count > 0 {
                return true
            }else {
                return false
            }
            
            // 输出结果
            //            for checkingRes in res {
            //                print((str as NSString).substring(with: checkingRes.range))
            //            }
        }
        catch {
            print(error)
            return false
            
        }
        
    }
    
    
}
