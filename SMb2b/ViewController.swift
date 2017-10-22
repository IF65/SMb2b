//
//  ViewController.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 18/10/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var topAuxiliaryPanel: UIView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomAuxiliaryPanel: UIView!
    
    // selezione corrente
    var selectedDateIndex: Int = 0
    
    // colors
    let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
    let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)
    
    // dati
    var clienti = [Cliente]()
    var periodo = [Date]()
    
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
        
        self.navigationController?.navigationBar.topItem?.title = "Supermedia S.p.A."
        
        topCollectionView.scrollToItem(at: IndexPath(item: selectedDateIndex, section: 0), at: .centeredHorizontally, animated: false)
        topCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func stringToDate(_ dateString:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Current time zone
        
        guard let returnDate = dateFormatter.date(from: dateString) else {return nil}
        
        return returnDate
    }
}

extension ViewController: UICollectionViewDataSource {
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
}

extension ViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDateIndex = indexPath.row
        collectionView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clienti.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        
        cell.textLabel?.text = clienti[indexPath.row].codice
        cell.detailTextLabel?.text = clienti[indexPath.row].descrizione
        
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
