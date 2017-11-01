//
//  ViewController.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

// colors
public let blueSM = UIColor(red: 0.0, green: 85/255, blue: 145/255, alpha: 1)
public let purpleSM = UIColor(red: 246/255, green: 21/255, blue: 147/255, alpha: 1)
public let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
public let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionViewPanel: UIView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalPanel: UIView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var countTitle: UILabel!
    @IBOutlet weak var margine: UILabel!
    @IBOutlet weak var margineTitle: UILabel!
    @IBOutlet weak var totale: UILabel!
    @IBOutlet weak var totaleTitle: UILabel!
    
    @IBOutlet weak var boxCount: UIView!
    @IBOutlet weak var boxMargine: UIView!
    @IBOutlet weak var boxTotale: UIView!
    
    @IBAction func cambiaTipoCalendario(_ sender: UIBarButtonItem) {
        
        switch self.tipoCalendario {
        case .giorno:
            self.tipoCalendario = .settimana
        case .settimana:
            self.tipoCalendario = .mese
        case .mese:
            self.tipoCalendario = .giorno
        }
        
        performSearch()
        
        topCollectionView.reloadData()
    }
    
    // calendario
    var tipoCalendario: TipoCalendario = .giorno
    
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
        
        totalPanel.layer.backgroundColor = UIColor.white.cgColor;//UIColor.lightGray.withAlphaComponent(0.1).cgColor
        totalPanel.layer.borderColor = UIColor.lightGray.cgColor
        totalPanel.layer.borderWidth = 0.0
        
        boxTotale.layer.cornerRadius = 8.0
        boxTotale.layer.borderColor = blueSM.cgColor //UIColor.lightGray.cgColor
        boxTotale.layer.borderWidth = 1.0
        boxTotale.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        totale.textColor = blueSM
        totaleTitle.text = "Totale"
        totaleTitle.textColor = blueSM
        
        boxMargine.layer.cornerRadius = 8.0
        boxMargine.layer.borderColor = blueSM.cgColor //UIColor.lightGray.cgColor
        boxMargine.layer.borderWidth = 1.0
        boxMargine.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        margine.textColor = blueSM
        margineTitle.text = "Margine"
        margineTitle.textColor = blueSM
        
        boxCount.layer.cornerRadius = 8.0
        boxCount.layer.borderColor = blueSM.cgColor //UIColor.lightGray.cgColor
        boxCount.layer.borderWidth = 1.0
        boxCount.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        count.textColor = blueSM
        countTitle.text = "Ordini"
        countTitle.textColor = blueSM
        
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 0.3
        
        periodo.selectItem(Per: tipoCalendario, index: periodo.selezioneGiorno!)
        
        performSearch()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animateAlongsideTransition(in: nil, animation: nil) {
            (context) -> Void in
            
            if let index = periodo.getSelectedIndex(Per: self.tipoCalendario) {
                self.topCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
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
        return periodo.count(Per: tipoCalendario)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tipoCalendario == .giorno {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CollectionViewCell
            
            if indexPath.row == periodo.getSelectedIndex(Per: .giorno) {
                cell.boxInternoTopBar.backgroundColor = purpleSM
            } else {
                cell.boxInternoTopBar.layer.backgroundColor = blueSM.cgColor
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            dateFormatter.dateFormat = "dd"
            
            let data = (periodo.getItem(Per: tipoCalendario, index: indexPath.row) as! Giorno).data
            
            cell.etichettaGiornoDellaSettimana.text = dateFormatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: data) - 1]
            cell.etichettaGiorno.text = dateFormatter.string(from: data)
            cell.etichettaMese.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: data) - 1]
            
            return cell
        } else if tipoCalendario == .settimana{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weakCell", for: indexPath) as! CollectionWeakViewCell
            
            if indexPath.row == periodo.getSelectedIndex(Per: .settimana) {
                cell.boxInternoTopBar.backgroundColor = purpleSM
            } else {
                cell.boxInternoTopBar.layer.backgroundColor = blueSM.cgColor
            }
            
            cell.etichettaNumeroSettimana.text = "Settimana n.\((periodo.getItem(Per: .settimana, index: indexPath.row) as! Settimana).numero)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            let dataInizio = (periodo.getItem(Per: .settimana, index: indexPath.row) as! Settimana).dataInizio
            let dataFine = (periodo.getItem(Per: .settimana, index: indexPath.row) as! Settimana).dataFine
            
            cell.etichettaGiornoIniziale.text = dateFormatter.string(from: dataInizio)
            cell.etichettaGiornoFinale.text = dateFormatter.string(from: dataFine)
            cell.etichettaMeseIniziale.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: dataInizio) - 1]
            cell.etichettaMeseFinale.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: dataFine) - 1]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCell", for: indexPath) as! CollectionMonthViewCell
        
            if indexPath.row == periodo.getSelectedIndex(Per: .mese) {
                cell.boxInternoTopBar.backgroundColor = purpleSM
            } else {
                cell.boxInternoTopBar.layer.backgroundColor = blueSM.cgColor
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            let dataInizio = (periodo.getItem(Per: .mese, index: indexPath.row) as! Mese).dataInizio
            cell.etichettaMese.text = dateFormatter.monthSymbols[Calendar.current.component(.month, from: dataInizio) - 1].capitalizingFirstLetter()
            cell.etichettaAnno.text = String(Calendar.current.component(.year, from: dataInizio))
        
            return cell
        }
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        periodo.selectItem(Per: tipoCalendario, index: indexPath.row)
        
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
                let selectedItem = periodo.getSelectedItem(Per: .giorno) as! Giorno
                searchRequest.dallaData = dateFormatter.string(from:  selectedItem.data)
                searchRequest.allaData = dateFormatter.string(from:  selectedItem.data)
            } else if self.tipoCalendario == .settimana {
                let selectedItem = periodo.getSelectedItem(Per: .settimana) as! Settimana
                searchRequest.dallaData = dateFormatter.string(from:  selectedItem.dataInizio)
                searchRequest.allaData = dateFormatter.string(from:  selectedItem.dataFine)
            } else {
                let selectedItem = periodo.getSelectedItem(Per: .mese) as! Mese
                searchRequest.dallaData = dateFormatter.string(from:  selectedItem.dataInizio)
                searchRequest.allaData = dateFormatter.string(from:  selectedItem.dataFine)
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
                            
                            self.topCollectionView.scrollToItem(at: IndexPath(item: periodo.getSelectedIndex(Per: self.tipoCalendario)!, section: 0), at: .centeredHorizontally, animated: true)
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
                    self.topCollectionView.scrollToItem(at: IndexPath(item: periodo.getSelectedIndex(Per: self.tipoCalendario)!, section: 0), at: .centeredHorizontally, animated: true)
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
        //destinationViewController.dataSelezionata = periodo[selectedDateIndex]
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: Int
        let height: Int
        if tipoCalendario == .giorno {
            width = 60
            height = 60
        } else if tipoCalendario == .settimana {
            width = 120
            height = 60
        } else {
            width = 125
            height = 60
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

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


