//
//  BaseModel.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import Firebase

class BaseModel {
    static let FIELD_DATE = "createdAt"
    
    var id = ""
    var createdAt: Int64 = FirebaseManager.getServerLongTime()
    
    init() {}
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        let info = snapshot.value! as! [String: Any?]
        if let createdAt = info[BaseModel.FIELD_DATE] {
            self.createdAt = createdAt as! Int64
        }
    }
    
    func tableName() -> String {
        return "base"
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict[BaseModel.FIELD_DATE] = createdAt
        return dict
    }
    
    func getDatabaseRef(withID: String? = nil, parentID: String? = nil) -> DatabaseReference {
        var strDb = tableName()
        if let parent = parentID {
            strDb += "/" + parent
        }
        let database = FirebaseManager.ref().child(strDb)
        if let strId = withID, !strId.isEmpty {
            return database.child(strId)
        }
        if self.id.isEmpty {
            self.id = database.childByAutoId().key!
        }
        return database.child(self.id)
    }
    
    func saveToDatabaseRaw(path: String) {
        let database = FirebaseManager.ref().child(path)
        database.setValue(self.toDictionary())
    }
    
    func saveToDatabase(withID: String? = nil, parentID: String? = nil) {
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        db.setValue(self.toDictionary())
    }
    
    func saveToDatabase(withField: String?, value: Any, withID: String? = nil, parentID: String? = nil, completion: @escaping (_ error: Error?, _ dbRef: DatabaseReference) -> () = {_,_ in}) {
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        db.child(withField!).setValue(value, withCompletionBlock: completion)
    }
    
    func saveToDatabaseManually(withID: String? = nil, parentID: String? = nil) {
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        db.child(BaseModel.FIELD_DATE).setValue(self.createdAt)
    }
    
    func isExistInDb(completion: @escaping((DataSnapshot?) -> ())) {
        let query = getDatabaseRef()
        query.observeSingleEvent(of: .value, with: completion)
    }
    
    func isEqual(to: BaseModel) -> Bool {
        return id == to.id
    }
    
    func copyData(with: BaseModel) {
        id = with.id
        createdAt = with.createdAt
    }
}
