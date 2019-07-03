//
//  FirebaseManager.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    static var serverOffset = 0.0
    static let mAuth = Auth.auth()
    
    static func ref() -> DatabaseReference {
        return Database.database().reference()
    }
    
    static func sref() -> StorageReference {
        let storageURL = FirebaseApp.app()?.options.storageBucket
        return Storage.storage().reference(forURL: "gs://" + storageURL!)
    }
    
    static func initServerTime() {
        let serverTimeQuery = FirebaseManager.ref().child(".info/serverTimeOffset")
        serverTimeQuery.observeSingleEvent(of: .value) { (snapshot) in
            FirebaseManager.serverOffset = snapshot.value as? Double ?? 0
        }
    }
    
    static func uploadImageTo(path: String, image: UIImage!, completionHandler: @escaping (_ downloadURL: String?, _ error: Error?) -> ()) {
        let data = image.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        FirebaseManager.sref().child(path).putData(data!, metadata: metaData) { (metadata, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            if let path = metadata?.path {
                let gsPath = sref().child(path).description
                let gsRef = Storage.storage().reference(forURL: gsPath)
                gsRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else {
                        completionHandler(url!.absoluteString, nil)
                    }
                })
            }
        }
    }
    
    static func getServerLongTime() -> Int64 {
        let estimatedServerTimeMs = NSDate().timeIntervalSince1970 * 1000 + serverOffset
        return Int64(estimatedServerTimeMs)
    }
    
    static func signOut() {
        do {
            try FirebaseManager.mAuth.signOut()
        } catch{}
    }
}
