//
//  GenesysMessenger.swift
//  InAppChat
//
//  Created by HoangDoan on 15/11/2022.
//

import Foundation
import MessengerTransport



@objc(GenesysMessenger)
class GenesysMessenger: RCTEventEmitter {


  
  var config:Configuration? = nil
  var messengerTransport: MobileMessenger? = nil
  public var client: MessagingClient? = nil
  public override init() {
    super.init()
  }
  
    
  @objc func setupGenesis() {
    config = Configuration(deploymentId: "bfddd67f-c7da-406c-a47a-a8a49f2ee346",domain: "mypurecloud.jp", tokenStoreKey: "", logging: true )
    client = MobileMessenger.shared.createMessagingClient(configuration: config!)
   

    client?.stateListener = { stateChange in // Subscribe to socket states listener.
      print("stateChange")
      print(stateChange)
      switch stateChange {
      case is MessagingClientState.Connecting:
        print("MessagingClientState.Connecting")// Establishing a secure connection via WebSocket.
      case is MessagingClientState.Connected:
        print("MessagingClientState.Connected")// Secure connection was established.
        do {
          try self.client!.configureSession()
        } catch {
          ///
        }
      case let configured as MessagingClientState.Configured:
        print(configured.connected)
      default:
        print(stateChange)
        break
      }
    }
    
      
    
    client?.messageListener = { event in
        switch event {
        case let inserted as MessageEvent.MessageInserted:
            if(inserted.message.direction == Message.Direction.outbound) {
              print("Message sent by Agent (Received)")
              
              self.sendEvent(withName: "onMessage", body: ["type": "outbound", "message": inserted.message.text])
                // Message sent by Agent (Received)
            }
          if(inserted.message.direction == Message.Direction.inbound) {
            self.sendEvent(withName: "onMessage", body: ["type": "inbound", "message": inserted.message.text])
          }
        case let history as MessageEvent.HistoryFetched:
          print(history.messages)
        default:
          break
        }
    }
    
    do {

      try client?.connect()
    } catch {
      print("there is an error here")
      // Handle exceptions here.
    }
    
  }
  
  
  @objc func uploadAttachment(_ uint8: [UInt8]) {
    do {
      
      
      let swiftByteArray : [UInt8] = uint8
      let intArray : [Int8] = swiftByteArray
          .map { Int8(bitPattern: $0) }
      let kotlinByteArray: KotlinByteArray = KotlinByteArray.init(size: Int32(swiftByteArray.count))
      for (index, element) in intArray.enumerated() {
          kotlinByteArray.set(index: Int32(index), value: element)
      }
      
      let attachmentId = try self.client?.attach(byteArray: kotlinByteArray, fileName: "filename.jpg")
      
      print(attachmentId)

    } catch {
      print("Errorrrr")
    }
  }
  
  @objc func sendMessage(_ message: String) {
    do {
      try self.client!.sendMessage(text: message)
    } catch {
      ///
    }
  }
  
  override func supportedEvents() -> [String]! {
    return ["onMessage"]
  }
  
  override class func requiresMainQueueSetup() -> Bool {
    true
  }
    
}
