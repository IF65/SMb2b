//
//  CalendarMonthCell.swift
//  SMb2b
//
//  Created by if65 on 30/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class CalendarMonthCell: UICollectionViewCell {
    
    @IBOutlet weak var etichettaAnno: UILabel!
    @IBOutlet weak var etichettaMese: UILabel!
    @IBOutlet weak var boxInterno: UIView!
    @IBOutlet weak var boxInternoTopBar: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.boxInterno.layer.cornerRadius = 4.0
        self.boxInterno.layer.borderColor = UIColor.lightGray.cgColor
        self.boxInterno.layer.borderWidth = 0.5
        self.boxInterno.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        /*self.boxInterno.layer.shadowColor = UIColor.lightGray.cgColor
        self.boxInterno.layer.shadowOpacity = 1
        self.boxInterno.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.boxInterno.layer.shadowRadius = 2*/
        
        self.boxInterno.layer.backgroundColor = UIColor.white.cgColor
        
        self.boxInternoTopBar.layer.cornerRadius = 4.0
        self.boxInternoTopBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.etichettaMese.textColor = blueSM
        
        self.etichettaAnno.textColor = UIColor.white
    }
}
