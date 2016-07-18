//
//  MySocket.swift
//  sockettool
//
//  Created by Abu on 16/7/9.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Foundation
import Socks
import SocksCore

protocol SocketDelegate {
    func action(conn:Connection)
    
}

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
        return "[\(_status)][\(_bytes.count)][\(_socket.address)] \(_bytes)"
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

class MySocket :NSObject{
    
    var exit:Bool = false
    var th:Thread? = nil
    var isWorking:Bool = false
    var thisSocket:TCPInternetSocket? = nil
    var socketList:[Descriptor:Connection] = [:]
    
    var socketDelegate:SocketDelegate?
    
    override init() {
    }
    
    
    func start2Work()   {
        guard !isWorking else {return}
        
        exit = false
        if GParas.isClientMode {
            NSLog("client mode")
        }else {
            NSLog("server mode")
            th = Thread(target: self, selector: #selector(MySocket.startServer  ), object: nil)
            th!.start()
        }
        
        isWorking = true
    }
    
    func stopWorking(){
        exit = true
        
        for (d:s) in socketList {
            try! s.value.socket.close()
            s.value.set(status: .close, bytes: [])
            
            NSLog("-> \(s.value)")
            
            socketDelegate?.action(conn: s.value)
        }
        
        try! thisSocket?.close()
        
        if th != nil {
            th?.cancel()
        }
        
        isWorking = false
        
    }
    
    
    enum MyError: ErrorProtocol {
        case descriptorReuse
    }
    
    enum HandleResult {
        case keepAlive
        case close
    }
    
    
    
    func send(descriptor : Descriptor ,b: [UInt8]){
        
        guard socketList.keys.contains(descriptor) else {return }
        
        do {
            let cnn = socketList[descriptor]!
            cnn.set(status: .send, bytes: b)
            
            NSLog("-> \(cnn)")
            
            try cnn.socket.send(data: b)
        }catch {
            NSLog("error \(error)")
        }
        
    }
    
    
    func handleMessage(client: TCPInternetSocket) throws -> HandleResult {
        
        let b = try client.recvAll()
        
        guard b.count > 0 else {return .close }
        
        let cnn = socketList[client.descriptor]!
        cnn.set(status: .receive, bytes:b)
        
        NSLog("-> \(cnn)")
        
        socketDelegate?.action(conn: cnn)
        
        return .keepAlive
    }
    
    
    func closeSocket(descriptor:Descriptor) throws {
        
        guard  socketList.keys.contains(descriptor) else { return }
        
        let cnn = socketList.removeValue(forKey: descriptor)
        
        if cnn != nil {
            try cnn?.socket.close()
            cnn?.set(status: .close, bytes: [])
            NSLog("-> \(cnn)")
            socketDelegate?.action(conn: cnn!)
        }
        
    }
    
    
    func startServer(arg: AnyObject){
        
        do {
            
            let address =   InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),addressFamily: AddressFamily.inet)
            //   let address = InternetAddress.any(port: 8080)
            let  server = try TCPInternetSocket(address: address)
            thisSocket = server
            
            try server.bind()
            try server.listen()
            
            socketDelegate?.action(conn: Connection(socket: server, status: .startListening, bytes: []))
            
            NSLog("Socket(\(server.descriptor)) listening on \( server.address ) ")
            
            while true {
                
                guard !exit else { break }
                
                //Wait for data on either the server socket and connected clients
                let watchedReads = Array(socketList.keys) + [server.descriptor]
                
                let (reads, writes, errors) = try select(reads: watchedReads, errors: watchedReads  )
                
                //first handle any existing connections
                try reads.filter { $0 != server.descriptor }.forEach {
                    
                    let client = socketList[$0]!
                    do {
                        let result = try handleMessage(client: client.socket)
                        switch result {
                        case .close:
                            try closeSocket(descriptor: client.descriptor)
                        case .keepAlive:
                            break
                        }
                    } catch {
                        print("Error: \(error)")
                        try closeSocket(descriptor: client.descriptor)
                    }
                }
                
                //then only continue if there's data on the server listening socket
                guard Set(reads).contains(server.descriptor) else { continue }
                
                let socket = try server.accept()
                socket.keepAlive = true
                guard socketList[socket.descriptor] == nil else {
                    throw MyError.descriptorReuse
                }
                let c = Connection( socket: socket, status: .new,bytes: [])
                socketList[socket.descriptor] = c
                NSLog("--> \(c)")
                socketDelegate?.action(conn: c)
                NSLog("total connection = \(socketList.count) ")
                //try socket.send(data: "hello".toBytes() )
            }
            
            NSLog("loop break, try to close server sockets")
            try server.close()
            
        } catch {
            exit = true
            print("catch Error \(error) <-----")
        }
        NSLog(" end of method")
    }
    
    
}
