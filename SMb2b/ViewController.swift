//
//  ViewController.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionViewPanel: UIView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalPanel: UIView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var margine: UILabel!
    @IBOutlet weak var totale: UILabel!
    
    // selezione corrente
    var selectedDateIndex: Int = 0
    
    // colors
    let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
    let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)
    
    // dati
    var clienti = [Cliente]()
    var periodo = [Date]()
    
    var dataTask: URLSessionDataTask?
    var searchResults = ResultArray()
    var isLoading = false
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clienti.append(Cliente(codice: "EPRICE", descrizione: "ePrice"))
        clienti.append(Cliente(codice: "ONLINESTORE", descrizione: "Online Store"))
        clienti.append(Cliente(codice: "TEKWORLD", descrizione: "Tekworld"))
        
        topCollectionView.showsHorizontalScrollIndicator = false
        
        let currentDateCommponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        var dateComponents = DateComponents()
        
        // current date
        dateComponents.year = currentDateCommponents.year!
        dateComponents.month = currentDateCommponents.month!
        dateComponents.day = currentDateCommponents.day!
        dateComponents.timeZone = TimeZone(identifier: "GMT")
        let currentDate = Calendar.current.date(from: dateComponents)
        
        // starting date
        dateComponents.year = currentDateCommponents.year! - 1
        dateComponents.month = 1 //currentDateCommponents.month!
        dateComponents.day = 1
        dateComponents.timeZone = TimeZone(identifier: "GMT")
        let startingDate = Calendar.current.date(from: dateComponents)
        
        // final date
        dateComponents.year = currentDateCommponents.year!
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.timeZone = TimeZone(identifier: "GMT")
        let finalDate = Calendar.current.date(from: dateComponents)
        
        let dateRange = startingDate! ... finalDate!
        
        var date = startingDate
        while (dateRange.contains(date!)) {
            periodo.append(date!)
            date = date?.addingTimeInterval(60*60*24)
            //print(date!)
            if date!.compare(currentDate!) == .orderedSame {
                selectedDateIndex = periodo.count
            }
        }
        
        //Inizializzazione interfaccia
        self.navigationController?.navigationBar.topItem?.title = "Supermedia S.p.A."
        
        topCollectionView.scrollToItem(at: IndexPath(item: selectedDateIndex, section: 0), at: .centeredHorizontally, animated: false)
        topCollectionView.reloadData()
        
        var cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SearchResultCell")
        cellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "LoadingCell")
        cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NothingFoundCell")
        
        collectionViewPanel.layer.borderColor = UIColor.lightGray.cgColor
        collectionViewPanel.layer.borderWidth = 0.5
        
        totalPanel.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        totalPanel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        totalPanel.layer.borderWidth = 0.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Private functions
    private func parse(data: Data) -> ResultArray? {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            
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
}

