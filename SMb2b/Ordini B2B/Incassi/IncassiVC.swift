//
//  IncassiVC.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 26/11/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class IncassiVC: UIViewController {
    
    @IBOutlet weak var topCollectionView: UICollectionView!
    
    @IBAction func cambiaTipoCalendario(_ sender: UIBarButtonItem) {
        
        switch self.tipoCalendario {
        case .giorno:
            self.tipoCalendario = .settimana
        case .settimana:
            self.tipoCalendario = .mese
        case .mese:
            self.tipoCalendario = .giorno
        }
        
        self.topCollectionView.scrollToItem(at: IndexPath(item: self.periodo.getSelectedIndex(Per: self.tipoCalendario)!, section: 0), at: .centeredHorizontally, animated: true)
        
        topCollectionView.reloadData()
    }
    
    var tipoCalendario: TipoCalendario = .giorno
    
    // dati
    var periodo =  ElencoDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImage(named: "logoSM_T2.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit// set imageview's content mode
        self.navigationItem.titleView = imageView
        
        topCollectionView.showsHorizontalScrollIndicator = false
        
        self.topCollectionView.scrollToItem(at: IndexPath(item: self.periodo.getSelectedIndex(Per: self.tipoCalendario)!, section: 0), at: .centeredHorizontally, animated: true)
        
        topCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animateAlongsideTransition(in: nil, animation: nil) {
            (context) -> Void in
            
            if let index = self.periodo.getSelectedIndex(Per: self.tipoCalendario) {
                self.topCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
            
            return
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension IncassiVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return periodo.count(Per: tipoCalendario)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tipoCalendario == .giorno {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarDayCell
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weakCell", for: indexPath) as! CalendarWeakCell
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCell", for: indexPath) as! CalendarMonthCell
            
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
    }
}
