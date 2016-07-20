//
//  Connection.swift
//  sockettool
//
//  Created by Abu on 16/7/20.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Foundation
import SocksCore
import Socks

class Connection: NSObject {
    
    private var _descriptor:Descriptor = 0
    var descriptor: Descriptor {
        get {return _descriptor }
    }
    
    private var _status:SocketStatus
    var status:SocketStatus{
        get {return _status }
    }
    
    private var _socket:TCPInternetSocket
    var socket:TCPInternetSocket{
        get{return _socket}
    }
    
    private var _receive:Int = 0
    var receive:Int {
        get { return _receive}
    }
    
    private var _send:Int = 0
    var send:Int {
        get {return _send }
    }
    
    private var _bytes:[UInt8] = []
    var bytes:[UInt8] {
        get {return _bytes }
        // set {_bytes = newValue }
    }
    
    init(socket:TCPInternetSocket,status:SocketStatus,bytes:[UInt8]){
        _descriptor = socket.descriptor
        _socket = socket
        _status = status
        _bytes = bytes
        _status = status
        switch _status {
        case .new :
            _receive = 0
            _send = 0
        case .send:
            _send = _bytes.count
        case .receive:
            _receive = _bytes.count
        default:
            break
        }
    }
    
    
    func set(status:SocketStatus,bytes:[UInt8]){
        _status = status
        _bytes = bytes
        switch _status {
        case .close:
            break
        case .new:
            break
        case .receive:
            _receive += _bytes.count
        case .send:
            _send += _bytes.count
        default:
            break
        }
    }
    
    override var description: String {
        //return "[\(_status)][\(_socket.address)][\(_bytes.count)] \(_bytes)"
        return "[\(_status)]\(fmtAddr())\(fmtCount()) \(_bytes.toHex().insert(step: 2,ch: Character(" ")))"
    }
    
    func toStringWithByte() -> String {
        return "[\(_status)]\(fmtAddr())\(fmtCount()) \(_bytes)"
    }
    
    private func fmtAddr() -> String {
        if try! _socket.address.addressFamily() == .inet {
            return "[\(_socket.address.ipString()):\(_socket.address.port)]"
        } else {
            return "[\(_socket.address)]"
        }
    }
    
    private func fmtCount() -> String {
        switch _status {
        case .new,.close,.connecting,.startListening:
            return ""
        default:
            return "[\(_bytes.count)]"
        }
    }
    
}

enum SocketStatus {
    case new
    case close
    case receive
    case send
    case startListening
    case connecting
}
