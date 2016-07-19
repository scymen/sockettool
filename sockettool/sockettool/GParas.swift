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
    
}


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
    
    private static let _hex = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    
    static func toHex(byte:[UInt8]) -> String {
        guard byte.count > 0 else { return "" }
        var s = ""
        for b in byte {
            s += _hex[ (Int)((b & 0xf0)>>4)]
            s += _hex[(Int)(b & 0x0f)]
        }
        return s
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
