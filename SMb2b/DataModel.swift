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
var periodo =  ElencoDate()

enum TipoCalendario {
    case giorno
    case settimana
    case mese
    //case anno
}

func compare(Data1 date1:Date, Data2 date2:Date) -> Int {
    let compareFormatter = DateFormatter()
    compareFormatter.dateFormat = "yyyy-MM-dd"
    
    if compareFormatter.string(from: date1) == compareFormatter.string(from: date2) {
        return 0
    } else if compareFormatter.string(from: date1) < compareFormatter.string(from: date2) {
        return -1
    } else {
        return 1
    }
}

class ElencoDate {
    var selezioneGiorno: Int?
    var selezioneMese: Int?
    var selezioneSettimana: Int?
    
    var giorni = [Giorno]()
    var settimane = [Settimana]()
    var mesi = [Mese]()
    let anni = [Anno]()
    
    private let dataIniziale: Date
    private let dataFinale: Date

    init() {
        let calendar = Calendar(identifier: .iso8601)
        let timeZone = TimeZone(identifier: "GMT")
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = timeZone
        
        // data iniziale
        dateComponents.year = calendar.component(.year, from: Date()) - 1
        dateComponents.month = 1 //currentDateCommponents.month!
        dateComponents.day = 1
        self.dataIniziale = calendar.date(from: dateComponents)!
        
        // data finale
        dateComponents.year = calendar.component(.year, from: Date())
        dateComponents.month = 12 //currentDateCommponents.month!
        dateComponents.day = 31
        self.dataFinale = calendar.date(from: dateComponents)!
        
        let dateRange = self.dataIniziale ... self.dataFinale
        
        var date = self.dataIniziale
        while (dateRange.contains(date)) {
            // giorni
            giorni.append(Giorno(Numero: calendar.ordinality(of: .day, in: .year, for: date)!, Data: date))
            
            //date = date.addingTimeInterval(60*60*24)
            
            // settimane
            if calendar.component(.weekday, from: date) == 1 { // 1 = Sunday
                let inizioSettimana = date.addingTimeInterval(-60*60*24*6)
                
                var numeroSettimana = calendar.ordinality(of: .weekOfYear, in: .year, for: date)!
                if numeroSettimana == 0 {
                    numeroSettimana = calendar.ordinality(of: .weekOfYear, in: .year, for: calendar.date(byAdding: DateComponents(day: -1), to: inizioSettimana)!)! + 1
                }
                
                let settimana = Settimana(Numero: numeroSettimana, Inizio: inizioSettimana, Fine: date)
                settimane.append(settimana)
            }
            
            // mesi
            if calendar.component(.day, from: date) == 1 {
                let inizioMese = date
                
                let fineMese = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inizioMese)!
                
                let mese = Mese(Numero: calendar.component(.month, from: inizioMese), Inizio: inizioMese, Fine: fineMese)
                mesi.append(mese)
            }
            
            let compareFormatter = DateFormatter()
            compareFormatter.timeStyle = DateFormatter.Style.none
            compareFormatter.dateStyle = DateFormatter.Style.short
            
            if compare(Data1: date, Data2: Date()) == 0 {
                selezioneGiorno = self.giorni.count - 1
                selezioneSettimana = self.settimane.count - 1
                selezioneMese = self.mesi.count - 1
            }
            
            date = date.addingTimeInterval(60*60*24)
            //date = calendar.date(byAdding: DateComponents(day: 1), to: date)!
        }
    }
    
    func count(Per tipo:TipoCalendario) -> Int {
        if tipo == .giorno {
            return giorni.count
        } else if tipo == .settimana {
            return settimane.count
        } else {
            return mesi.count
        }
    }
    
    func selectItem(Per tipo:TipoCalendario, index:Int) -> Void {
        if tipo == .giorno {
            selezioneGiorno = index
        } else if tipo == .settimana {
            selezioneSettimana = index
        } else {
            selezioneMese = index
        }
    }
    
    func getSelectedIndex(Per tipo:TipoCalendario) -> Int? {
        if tipo == .giorno {
            return selezioneGiorno
        } else if tipo == .settimana {
            return selezioneSettimana
        } else {
            return selezioneMese
        }
    }
    
    func getSelectedItem(Per tipo:TipoCalendario) -> Any? {
        if tipo == .giorno {
            if let selezioneGiorno = selezioneGiorno {
                return giorni[selezioneGiorno]
            }
            return nil
        } else if tipo == .settimana {
            if let selezioneSettimana = selezioneSettimana {
                return settimane[selezioneSettimana]
            }
            return nil
        } else {
            if let selezioneMese = selezioneMese {
                return settimane[selezioneMese]
            }
            return nil
        }
    }
    
    func getItem(Per tipo:TipoCalendario, index:Int) -> Any? {
        if tipo == .giorno {
            return giorni[index]
        } else if tipo == .settimana {
            return settimane[index]
        } else {
            return mesi[index]
        }
    }
}

class Giorno{
    let numero: Int
    let data: Date
    
    init(Numero numero: Int, Data data:Date) {
        self.numero = numero
        self.data = data
    }
}

class Settimana {
    let numero: Int
    var dataInizio: Date
    var dataFine: Date
    var anno: Int
    
    init(Numero numero: Int, Inizio dataInizio:Date, Fine dataFine:Date) {
        self.numero = numero
        self.dataInizio = dataInizio
        self.dataFine = dataFine
        self.anno = Calendar.current.component(.year, from: dataInizio)
    }
}

class Mese {
    let numero: Int
    var dataInizio: Date
    var dataFine: Date
    var anno: Int
    
    init(Numero numero: Int, Inizio dataInizio:Date, Fine dataFine: Date) {
        self.numero = numero
        self.dataInizio = dataInizio
        self.dataFine = dataFine
        self.anno = Calendar.current.component(.year, from: dataInizio)
    }
}

class Anno {
    let numero: Int
    var dataInizio: Date
    var dataFine: Date
    
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

