//
//  TableViewController.swift
//  Location Finder
//
//  Created by Nisha Gohil on 2021-03-27.
//

import UIKit
var array = [""]


class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        myTableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
       myTableView.dataSource = self
       myTableView.delegate = self

       myTableView.reloadData()

}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return array.count
    
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    
    
    cell?.textLabel?.text = array[indexPath.row]
    
  
    return cell!
}


    //to delete a task from swiping left
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
        }
   
}
    
