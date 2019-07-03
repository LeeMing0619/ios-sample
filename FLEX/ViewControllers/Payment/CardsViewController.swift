//
//  CardsViewController.swift
//  FLEX
//
//  Created by rlogical-dev-11 on 24/06/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController {

    @IBOutlet weak var tblCard: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addPayment(_ sender: Any) {
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CardsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
        IndexPath) {
        
    }
}
extension CardsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            
        cell.lblCardNumber.text = "•••• •••• ••• 1234"
        cell.lblCardValidity.text = "Due date April 15th of 2021"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
