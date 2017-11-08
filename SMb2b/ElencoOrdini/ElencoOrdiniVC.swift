//
//  ViewControllerOrdiniViewController.swift
//  SMb2b
//
//  Created by if65 on 24/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class ElencoOrdiniVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataInizio: Date?
    var dataFine: Date?
    var clienteCodice: String?
    
    var idSelezionato: String?
    
    var dataTask: URLSessionDataTask?
    var searchResults = OrdiniElencoResult()
    var isLoading = false
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cellNib = UINib(nibName: "ElencoOrdiniCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ElencoOrdiniCell")
        cellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "LoadingCell")
        cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NothingFoundCell")
        
        performSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return searchResults.resultCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ElencoOrdiniCell", for: indexPath) as! ElencoOrdiniCell
            
            cell.riferimento.text = searchResults.results[indexPath.row].riferimentoCliente
            let data = searchResults.results[indexPath.row].data[...searchResults.results[indexPath.row].data.index(searchResults.results[indexPath.row].data.startIndex, offsetBy: 9)]
            
            var tipo = ""
            switch searchResults.results[indexPath.row].tipo {
            case 0 : tipo = "Giornaliero"
            case 1 : tipo = "Stock"
            default:
                tipo = "Drop Ship."
            }
            cell.descrizione.text = "Ord. nr.\(searchResults.results[indexPath.row].numero) del \(data) di tipo \(tipo)"
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.decimal
            currencyFormatter.minimumFractionDigits = 0
            currencyFormatter.maximumFractionDigits = 0
            currencyFormatter.locale = NSLocale.current
            cell.totale.text = currencyFormatter.string(from: searchResults.results[indexPath.row].totale as NSNumber)!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        idSelezionato = searchResults.results[indexPath.row].id
        
        self.performSegue(withIdentifier: "righeOrdine", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "righeOrdine" {
            let destinationViewController = segue.destination as! RigheOrdineVC
            if let idSelezionato = idSelezionato {
                destinationViewController.idOrdine = idSelezionato
            }
            
            // il backbutton appartiene sempre al view controller precedente
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = "Indietro"
            navigationItem.backBarButtonItem = backBarButtonItem
        }
    }
    
    //MARK:- Private functions
    private func parse(data: Data) -> OrdiniElencoResult? {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(OrdiniElencoResult.self, from: data)
            
            return result
        } catch {
            print("JSON Error \(error)")
            return nil
        }
    }
    
    private func showNetworkError() {
        let alert = UIAlertController(title: "Errore di rete...", message: "C'è stato un errore nel tentativo di accesso al server b2b di Supermedia S.p.A. . Riprova.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func stringToDate(_ dateString:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Current time zone
        
        guard let returnDate = dateFormatter.date(from: dateString) else {return nil}
        
        return returnDate
    }
    
    private func dateToString(_ date:Date?, _ format: String?) -> String {
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
    
    private func performSearch() {
        dataTask?.cancel()
        hasSearched = true
        isLoading = true
        tableView.reloadData()
        
        searchResults.results = []
        
        let url = URL(string: "http://11.0.1.31:8080/b2b")
        
        do {
            var elencoOrdiniRequest = OrdiniElencoRequest()
            if let clienteCodice = clienteCodice {
                elencoOrdiniRequest.codiceCliente = clienteCodice
            }
            elencoOrdiniRequest.dallaData = dateToString(dataInizio, nil)
            elencoOrdiniRequest.allaData = dateToString(dataFine, nil)
            
            let encoder = JSONEncoder()
            let elencoOrdiniRequestBody = try encoder.encode(elencoOrdiniRequest)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("elencoOrdiniClienti", forHTTPHeaderField: "funzione")
            request.httpBody = elencoOrdiniRequestBody
            
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
                            
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                } else {
                    print("Success! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                
            }
            dataTask?.resume()
        } catch {
            print("JSON Error \(error)")
        }
    }
}
