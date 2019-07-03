//
//  Message.swift
//  FLEX
//
//  Created by Admin on 6/18/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

class Message: BaseModel {
    
    //
    // notification fields
    //
    static let PN_FIELD_USER_ID = "senderId"
    
    //
    // table info
    //
    static let TABLE_NAME = "messages"
    static let FIELD_SENDER_ID = "senderId"
    static let FIELD_TEXT = "text"
    
    var text: String = ""
    var senderId: String = ""
    var sender: User?
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init()
        let info = snapshot.value! as! [String: Any?]
        if let senderId = info[Message.FIELD_SENDER_ID] as? String {
            self.senderId = senderId
        }
        if let text = info[Message.FIELD_TEXT] as? String {
            self.text = text
        }
    }
    
    override func tableName() -> String {
        return Message.TABLE_NAME
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        dict[Message.FIELD_SENDER_ID] = self.senderId
        dict[Message.FIELD_TEXT] = text
        return dict
    }
    
    /// send push notification to specific user
    static func sendPushNotification(sender: User,
                                     receiver: User,
                                     message: String = "",
                                     title: String = "") {
        let url = "https://fcm.googleapis.com/fcm/send"
        
        if let deviceToken = receiver.token {
            let headers: HTTPHeaders = [
                "Authorization": "key=\(Config.fcmAuthKey)",
                "Content-Type": "application/json"
            ]
            let parameters : Parameters = [
                "notification" : [
                    "title": title,
                    "body" : message,
                    "sound" : "default"
                ],
                "data": [
                    PN_FIELD_USER_ID: sender.id
                ],
                "to":deviceToken
            ]
            print(headers)
            print(parameters)
            Alamofire.request(url,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let val):
                        print(val)
                    case .failure(let val):
                        print(val)
                    }
                })
            
        }
    }
}
