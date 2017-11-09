//
//  RigheOrdineCell.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 08/11/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class RigheOrdineCell: UITableViewCell {
    
    @IBOutlet weak var codiceGcc:UILabel?
    @IBOutlet weak var descrizione:UILabel?
    @IBOutlet weak var quantita:UILabel?
    @IBOutlet weak var totale:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        codiceGcc?.textColor = blueSM
        descrizione?.textColor = blueSM
        quantita?.textColor = blueSM
        totale?.textColor = blueSM
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
