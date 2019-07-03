//
//  ChatCell.swift
//  FLEX
//
//  Created by Admin on 6/18/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var mImgViewUser: UIImageView?
    @IBOutlet weak var mLblMsg: UILabel!
    
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if mImgViewUser != nil {
            mImgViewUser?.makeRound(radius: mImgViewUser!.frame.width/2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func fillContent(msg: Message) {
        if let user = msg.sender {
            // user photo
            if let photoUrl = user.photoUrl {
                mImgViewUser?.sd_setImage(with: URL(string: photoUrl),
                                          placeholderImage: UIImage(named: "UserDefault"),
                                          options: .progressiveDownload,
                                          completed: nil)
            }
        }
        
        // text
        
        // get string width
        let str_width =  msg.text.width(withConstrainedHeight: 15.0, font: UIFont.systemFont(ofSize: 15.0))
        if str_width > 270 {
            //multiple line
            let str_height = msg.text.height(withConstrainedWidth: 270.0, font: UIFont.systemFont(ofSize: 15.0))
            bubbleWidthConstraint.constant = 270.0
            buttonHeightConstraint.constant = str_height + 16.0
        } else {
            //single line
            bubbleWidthConstraint.constant = str_width + 36.0
            buttonHeightConstraint.constant = 15.0 + 16.0
        }
        mLblMsg.sizeToFit()
        mLblMsg.text = msg.text
    }
    
}
