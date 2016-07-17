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
    func action(addr:ResolvedInternetAddress,status:socketStatus)
    func receive(addr:ResolvedInternetAddress,b :[UInt8])
    
}

enum socketStatus {
    case  newConnection
    case closed
    case reading
    case writing
}

class MySocket :NSObject{
    
    var exit:Bool = false
    var th:Thread? = nil
    var isWorking:Bool = false
    var thisSocket:TCPInternetSocket? = nil
    var socketList:[Descriptor:TCPInternetSocket] = [:]
    
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
            NSLog("try to colse \(s.value) ")
            
            try! s.value.close()
            socketDelegate?.action(addr:  s.value.address, status: socketStatus.closed)
        }
        
        try! thisSocket?.close()
        socketDelegate?.action(addr: (thisSocket?.address)!, status: socketStatus.closed)
        
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
    
    
    func send(socket: TCPInternetSocket ,b: [UInt8]){
        do {
            try socket.send(data: b)
        }catch {
            NSLog("error \(error)")
        }
        
    }
    
    
    func handleMessage(client: TCPInternetSocket) throws -> HandleResult {
        let b:[UInt8] = try client.recvAll()
        NSLog("received \(client.address) length=\(b.count)")
        socketDelegate?.receive(addr: client.address, b: b)
        return .keepAlive
    }
    
    
    func closeSocket(addr:ResolvedInternetAddress) throws {
        NSLog("close \(addr)")
        
        let k = Descriptor(addr.description)!
        
        guard socketList.keys.contains(k) else { return }
        
        try socketList[k]?.close()
        
        socketList.removeValue(forKey:  k)
        
        socketDelegate?.action(addr: addr, status:socketStatus.closed)
        
    }
    
    
    func startServer(arg: AnyObject){
        
        do {
            
            let address =   InternetAddress(hostname: GParas.IP!, port: (UInt16)(GParas.port),addressFamily: AddressFamily.inet)
            //   let address = InternetAddress.any(port: 8080)
            let  server = try TCPInternetSocket(address: address)
            thisSocket = server
            
            try server.bind()
            try server.listen()
            
            print("\(server.descriptor) Listening on \( server.address ) ")
            
            
            while true {
                
                guard !exit else { break }
                
                //Wait for data on either the server socket and connected clients
                let watchedReads = Array(socketList.keys) + [server.descriptor]
                
                let (reads, writes, errors) = try select(reads: watchedReads, errors: watchedReads  )
                
                NSLog("total connection = \(socketList.count) ")
                
                //first handle any existing connections
                try reads.filter { $0 != server.descriptor }.forEach {
                    
                    let client = socketList[$0]!
                    do {
                        let result = try handleMessage(client: client)
                        switch result {
                        case .close:
                            try closeSocket(addr:  client.address)
                        case .keepAlive:
                            break
                        }
                    } catch {
                        print("Error: \(error)")
                        try closeSocket(addr:  client.address)
                    }
                }
                
                
                //then only continue if there's data on the server listening socket
                guard Set(reads).contains(server.descriptor) else { continue }
                
                let socket = try server.accept()
                socket.keepAlive = true
                guard socketList[socket.descriptor] == nil else {
                    throw MyError.descriptorReuse
                }
                socketList[socket.descriptor] = socket
                NSLog("New connection \(socket.address)")
                socketDelegate?.action(addr:  socket.address, status: socketStatus.newConnection)
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
