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
    @IBOutlet weak var costo: UILabel?
    
    /*@IBOutlet weak var descrizione: UILabel?
    @IBOutlet weak var modello: UILabel?
    @IBOutlet weak var marchio: UILabel?*/
    
    var dataTask: URLSessionDataTask?
    var searchResults = DettaglioArticoloResult()
    var isLoading = false
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        UILabel.appearance().textColor = blueSM
        
        reloadData()
        performSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Functions
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
    
    private func reloadData() {
        // sezione descrizione
        descrizione?.text = ""
        
        // sezione importi
        costo?.text = ""
        if searchResults.results.count == 1 {
            let numberFormatter = NumberFormatter()
            
            // sezione descrizione
            let descrizioneArticolo = searchResults.results[0].descrizione.lowercased().capitalizingFirstLetter()
            let modello = searchResults.results[0].modello
            let marchio = searchResults.results[0].marchio
            descrizione?.text = "\(descrizioneArticolo)\nmodello:\(modello)\nmarchio:\(marchio)"
            
            // sezione importi
            numberFormatter.numberStyle = .currency
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.locale = Locale(identifier: Locale.current.identifier)
            costo?.text = numberFormatter.string(from: searchResults.results[0].prezzoAcquisto as NSNumber)
        }
    }
    
    private func performSearch() {
        dataTask?.cancel()
        hasSearched = true
        isLoading = true
        //tableView.reloadData()
        self.reloadData()
        
        searchResults.results = []
        
        let url = URL(string: "http://10.11.14.78/copre/copre2.php")
        
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

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(rawValue: 2.0))//UIFont(name: "System", size: 14)
        header?.textLabel?.textColor = blueSM
        header?.textLabel?.text = header?.textLabel?.text?.lowercased().capitalizingFirstLetter()
    }

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UILabel{
    var defaultColor: UIColor? {
        get { return self.textColor }
        set { self.textColor = newValue }
    }
}
