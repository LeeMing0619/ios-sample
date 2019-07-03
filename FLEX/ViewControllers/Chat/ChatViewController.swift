//
//  ChatViewController.swift
//  FLEX
//
//  Created by Admin on 6/18/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: BaseViewController {

    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mTextMessage: UITextField!
    @IBOutlet weak var mViewInput: UIView!
    
    var messages: [Message] = []
    var userTo: User?
    var userToId: String?
    
    var mKeyboardHeight: CGFloat = 0.0
    var mDbRef: DatabaseReference?
    
    private let CELLID_CHAT_TO = "ChatToCell"
    private let CELLID_CHAT_FROM = "ChatFromCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init tableview
        mTableView.register(UINib(nibName: "ChatItemViewTo", bundle: nil), forCellReuseIdentifier: CELLID_CHAT_TO)
        mTableView.register(UINib(nibName: "ChatItemViewFrom", bundle: nil), forCellReuseIdentifier: CELLID_CHAT_FROM)
        
        mTableView.rowHeight = UITableView.automaticDimension + 50
        mTableView.estimatedRowHeight = 600
        
        // keyboard avoiding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //
        // init data
        //
        //        mChatId = Chat.makeIdWith2User(self.userTo!.id, User.currentUser!.id)
        
        // fetchChat()
        if self.userTo == nil {
            // fetch user from id
            if let userId = self.userToId {
                User.readFromDatabase(withId: userId) { (user) in
                    if user == nil {
                        return
                    }
                    self.userTo = user
                    self.initView()
                }
            }
        } else {
            self.initView()
        }
        
        
    }
    
    func initView() {
        // title
//        self.title = self.userTo?.userFullName()
        getMessages()
    }
    
    deinit {
        mDbRef?.removeAllObservers()
    }
    
    //MARK: - Button Actions
    @IBAction func onButSend(_ sender: Any) {
        self.view.endEditing(true)
        
        // send
        let text = mTextMessage.text!
        if text.isEmpty {
            return
        }
        
        //
        // update chat info
        //
        let userCurrent = User.currentUser!
        //        if mChat == nil {
        //            mChat = Chat()
        //        }
        //        mChat?.senderId = userCurrent.id
        //        mChat?.text = text
        //
        //        mChat?.saveToDatabaseManually(withID: mChatId, parentID: userCurrent.id)
        //        mChat?.saveToDatabaseManually(withID: mChatId, parentID: self.userTo?.id)
        
        //
        // add new mesage
        //
        let msgNew = Message()
        msgNew.senderId = userCurrent.id
        msgNew.sender = userCurrent
        msgNew.text = text
        
        msgNew.saveToDatabase(parentID: userCurrent.id + "/" + self.userTo!.id)
        msgNew.saveToDatabase(parentID: self.userTo!.id + "/" + userCurrent.id)
        
        self.messages.append(msgNew)
        
        // clear textfield
        self.mTextMessage.text = ""
        
        // update table
        updateTable()
        
        // send notification to user
        Message.sendPushNotification(sender:userCurrent,
                                     receiver: self.userTo!,
                                     message: text,
                                     title: userCurrent.userFullName())
    }
    @IBAction func onButPhone(_ sender: Any) {
        // phone call to driver
        if Utils.isStringNullOrEmpty(text: self.userTo?.phone) {
            // no contact, error notice
            self.alertOk(title: "No contact info",
                         message: "User didn't register a phone number",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        
        guard let number = URL(string: "tel://" + (self.userTo?.phone)!) else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func onButBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if self.mTableView.contentSize.height > self.mTableView.frame.size.height {
                let bottomOffset = CGPoint(x: 0,
                                           y: self.mTableView.contentSize.height - self.mTableView.frame.size.height)
                self.mTableView.setContentOffset(bottomOffset, animated: animated)
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification?) -> CGFloat {
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        return keyboardHeight
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        if mKeyboardHeight > 0 {
            // already showing keyboard, return
            return
        }
        
        var frmView = self.view.frame
        mKeyboardHeight = getKeyboardHeight(notification: notification)
        frmView.size = CGSize(width: frmView.width, height: frmView.height - mKeyboardHeight)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.view.frame = frmView
        }) { (finished) in
            self.tableViewScrollToBottom(animated: false)
        }
    }
    
    func keyboardWillDisappear() {
        var frmView = self.view.frame
        frmView.size = CGSize(width: frmView.width, height: frmView.height + mKeyboardHeight)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.view.frame = frmView
        })
        
        mKeyboardHeight = 0
    }
    
    //    func fetchChat() {
    //        let userCurrent = User.currentUser!
    //
    //        if mChat != nil {
    //            // already fetched, return
    //            return
    //        }
    //
    //        // fetch chat room
    //        let db = FirebaseManager.ref()
    //            .child(Chat.TABLE_NAME)
    //            .child(userCurrent.id)
    //            .child(self.userTo!.id)
    //        db.observeSingleEvent(of: .value) { (snapshot) in
    //            if !snapshot.exists() {
    //                return
    //            }
    //
    //            self.mChat = Chat(snapshot: snapshot)
    //        }
    //    }
    
    func getMessages() {
        let userCurrent = User.currentUser!
        
        self.messages.removeAll()
        
        //        mDbRef = FirebaseManager.ref()
        //            .child(Chat.TABLE_NAME)
        //            .child(userCurrent.id)
        //            .child(mChatId)
        //            .child(Message.TABLE_NAME)
        mDbRef = FirebaseManager.ref()
            .child(Message.TABLE_NAME)
            .child(userCurrent.id)
            .child(self.userTo!.id)
        
        mDbRef?.observe(.childAdded, with: { (snapshot) in
            let msg = Message(snapshot: snapshot)
            msg.id = snapshot.key
            
            // set user
            msg.sender = msg.senderId == userCurrent.id ? userCurrent : self.userTo
            
            var isExist = false
            for aMsg in self.messages {
                if aMsg.isEqual(to: msg) {
                    isExist = true
                    break
                }
            }
            
            if !isExist {
                DispatchQueue.main.async {
                    self.messages.append(msg)
                    
                    self.updateTable()
                }
            }
        })
    }
    
    func updateTable(animated: Bool = false) {
        if animated {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            mTableView.insertRows(at: [indexPath], with: .automatic)
        }
        else {
            mTableView.reloadData()
        }
        
        self.tableViewScrollToBottom(animated: false)
    }

}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCurrent = User.currentUser!
        let msg = messages[indexPath.row]
        var strCellId = CELLID_CHAT_FROM
        if msg.senderId == userCurrent.id {
            strCellId = CELLID_CHAT_TO
        }
        let cellItem = tableView.dequeueReusableCell(withIdentifier: strCellId) as! ChatCell
        cellItem.backgroundColor = .clear
        cellItem.fillContent(msg: msg)
        // user tap event
        //        cellItem.mButUser.tag = indexPath.row
        //        cellItem.mButUser.addTarget(self, action: #selector(onButUser), for: .touchUpInside)
        
        return cellItem
    }
    
}

extension ChatViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(UITableView.automaticDimension)
        let msg = messages[indexPath.row]
        let str_width =  msg.text.width(withConstrainedHeight: 15.0, font: UIFont.systemFont(ofSize: 15.0))
        if str_width > 270 {
            //multiple line
            let str_height = msg.text.height(withConstrainedWidth: 270.0, font: UIFont.systemFont(ofSize: 15.0))
            return str_height + 16.0 + 8.0
        } else {
            //single line
            return 15.0 + 16.0 + 8.0
        }
    }
}

extension ChatViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onButSend(mTextMessage)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        keyboardWillDisappear()
        return true
    }
}


