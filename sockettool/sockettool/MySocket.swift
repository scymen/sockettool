//
//  MySocket.swift
//  sockettool
//
//  Created by Abu on 16/7/9.
//  Copyright © 2016年 sockettool. All rights reserved.
//

import Foundation
import SocksCore
import Socks


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
        if Paras.isClientMode {
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
            var address = InternetAddress.any(port: 8080)
            if Paras.IP != "0.0.0.0" {
                  address =   InternetAddress(hostname: Paras.IP!, port: (UInt16)(Paras.port),addressFamily: AddressFamily.inet)
            }
           
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
