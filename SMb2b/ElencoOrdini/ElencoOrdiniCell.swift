//
//  ElencoOrdiniCell.swift
//  SMb2b
//
//  Created by if65 on 08/11/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class ElencoOrdiniCell: UITableViewCell {
    
    @IBOutlet weak var riferimento: UILabel!
    @IBOutlet weak var descrizione: UILabel!
    @IBOutlet weak var quantita:UILabel!
    @IBOutlet weak var totale: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        riferimento.textColor = blueSM
        descrizione.textColor = blueSM
        quantita.textColor = blueSM
        totale.textColor = blueSM
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
