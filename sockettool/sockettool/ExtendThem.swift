//
//  ExtendThem.swift
//  sockettool
//
//  Created by Abu on 16/7/20.
//  Copyright © 2016年 sockettool. All rights reserved.
//


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
    
    func toASCIIs() -> String {
        if self.count <= 0 { return "" }
        //var ch:[Character] = []
        var s = ""
        for c in self {
            s += UnicodeScalar(c).escaped(asASCII: false)
            //  ch.append( Character(UnicodeScalar(c).escaped(asASCII: false)))
        }
        return  s
        //let b:[UInt8] = self as! [UInt8]
        // let ns = NSString(bytes: b, length: b.count, encoding: String.Encoding.utf8.rawValue)
        //return (ns?.description)!
    }
}

extension Date {
    
    func toString(fmt:String) -> String {
        
        let f:DateFormatter  = DateFormatter()
        f.dateFormat = fmt
        return f.string(from: self)
        //f.date(from: <#T##String#>)
    }
    
    
}



