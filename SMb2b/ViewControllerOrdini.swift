//
//  ViewControllerOrdiniViewController.swift
//  SMb2b
//
//  Created by if65 on 24/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class ViewControllerOrdini: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataInizio: Date?
    var dataFine: Date?
    var clienteCodice: String?
    
    var dataTask: URLSessionDataTask?
    var searchResults = OrdiniElencoResult()
    var isLoading = false
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.resultCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElencoOrdiniCell", for: indexPath) 
        
        cell.textLabel?.text = String(describing: searchResults.results[indexPath.row].numero)
        return cell
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
    
    private func dateToString(_ date:Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
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
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            var elencoOrdiniRequest = OrdiniElencoRequest()
            if let clienteCodice = clienteCodice {
                elencoOrdiniRequest.codiceCliente = clienteCodice
                print("Cliente: \(clienteCodice)")
            }
            elencoOrdiniRequest.dallaData = dateToString(dataInizio)
            elencoOrdiniRequest.allaData = dateToString(dataFine)
            
    
            print("Inizio: \(dateToString(dataInizio))")
            print("Fine  : \(dateToString(dataFine))")
            
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
