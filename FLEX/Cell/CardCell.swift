//
//  CardCell.swift
//  FLEX
//
//  Created by rlogical-dev-11 on 24/06/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imgCard: UIImageView!
    
    
    @IBOutlet weak var lblCardValidity: UILabel!
    @IBOutlet weak var lblCardNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //Set containerView drop shadow
        
            containerView.layer.borderWidth = 1.0
            containerView.layer.borderColor = UIColor.white.cgColor
            containerView.layer.shadowColor = UIColor.lightGray.cgColor
            containerView.layer.shadowRadius = 4.0
            containerView.layer.shadowOpacity = 0.3
            containerView.layer.shadowOffset = CGSize(width:4.0, height: 4.0)
            containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
        }
    
    
}
