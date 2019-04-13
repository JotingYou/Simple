//
//  YJMainViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJMainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,YJEditViewControllerDelegate,UISearchBarDelegate,YJDetailTVCDelegate {
    func didFinished() {
        let index = IndexPath.init(row: 0, section: 0)        
        self.tableView.insertRows(at: [index], with: .automatic)
    }
    
    func didEdited(index:IndexPath) {
        self.tableView.reloadRows(at: [index], with: .automatic)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    //MARK: -
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            YJCache.shared.deletePersonAt(row: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: .editingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            print("Deleted")
//
//            self.catNames.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return YJCache.shared.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableID = "personCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableID)!
        let person = YJCache.shared.people[indexPath.row]
        
        cell.textLabel?.text = person.name
        if person.isValued {
            cell.detailTextLabel?.text = String(person.profit)
        }else{
            cell.detailTextLabel?.text = "Waiting..."
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: indexPath)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: YJEditViewController.self) {
            let dest:YJEditViewController = segue.destination as! YJEditViewController
            dest.type = 0
            dest.delegate = self
        }else if segue.destination.isKind(of: YJDetailTableViewController.self){
            let dest = segue.destination as! YJDetailTableViewController
            if let index:IndexPath = sender as? IndexPath {
                dest.person = YJCache.shared.people[index.row]
                dest.delegate = self
                dest.indexPath = index
            }

        }
    }
 

}
