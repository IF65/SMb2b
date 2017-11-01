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
    private let calendar = Calendar(identifier: .iso8601)
    private let timeZone = TimeZone(identifier: "GMT")
    
    init() {
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
            compareFormatter.timeStyle = .none
            compareFormatter.dateStyle = .short
            
            if compare(Data1: date, Data2: Date()) == 0 {
                selezioneGiorno = self.giorni.count - 1
                selezioneSettimana = self.settimane.count - 1
                selezioneMese = self.mesi.count - 1
            }
            
            //date = date.addingTimeInterval(60*60*24)
            date = calendar.date(byAdding: DateComponents(day: 1), to: date)!
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
    
    // sincronizza le selezioni di Giorno, Settimana e Mese
    func selectItem(Per tipo:TipoCalendario, index:Int) -> Void {
        let searchComponents = calendar.dateComponents([.year, .month, .weekOfYear], from: giorni[index].data)
        
        if tipo == .giorno {
            selezioneGiorno = index
            
            selezioneSettimana = nil
            for index in 0..<settimane.count {
                if settimane[index].anno == searchComponents.year! && settimane[index].numero == searchComponents.weekOfYear! {
                    selezioneSettimana = index
                }
            }
            
            selezioneMese = nil
            for index in 0..<mesi.count {
                if mesi[index].anno == searchComponents.year! && mesi[index].numero == searchComponents.month! {
                    selezioneMese = index
                }
            }
        } else if tipo == .settimana {
            selezioneSettimana = index
            let settimanaSelezionata = getItem(Per: .settimana, index: selezioneSettimana!) as! Settimana
            let settimanaDelGiornoSelezionato = getItem(Per: .settimana, data: giorni[selezioneGiorno!].data) as! Settimana
            
            if  settimanaSelezionata != settimanaDelGiornoSelezionato {
                //selezioneGiorno
            }
        } else {
            selezioneMese = index
        }
    }
    
    // ritorna l'indice della selezione corrente in base al tipo richiesto
    func getSelectedIndex(Per tipo:TipoCalendario) -> Int? {
        if tipo == .giorno {
            return selezioneGiorno
        } else if tipo == .settimana {
            return selezioneSettimana
        } else {
            return selezioneMese
        }
    }
    
    // ritorna l'oggetto della selezione corrente in base al tipo
    func getSelectedItem(Per tipo:TipoCalendario) -> Any? {
        if tipo == .giorno {
            if let selezioneGiorno = selezioneGiorno { return giorni[selezioneGiorno] }
        } else if tipo == .settimana {
            if let selezioneSettimana = selezioneSettimana { return settimane[selezioneSettimana] }
        } else {
            if let selezioneMese = selezioneMese { return mesi[selezioneMese] }
        }
        return nil
    }
    
    // ritorna l'oggetto alla posizione richiesta in base al tipo
    func getItem(Per tipo:TipoCalendario, index:Int) -> Any? {
        if tipo == .giorno {
            if index < giorni.count { return giorni[index] }
        } else if tipo == .settimana {
            if index < settimane.count { return settimane[index] }
        } else {
            if index < mesi.count { return mesi[index] }
        }
        return nil
    }
    
    // ritorna l'oggetto corrispondente alla data richiesta in base al tipo
    func getItem(Per tipo:TipoCalendario, data:Date) -> Any? {
        if tipo == .giorno {
            for index in 0..<giorni.count {
                if compare(Data1: giorni[index].data, Data2: data) == 0 {
                    return giorni[index]
                }
            }
        } else if tipo == .settimana {
            for index in 0..<settimane.count {
                if compare(Data1: settimane[index].dataInizio, Data2: data) <= 0 && compare(Data1: settimane[index].dataFine, Data2: data) >= 0 {
                    return settimane[index]
                }
            }
        } else {
            for index in 0..<mesi.count {
                if compare(Data1: mesi[index].dataInizio, Data2: data) <= 0 && compare(Data1: mesi[index].dataFine, Data2: data) >= 0 {
                    return mesi[index]
                }
            }
        }
        return nil
    }
    
}

class Giorno: Equatable{
    let numero: Int
    let data: Date
    let anno: Int
    
    init(Numero numero: Int, Data data:Date) {
        self.numero = numero
        self.data = data
        self.anno = Calendar.current.component(.year, from: data)
    }
    
    static func == (primo:Giorno, secondo:Giorno)->Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return
            (primo.numero == secondo.numero && primo.anno == secondo.anno) ||
                (compare(Data1:primo.data, Data2:secondo.data) == 0)
    }
}

class Settimana: Equatable{
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
    
    static func == (primo:Settimana, secondo:Settimana)->Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return
            (primo.numero == secondo.numero && primo.anno == secondo.anno) ||
                (compare(Data1:primo.dataInizio, Data2:secondo.dataInizio) == 0 && compare(Data1:primo.dataFine, Data2:secondo.dataFine) == 0)
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

