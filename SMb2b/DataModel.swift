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

class ResultArray:Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult:Codable {
    var idTime = ""
    var codice = ""
    var modello = ""
    var descrizione = ""
    var giacenza = 0
    var inOrdine = 0
    var prezzoAcquisto = 0.0
    var prezzoRiordino = 0.0
    var prezzoVendita = 0.0
    var aliquotaIva = 0.0
    var novita = false
    var eliminato = false
    var esclusiva = false
    var barcode = ""
    var marchioCopre = ""
    var griglia = ""
    var grigliaObbligatorio = ""
    var ediel01 = ""
    var ediel02 = ""
    var ediel03 = ""
    var ediel04 = ""
    var marchio = ""
    var ricaricoPercentuale = 0.0
    var doppioNetto = 0.0
    var triploNetto = 0.0
    var nettoNetto = 0.0
    var ordinabile = false
    var canale = 0
    var pndAC = 0.0
    var pndAP = 0.0
}

class SearchRequestTabulatoCopre:Codable {
    var functionName = ""
    var ediel01 = ""
    var ediel02 = ""
    var ediel03 = ""
    var ediel04 = ""
    var marchio = ""
    var descrizione = ""
    var modello = ""
    var barcode = ""
    var ordinabile = true
    var codiceArticolo = ""
    
}

