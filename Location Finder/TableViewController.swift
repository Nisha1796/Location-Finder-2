//
//  TableViewController.swift
//  Location Finder
//
//  Created by Nisha Gohil on 2021-03-27.
//

import UIKit
var HistoryArray: [String] = []
let userDefaults = UserDefaults.standard

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        myTableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        HistoryArray = userDefaults.stringArray(forKey: "location") ?? []
        userDefaults.set(HistoryArray, forKey: "location")
        
       myTableView.dataSource = self
       myTableView.delegate = self

       myTableView.reloadData()

}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return HistoryArray.count
    
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    
    
    cell?.textLabel?.text = HistoryArray[indexPath.row]
    
  
    return cell!
}


    //to delete a task from swiping left
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            HistoryArray = userDefaults.stringArray(forKey: "location") ?? []
            HistoryArray.remove(at: indexPath.row)
            userDefaults.set(HistoryArray, forKey: "location")
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
        }
   
}
    
