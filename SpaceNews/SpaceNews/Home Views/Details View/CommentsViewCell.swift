//
//  CommentsViewCell.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 26/01/2022.
//

import Foundation

import UIKit
import SafariServices
import Firebase

class CommentsViewCell: UITableViewCell {
    

    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var commentUserName: UILabel!
    @IBOutlet weak var commentBody: UILabel!
    
    
    override func awakeFromNib() {
        

            
        super.awakeFromNib()
    }
    
}
