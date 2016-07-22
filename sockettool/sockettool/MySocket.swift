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
            th = Thread(target: self, selector: #selector(MySocket.startClient), object: nil)
            th!.start()
        } else {
            th = Thread(target: self, selector: #selector(MySocket.startServer), object: nil)
            th!.start()
        }
        
    }
    
    func stopWorking(){
        exit = true
        isWorking = false
        socketDelegate?.setButtonEnable(id: "btnOK", enable: true)
        if th != nil {
            th?.cancel()
        }
        for (d:s) in socketList {
            do {
                try s.value.socket.close()
                s.value.set(status: .close, bytes: [])
                NSLog("-> \(s.value)")
                socketDelegate?.action(conn: s.value)
            } catch {
                print("\(error)")
            }
        }
        
        do {
            if thisSocket != nil {
                socketDelegate?.action(conn: Connection(socket: thisSocket!, status: .close, bytes: []))
                try thisSocket?.close()
            }
        }catch {
            NSLog("\(error)" )
            socketDelegate?.action(msg: "\(error)")
        }
        
    }
    
    
    enum MyError: ErrorProtocol {
        case descriptorReuse
    }
    
    enum HandleResult {
        case keepAlive
        case close
    }
    
    
    func send(b: [UInt8]){
        
        guard thisSocket != nil else { return }
        
        send(descriptor: (thisSocket?.descriptor)!,b: b)
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
            socketDelegate?.action(msg:"\(error)" )
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
    
    
    func startClient(arg:AnyObject ) {
        do{
            let client = try TCPInternetSocket(address: Paras.addr!)
            try  client.connect(withTimeout: 3)
            thisSocket = client
            let c = Connection( socket: client, status:.connecting,bytes: [])
            socketList[client.descriptor] = c
            NSLog("--> \(c) OK ")
            isWorking = true
            socketDelegate?.action(conn: c)
            socketDelegate?.setButtonEnable(id: "btnOK", enable: false)
            let time = timeval(tv_sec: 0, tv_usec: 500)
            while !exit {
                
                let flag = try client.waitForReadableData(timeout: time)
                //print("client loop have readable bytes \(flag) client close =\(client.closed)")
                if flag {
                    let b = try client.recvAll()
                    if b.count <= 0 {
                        // it seems that socket is closed
                        stopWorking()
                        exit = true
                    } else {
                        c.set(status: SocketStatus.receive, bytes:b)
                        socketDelegate?.action(conn: c)
                    }
                }
                
            }
        }catch {
            exit = true
            NSLog("\(error)")
            socketDelegate?.action(msg: "\(error)")
            socketDelegate?.setButtonEnable(id: "btnOK", enable: true)
        }
    }
    
    func startServer(arg: AnyObject){
        
        do {
            let address = Paras.addr!
            let  server = try TCPInternetSocket(address: address)
            thisSocket = server
            
            NSLog("Start \(Paras.isClientMode ? "client":"server" ) mode")
            
            if Paras.isClientMode {
                try server.connect(withTimeout: 3)
                let c = Connection( socket: server, status:.connecting,bytes: [])
                socketList[server.descriptor] = c
                socketDelegate?.action(conn: Connection(socket: server, status: .connecting, bytes: []))
                NSLog("Socket(\(server.descriptor)) connect to \( server.address ) ")
                
            } else {
                try server.bind()
                try server.listen()
                socketDelegate?.action(conn: Connection(socket: server, status: .startListening, bytes: []))
                NSLog("Socket(\(server.descriptor)) listening on \( server.address ) ")
            }
            
            socketDelegate?.setButtonEnable(id: "btnOK", enable: false)
            
            isWorking = true
            
            while true {
                
                guard !exit else { break }
                
                //Wait for data on either the server socket and connected clients
                let watchedReads = Array(socketList.keys) + [server.descriptor]
                
                let (reads, writes, errors) = try select(reads: watchedReads, errors: watchedReads  )
                
                print("shiiiiit")
                
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
            socketDelegate?.setButtonEnable(id: "btnOK", enable: true)
            print("catch Error \(error) <-----")
        }
        NSLog(" end of method")
    }
    
    
}
