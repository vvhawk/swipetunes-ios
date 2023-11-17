//
//  SwipeLogTableViewCell.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/16/23.
//

import UIKit



class SwipeLogTableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var songLabel: UILabel!
    
    let lilac = UIColor(hex: "9BB6FB")
    let mint = UIColor(hex: "5ECDA4")
    let blush = UIColor(hex: "FB9B9B")
    let egg = UIColor(hex: "FFF8D6")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
   


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if selected {
            self.layer.borderColor = egg.cgColor // Lilac color
                } else {
                    self.layer.borderColor = UIColor.clear.cgColor
                }
    }
    
    

}
