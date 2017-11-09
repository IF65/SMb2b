//
//  TotaleOrdiniCell.swift
//  b2b
//
//  Created by if65 on 27/09/2017.
//  Copyright © 2017 if65. All rights reserved.
//

import UIKit

class TotaleOrdiniCell: UITableViewCell {
    
    @IBOutlet weak var cliente: UILabel!
    @IBOutlet weak var totale: UILabel!
    @IBOutlet weak var ordiniCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cliente.textColor = blueSM
        totale.textColor = blueSM
        ordiniCount.textColor = blueSM
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
}
