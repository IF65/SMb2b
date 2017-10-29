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
    
    @IBAction func cambiaTipoCalendario(_ sender: UIBarButtonItem) {
        switch self.tipoCalendario{
        case .giorno:
            self.tipoCalendario = .settimana
        case .settimana:
            /*self.tipoCalendario = .mese
        case .mese:
            self.tipoCalendario = .anno
        case .anno:*/
            self.tipoCalendario = .giorno
        }
        
        performSearch()
        
        topCollectionView.reloadData()
    }
    
    // selezione corrente
    var selectedDateIndex: Int = 0
    var selectedWeekIndex: Int = 0
    
    // calendario
    var tipoCalendario: TipoCalendario = .giorno
    
    // colors
    let blueSM = UIColor(red: 0.0, green: 85/255, blue: 145/255, alpha: 1)
    let purpleSM = UIColor(red: 246/255, green: 21/255, blue: 147/255, alpha: 1)
    let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
    let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)
    
    var dataTask: URLSessionDataTask?
    var searchResults = ResultArray()
    var isLoading = false
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clienti.append(Cliente(codice: "EPRICE", descrizione: "ePrice"))
        clienti.append(Cliente(codice: "ONLINESTORE", descrizione: "Online Store"))
        clienti.append(Cliente(codice: "TEKWORLD", descrizione: "Tekworld"))
        clienti.append(Cliente(codice: "YEPPON", descrizione: "Yeppon"))
        
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
        dateComponents.year = currentDateCommponents.year!
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
                selectedWeekIndex = Calendar.current.component(.weekOfYear, from: periodo[selectedDateIndex - 1]) - 1
            }
            
            //settimana
            let dayOfWeek = Calendar.current.component(.weekday, from: date!)
            
            // 1 = Sunday
            if dayOfWeek == 1 {
                let inizioSettimana = date?.addingTimeInterval(-60*60*24*6)
                let settimana = Settimana(Numero: Calendar.current.component(.weekOfYear, from: date!), Inizio: inizioSettimana!, Fine: date!)
                settimana.index = periodo.count - 1
                settimane.append(settimana)
            }
        }
        
        //Inizializzazione interfaccia
        //self.navigationController?.navigationBar.topItem?.title = "Supermedia S.p.A."
        let logo = UIImage(named: "logoSM_T2.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit// set imageview's content mode
        self.navigationItem.titleView = imageView
        
        
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
        
        performSearch()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animateAlongsideTransition(in: nil, animation: nil) {
            (context) -> Void in
            if self.tipoCalendario == .giorno {
                self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
            } else {
                self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedWeekIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
            return
        }
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
        if tipoCalendario == .giorno {
            return periodo.count
        } else {
            return settimane.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tipoCalendario == .giorno {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CollectionViewCell
            if indexPath.row == selectedDateIndex {
                cell.barraSelezione.backgroundColor = purpleSM
                cell.boxInterno.backgroundColor = UIColor.lightGray.withAlphaComponent(0.01)
            } else {
                cell.barraSelezione.backgroundColor = UIColor.white
            }
            
            if Calendar.current.component(.weekday, from: periodo[indexPath.row]) == 1 {
                cell.boxInternoTopBar.layer.backgroundColor = purpleSM.cgColor
            } else {
                cell.boxInternoTopBar.layer.backgroundColor = blueSM.cgColor
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            cell.etichettaGiornoDellaSettimana.text = dateFormatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: periodo[indexPath.row]) - 1]
            
            dateFormatter.dateFormat = "dd"
            cell.etichettaGiorno.text = dateFormatter.string(from: periodo[indexPath.row])
            
            cell.etichettaMese.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: periodo[indexPath.row]) - 1]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weakCell", for: indexPath) as! CollectionWeakViewCell
            
            if indexPath.row == selectedDateIndex {
                cell.barraSelezione.backgroundColor = purpleSM
                cell.boxInterno.backgroundColor = UIColor.lightGray.withAlphaComponent(0.01)
            } else {
                cell.barraSelezione.backgroundColor = UIColor.white
            }
            
            cell.boxInternoTopBar.layer.backgroundColor = blueSM.cgColor
            
            cell.etichettaNumeroSettimana.text = "Settimana n.\(settimane[indexPath.row].numero)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            cell.etichettaGiornoIniziale.text = dateFormatter.string(from: settimane[indexPath.row].dataInizio)
            cell.etichettaGiornoFinale.text = dateFormatter.string(from: settimane[indexPath.row].dataFine)
            
            dateFormatter.locale = Locale(identifier: "it_IT")
            cell.etichettaMeseIniziale.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: settimane[indexPath.row].dataInizio) - 1]
            cell.etichettaMeseFinale.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: settimane[indexPath.row].dataFine) - 1]
            
            return cell
        }
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tipoCalendario == .giorno {
            selectedDateIndex = indexPath.row
            selectedWeekIndex = Calendar.current.component(.weekOfYear, from: periodo[selectedDateIndex]) - 1
        } else {
            selectedDateIndex = settimane[indexPath.row].index
            selectedWeekIndex = indexPath.row
        }
        
        collectionView.reloadData()
        
        performSearch()
    }
    
    
    func performSearch() {
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
            
            let searchRequest = SearchRequest()
            searchRequest.funzione = "totaleOrdiniPerCliente"
            if self.tipoCalendario == .giorno {
                searchRequest.dallaData = dateFormatter.string(from:  periodo[selectedDateIndex])
                searchRequest.allaData = dateFormatter.string(from:  periodo[selectedDateIndex])
            } else {
                searchRequest.dallaData = dateFormatter.string(from:  settimane[selectedWeekIndex].dataInizio)
                searchRequest.allaData = dateFormatter.string(from:  settimane[selectedWeekIndex].dataFine)
            }
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
                            if self.tipoCalendario == .giorno {
                                self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
                            } else {
                                 self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedWeekIndex, section: 0), at: .centeredHorizontally, animated: true)
                            }
                           
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
                    if self.tipoCalendario == .giorno {
                        self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
                    } else {
                        self.topCollectionView.scrollToItem(at: IndexPath(item: self.selectedWeekIndex, section: 0), at: .centeredHorizontally, animated: true)
                    }
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
            
            let count = String(searchResults.results[indexPath.row].count)
            let margine = currencyFormatter.string(from: searchResults.results[indexPath.row].margine as NSNumber)!
            
            cell.cliente.text = searchResults.results[indexPath.row].codiceCliente.capitalized
            cell.descrizione.text = "\(count) ordine/i per \(margine) \(currencyFormatter.currencySymbol!) di margine."
            cell.totale.text = currencyFormatter.string(from: searchResults.results[indexPath.row].totale as NSNumber)!
            
            cell.cliente.sizeToFit()
            cell.descrizione.sizeToFit()
            cell.totale.sizeToFit()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "elencoOrdini", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination as! ViewControllerOrdini
        destinationViewController.clienteSelezionato = "EPRICE"
        destinationViewController.dataSelezionata = periodo[selectedDateIndex]
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: Int
        let height: Int
        if tipoCalendario == .giorno {
            width = 60
            height = 62
        } else {
            width = 130
            height = 62
        }
        return CGSize(width: width, height: height)
    }
    
    /* func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize*/
}




