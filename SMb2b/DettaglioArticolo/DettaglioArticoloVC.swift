//
//  DettaglioArticoloVC.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 15/11/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class DettaglioArticoloVC: UITableViewController {
    
    var codiceArticolo: String?
    
    @IBOutlet weak var descrizione: UILabel?
    @IBOutlet weak var codiceGcc: UILabel?
    @IBOutlet weak var codiceSm: UILabel?
    @IBOutlet weak var modello: UILabel?
    @IBOutlet weak var giacenza: UILabel?
    @IBOutlet weak var inOrdine: UILabel?
    @IBOutlet weak var prezzoAcquisto: UILabel?
    @IBOutlet weak var prezzoRiordino: UILabel?
    @IBOutlet weak var prezzoVendita: UILabel?
    @IBOutlet weak var aliquotaIva: UILabel?
    @IBOutlet weak var novita: UILabel?
    @IBOutlet weak var eliminato: UILabel?
    @IBOutlet weak var esclusiva: UILabel?
    @IBOutlet weak var barcode: UILabel?
    @IBOutlet weak var marchioCopre: UILabel?
    @IBOutlet weak var ediel: UILabel?
    @IBOutlet weak var ricaricoPercentuale: UILabel?
    @IBOutlet weak var marchio: UILabel?
    @IBOutlet weak var doppioNetto: UILabel?
    @IBOutlet weak var triploNetto: UILabel?
    @IBOutlet weak var nettoNetto: UILabel?
    @IBOutlet weak var ordinabile: UILabel?
    @IBOutlet weak var canale: UILabel?
    @IBOutlet weak var pndAC: UILabel?
    @IBOutlet weak var pndAP: UILabel?
    
    var dataTask: URLSessionDataTask?
    var searchResults = DettaglioArticoloResult()
    var isLoading = false
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descrizione?.alpha = alphaSM
        codiceGcc?.alpha = alphaSM
        codiceSm?.alpha = alphaSM
        modello?.alpha = alphaSM
        giacenza?.alpha = alphaSM
        inOrdine?.alpha = alphaSM
        prezzoAcquisto?.alpha = alphaSM
        prezzoRiordino?.alpha = alphaSM
        prezzoVendita?.alpha = alphaSM
        aliquotaIva?.alpha = alphaSM
        novita?.alpha = alphaSM
        eliminato?.alpha = alphaSM
        esclusiva?.alpha = alphaSM
        barcode?.alpha = alphaSM
        marchioCopre?.alpha = alphaSM
        ediel?.alpha = alphaSM
        marchio?.alpha = alphaSM
        ricaricoPercentuale?.alpha = alphaSM
        doppioNetto?.alpha = alphaSM
        triploNetto?.alpha = alphaSM
        nettoNetto?.alpha = alphaSM
        ordinabile?.alpha = alphaSM
        canale?.alpha = alphaSM
        pndAC?.alpha = alphaSM
        pndAP?.alpha = alphaSM
        
        reloadData()
        performSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Functions
    private func showNetworkError() {
        let alert = UIAlertController(title: "Errore di rete...", message: "C'è stato un errore nel tentativo di accesso al server b2b di Supermedia S.p.A. . Riprova.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func parse(data: Data) -> DettaglioArticoloResult? {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(DettaglioArticoloResult.self, from: data)
            
            return result
        } catch {
            print("JSON Error \(error)")
            return nil
        }
    }
    
    private func performSearch() {
        dataTask?.cancel()
        hasSearched = true
        isLoading = true
        //tableView.reloadData()
        self.reloadData()
        
        searchResults.results = []
        
        let url = URL(string: itmUrl)
        
        do {
            var dettaglioArticoloRequest = DettaglioArticoloRequest()
            dettaglioArticoloRequest.functionName = "tabulatoCopre"
            if let codiceArticolo = codiceArticolo {
                dettaglioArticoloRequest.codiceArticolo = codiceArticolo
            }
            
            let encoder = JSONEncoder()
            let dettaglioArticoloRequestBody = try encoder.encode(dettaglioArticoloRequest)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.setValue("tabulatoCopre", forHTTPHeaderField: "function")
            request.httpBody = dettaglioArticoloRequestBody
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: request) {data,response,error in
                if let error = error {
                    print("Failure! \(error)")
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)!
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            
                            self.reloadData()
                            //self.tableView.reloadData()
                        }
                        return
                    }
                    
                } else {
                    print("Success! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.reloadData()
                    //self.tableView.reloadData()
                    self.showNetworkError()
                }
                
            }
            dataTask?.resume()
        } catch {
            print("JSON Error \(error)")
        }
    }
    
    private func reloadData() {
        codiceGcc?.text = ""
        codiceSm?.text = ""
        descrizione?.text = ""
        giacenza?.text = ""
        inOrdine?.text = ""
        prezzoAcquisto?.text = ""
        prezzoRiordino?.text = ""
        prezzoVendita?.text = ""
        aliquotaIva?.text = ""
        novita?.text = ""
        eliminato?.text = ""
        esclusiva?.text = ""
        barcode?.text = ""
        marchioCopre?.text = ""
        ediel?.text = ""
        ricaricoPercentuale?.text = ""
        doppioNetto?.text = ""
        triploNetto?.text = ""
        nettoNetto?.text = ""
        ordinabile?.text = ""
        canale?.text = ""
        pndAC?.text = ""
        pndAP?.text = ""
        
        // sezione importi
        prezzoVendita?.text = ""
        if searchResults.results.count == 1 {
            let result = searchResults.results[0]
            
            let numberFormatter = NumberFormatter()
            
            let descrizioneArticolo = searchResults.results[0].descrizione.lowercased().capitalizingFirstLetter()
            let modello = searchResults.results[0].modello
            let marchio = searchResults.results[0].marchio
            descrizione?.text = "\(descrizioneArticolo)\n\nmodello: \(modello)\nmarchio: \(marchio)"
            
            numberFormatter.numberStyle = .currency
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.locale = Locale(identifier: Locale.current.identifier)
            nettoNetto?.text = numberFormatter.string(from: result.nettoNetto as NSNumber)
            doppioNetto?.text = numberFormatter.string(from: result.doppioNetto as NSNumber)
            prezzoAcquisto?.text = numberFormatter.string(from: result.prezzoAcquisto as NSNumber)
            
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 0
            giacenza?.text = numberFormatter.string(from: result.giacenza as NSNumber)
            inOrdine?.text = numberFormatter.string(from: result.inOrdine as NSNumber)
            
            codiceGcc?.text = result.codice
            codiceSm?.text = "0123456"
            prezzoRiordino?.text = ""
            prezzoVendita?.text = ""
            aliquotaIva?.text = ""
            novita?.text = ""
            eliminato?.text = ""
            esclusiva?.text = ""
            barcode?.text = result.barcode
            marchioCopre?.text = ""
            ediel?.text = result.ediel01+"."+result.ediel02+"."+result.ediel03+"."+result.ediel04
            ricaricoPercentuale?.text = ""
            triploNetto?.text = ""
            ordinabile?.text = ""
            canale?.text = String(searchResults.results[0].canale)
            pndAC?.text = ""
            pndAP?.text = ""
            
            
        }
    }
}
