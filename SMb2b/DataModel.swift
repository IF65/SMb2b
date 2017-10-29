//
//  DataModel.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import Foundation


// dati
var clienti = [Cliente]()
var periodo = [Date]()
var settimane = [Settimana]()

//var weekDayShort = [0:"Lun",1:"Mar",2:"Mer",3:"Gio",4:"Ven",5:"Sab",6:"Dom"]

enum TipoCalendario {
    case giorno
    case settimana
    /*case mese
    case anno*/
}

class Settimana {
    let numero: Int
    var dataInizio: Date
    var dataFine: Date
    var index: Int = 0
    
    init(Numero numero: Int, Inizio dataInizio:Date, Fine dataFine: Date) {
        self.numero = numero
        self.dataInizio = dataInizio
        self.dataFine = dataFine
    }
}

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
    var codiceCliente = ""
    var totale = 0.0
    var margine = 0.0
    var count = 0
}

class SearchRequest:Codable {
    var funzione = ""
    var dallaData = ""
    var allaData = ""
}

