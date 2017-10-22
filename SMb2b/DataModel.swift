//
//  DataModel.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import Foundation


var weekDayShort = [0:"Lun",1:"Mar",2:"Mer",3:"Gio",4:"Ven",5:"Sab",6:"Dom"]


class Cliente {
    var codice: String
    var descrizione: String
    
    init(codice:String, descrizione:String) {
        self.codice = codice
        self.descrizione = descrizione
    }
}

