//
//  DataModel.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import Foundation
import UIKit

// parametri
public let itmUrl: String = "http://10.11.14.78/copre/copre2.php"
public let smUrl: String = "http://11.0.1.31:8080/b2b"

public let alphaSM: CGFloat = 1.0

public let blueSM = UIColor(red: 0.0, green: 85/255, blue: 145/255, alpha: 1)
public let purpleSM = UIColor(red: 246/255, green: 21/255, blue: 147/255, alpha: 1)
public let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
public let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)

// dati
var clienti = [Cliente]()
var periodo =  ElencoDate()
var slideMenu = [MenuElement]()

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

func stringToDate(_ dateString:String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Current time zone
    
    guard let returnDate = dateFormatter.date(from: dateString) else {return nil}
    
    return returnDate
}

func dateToString(_ date:Date?, _ format: String?) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat =  "yyyy-MM-dd"
    if let format = format {
        dateFormatter.dateFormat = format
    }
    
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Current time zone
    if let date = date {
        return dateFormatter.string(from:  date)
    }
    
    return ""
}

class MenuElement {
    let id: Int
    let descrizione: String
    var image: UIImage?
    
    init(Id id: Int, Descrizione descrizione: String) {
        self.id = id
        self.descrizione = descrizione
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
    
    // sincronizza le selezioni di Giorno, Settimana e Mese
    func selectItem(Per tipo:TipoCalendario, index:Int) -> Void {
        let searchComponents = calendar.dateComponents([.year, .month, .weekOfYear], from: giorni[index].data)
        
        if tipo == .giorno { //<------ Giorno
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
        } else if tipo == .settimana { //<------ Settimana
            selezioneSettimana = index
            
            // se il nuovo giorno selezionato ricade nella settimana selezionata non faccio nulla
            let settimanaSelezionata = getItem(Per: .settimana, index: selezioneSettimana!) as! Settimana
            let settimanaDelGiornoSelezionato = getItem(Per: .settimana, data: giorni[selezioneGiorno!].data) as! Settimana
            if  settimanaSelezionata != settimanaDelGiornoSelezionato {
                selezioneGiorno = nil
                for index in 0..<giorni.count {
                    if giorni[index].anno == settimanaSelezionata.anno && compare(Data1: giorni[index].data, Data2: settimanaSelezionata.dataInizio) == 0 {
                        selezioneGiorno = index
                    }
                }
            }
            
            // se il nuovo giorno selezionato ricade nel mese selezionato non faccio nulla
            let meseSelezionato = getItem(Per: .mese, index: selezioneMese!) as! Mese
            let meseDelGiornoSelezionato = getItem(Per: .mese, data: giorni[selezioneGiorno!].data) as! Mese
            if  meseSelezionato != meseDelGiornoSelezionato {
                selezioneMese = nil
                for index in 0..<mesi.count {
                    if mesi[index].anno == meseDelGiornoSelezionato.anno && mesi[index].numero == meseDelGiornoSelezionato.numero {
                        selezioneMese = index
                    }
                }
                
                /*for index in 0..<mesi.count {
                    if mesi[index].anno == settimanaSelezionata.anno && compare(Data1: mesi[index].dataInizio, Data2: settimanaSelezionata.dataFine) == -1 && compare(Data1: mesi[index].dataFine, Data2: settimanaSelezionata.dataInizio) == 1 {
                        selezioneMese = index
                    }
                }*/
            }
        } else { //<------ Mese
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
        var returnedObject: Any? = nil
        
        if tipo == .giorno {
            if let selezioneGiorno = selezioneGiorno { returnedObject = giorni[selezioneGiorno] }
        } else if tipo == .settimana {
            if let selezioneSettimana = selezioneSettimana { returnedObject = settimane[selezioneSettimana] }
        } else {
            if let selezioneMese = selezioneMese { returnedObject = mesi[selezioneMese] }
        }
        
        return returnedObject
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

class Mese: Equatable {
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
    
    static func == (primo:Mese, secondo:Mese)->Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return
            (primo.numero == secondo.numero && primo.anno == secondo.anno) ||
                (compare(Data1:primo.dataInizio, Data2:secondo.dataInizio) == 0 && compare(Data1:primo.dataFine, Data2:secondo.dataFine) == 0)
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

//MARK:- Ordini Totali
struct OrdiniTotali:Codable {
    var codiceCliente = ""
    var totale = 0.0
    var margine = 0.0
    var count = 0
}

struct OrdiniTotaliRequest:Codable {
    var funzione = ""
    var dallaData = ""
    var allaData = ""
}

struct OrdiniTotaliResult:Codable {
    var resultCount = 0
    var results = [OrdiniTotali]()
}

//MARK:- Elenco ordini dettagliato
struct OrdiniElencoRequest:Codable {
    var codiceCliente = ""
    var dallaData = ""
    var allaData = ""
}

struct OrdiniElencoResult:Codable {
    var resultCount = 0
    var results = [OrdiniElenco]()
}

struct OrdiniElenco:Codable {
    var id: String = ""
    var data: String = ""
    var dataCompetenza: String = ""
    var codiceCliente: String = ""
    var denominazioneCliente: String = ""
    var backOrder: Bool = false
    var numero: Int = 0
    var riferimentoCliente: String = ""
    var tipo: Int = 0
    var note: String = ""
    var totale: Double = 0.0
    var margine: Double = 0.0
    var numeroReferenze: Double = 0.0
    var preordineCreato: Bool = false
    var bozza: Bool = false
    var eliminato: Bool = false
    var preventivo: Bool = false
    var dataInvioPreventivo: String = ""
    var dataAccettazionePreventivo: String = ""
}

//MARK:- Righe ordine
struct OrdineRigheRequest:Codable {
    var id = ""
}

struct OrdineRigheResult:Codable {
    var resultCount = 0
    var results = [OrdineRighe]()
}

struct OrdineRighe:Codable {
    var id: String = ""
    var idOrdiniClienti: String = ""
    var codiceArticolo: String = ""
    var codiceArticoloGCC: String = ""
    var barcode: String = ""
    var descrizione: String = ""
    var marchio: String = ""
    var modello: String = ""
    var nettoNetto: Double = 0.0
    var quantita: Int = 0
    var prezzo: Double = 0.0
    var quantitaConfermata: Int = 0
    var quantitaEvasa: Int = 0
    var codiceArticoloCliente: String = ""
    var note: String = ""
    var costoGCC: Double = 0.0
    var totale: Double = 0.0
    var margine: Double = 0.0
    var inOrdine: Int = 0
    var giacenza: Int = 0
    var ddtNumero: String = ""
    var ddtData: String = ""
}

//MARK:- Dettaglio articolo
struct DettaglioArticoloRequest:Codable {
    var functionName: String = ""
    var codiceArticolo: String = ""
}

struct DettaglioArticoloResult:Codable {
    var resultCount = 0
    var results = [DettaglioArticolo]()
}

struct DettaglioArticolo:Codable {
    var idTime: String = ""
    var codice: String = ""
    var modello: String = ""
    var descrizione: String = ""
    var giacenza: Int = 0
    var inOrdine: Int = 0
    var prezzoAcquisto: Double = 0.0
    var prezzoRiordino: Double = 0.0
    var prezzoVendita: Double = 0.0
    var aliquotaIva: Double = 0.0
    var novita: Bool = false
    var eliminato: Bool = false
    var esclusiva: Bool = false
    var barcode: String = ""
    var marchioCopre: String = ""
    var griglia: String = ""
    var grigliaObbligatorio: String = ""
    var ediel01: String = ""
    var ediel02: String = ""
    var ediel03: String = ""
    var ediel04: String = ""
    var marchio: String = ""
    var ricaricoPercentuale: Double = 0.0
    var doppioNetto: Double = 0.0
    var triploNetto: Double = 0.0
    var nettoNetto: Double = 0.0
    var ordinabile: Bool = false
    var canale: Int = 0
    var pndAC: Double = 0.0
    var pndAP: Double = 0.0
}
