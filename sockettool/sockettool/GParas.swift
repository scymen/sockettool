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

public class GParas:NSObject {
    
    static var isClientMode :Bool = true
    static var IP:String? = "127.0.0.1"
    static var port:Int32 = 8070
    static var addr :InternetAddress? //= InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),addressFamily: AddressFamily.inet)
    
    override init() {
              //  GParas.addr =  InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port), addressFamily: AddressFamily.inet)
    }
    
    deinit {
        
    }
    
  
    
    
    static func parasValidated(ip:String,port:String) -> Bool {
        
        if  !GParas.isMatch(str:port,pattern: "^\\d{1,5}$")
            || !GParas.isMatch(str:ip, pattern: GParas.regular_ip){
            return false
        }
        
        GParas.IP = ip
        GParas.port = Int32(port)!
        
        GParas.addr =  InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),
                                       addressFamily: AddressFamily.inet)
        
        return true
    }
    
    
    
    
    static let regular_ip : String = "((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))"
    
    static func isMatch(str :String, pattern :String) -> Bool{
        
        do {
            let regex = try RegularExpression(pattern: pattern, options: RegularExpression.Options.caseInsensitive)
            
            let res = regex.matches(in: str, options: RegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            
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
    
    
}