//MARK:- Collection View
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return periodo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CollectionViewCell
        
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        cell.boxInterno.layer.cornerRadius = 4.0
        cell.boxInterno.layer.borderColor = UIColor.lightGray.cgColor
        cell.boxInterno.layer.borderWidth = 0.5
        cell.boxInterno.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cell.boxInterno.layer.shadowColor = UIColor.lightGray.cgColor
        cell.boxInterno.layer.shadowOpacity = 1
        cell.boxInterno.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.boxInterno.layer.shadowRadius = 2
        
        cell.boxInterno.layer.backgroundColor = UIColor.white.cgColor
        
        //cell.boxInterno.layer.shadowPath = UIBezierPath(rect: cell.boxInterno.bounds).cgPath
        //cell.boxInterno.layer.shouldRasterize = true
        
        cell.boxInternoTopBar.layer.cornerRadius = 4.0
        cell.boxInternoTopBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if indexPath.row == selectedDateIndex {
            cell.boxInternoTopBar.layer.backgroundColor = UIColor.blue.cgColor
            cell.etichettaGiornoDellaSettimana.textColor = UIColor.white
            cell.etichettaMese.textColor = UIColor.blue
            cell.etichettaGiorno.textColor = UIColor.blue
        } else {
            cell.etichettaGiorno.textColor = UIColor.black
            cell.etichettaMese.textColor = UIColor.black
            if Calendar.current.component(.weekday, from: periodo[indexPath.row]) == 1 {
                cell.boxInternoTopBar.layer.backgroundColor = UIColor.red.cgColor
                cell.etichettaGiornoDellaSettimana.textColor = UIColor.white
            } else {
                cell.boxInternoTopBar.layer.backgroundColor = darkGreen.cgColor
                cell.etichettaGiornoDellaSettimana.textColor = UIColor.white
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT")
        cell.etichettaGiornoDellaSettimana.text = dateFormatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: periodo[indexPath.row]) - 1]
        
        dateFormatter.dateFormat = "dd"
        cell.etichettaGiorno.text = dateFormatter.string(from: periodo[indexPath.row])
        
        cell.etichettaMese.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: periodo[indexPath.row]) - 1]
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDateIndex = indexPath.row
        collectionView.reloadData()
        
        performSearch()
    }
    
    
    func performSearch() {
        let searchText = "LAVATRICE"
        dataTask?.cancel()
        hasSearched = true
        isLoading = true
        tableView.reloadData()
        
        searchResults.results = []
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: String(format:"http://11.0.1.31:8080/b2b", encodedText))
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let searchRequest = SearchRequest()
            searchRequest.funzione = "totaleOrdiniPerCliente"
            searchRequest.dallaData = dateFormatter.string(from:  periodo[selectedDateIndex])
            searchRequest.allaData = dateFormatter.string(from:  periodo[selectedDateIndex])
            
            let encoder = JSONEncoder()
            let searchRequestBody = try encoder.encode(searchRequest)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("totaleOrdiniPerCliente", forHTTPHeaderField: "funzione")
            request.httpBody = searchRequestBody
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: request) {data,response,error in
                if let error = error {
                    print("Failure! \(error)")
                } else if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        self.searchResults = self.parse(data: data)!
 
                        DispatchQueue.main.async {
                            let currencyFormatter = NumberFormatter()
                            currencyFormatter.usesGroupingSeparator = true
                            currencyFormatter.numberStyle = NumberFormatter.Style.decimal
                            currencyFormatter.minimumFractionDigits = 0
                            currencyFormatter.maximumFractionDigits = 0
                            currencyFormatter.locale = NSLocale.current
                            
                            var count = 0
                            var margine = 0.0
                            var totale = 0.0
                            for riga in self.searchResults.results {
                                count += riga.count
                                margine += riga.margine
                                totale += riga.totale
                            }
                            
                            self.count.text = currencyFormatter.string(from: count as NSNumber)!
                            self.margine.text = currencyFormatter.string(from: margine as NSNumber)!
                            self.totale.text = currencyFormatter.string(from: totale as NSNumber)!
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

//MARK:- Table View
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.results.count == 0 {
            return 1
        } else {
            return searchResults.results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else if searchResults.results.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFoundCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
            
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.decimal
            currencyFormatter.minimumFractionDigits = 0
            currencyFormatter.maximumFractionDigits = 0
            currencyFormatter.locale = NSLocale.current
            
            cell.cliente.text = searchResults.results[indexPath.row].codiceCliente.capitalized
            cell.count.text = String(searchResults.results[indexPath.row].count)
            cell.margine.text = currencyFormatter.string(from: searchResults.results[indexPath.row].margine as NSNumber)!
            cell.totale.text = currencyFormatter.string(from: searchResults.results[indexPath.row].totale as NSNumber)!
            
            cell.cliente.sizeToFit()
            cell.totale.sizeToFit()
            cell.margine.sizeToFit()
            cell.count.sizeToFit()
            
            return cell
        }
    }
}
