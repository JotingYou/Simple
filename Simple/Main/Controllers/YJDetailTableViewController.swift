//
//  YJDetailTableViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
protocol YJDetailTVCDelegate:NSObjectProtocol {
    func didEdited(index:IndexPath)
}
class YJDetailTableViewController: UITableViewController,YJEditViewControllerDelegate {
    func didFinished(tag: Int, indexPath: IndexPath?) {
        self.tableView.reloadData()
        self.delegate?.didEdited(index: indexPath!)
    }

    
    weak var delegate:YJDetailTVCDelegate?
    var indexPath:IndexPath?
    
    var person:People?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Name", comment: "")
            cell.detailTextLabel?.text = person!.name
            break;
        case 1:
            cell.textLabel?.text = NSLocalizedString("Stock Name", comment: "")
            cell.detailTextLabel?.text = person!.fund
            break;
        case 2:
            cell.textLabel?.text = NSLocalizedString("Stock Number", comment: "")
            cell.detailTextLabel?.text = person!.fund_number
            break;
        case 3:
            cell.textLabel?.text = NSLocalizedString("Amount", comment: "")
            cell.detailTextLabel?.text = String(person!.amount)
            break;
        case 4:
            cell.textLabel?.text = NSLocalizedString("Value", comment: "")
            cell.detailTextLabel?.text = String(person!.value)
            break;
        case 5:
            cell.textLabel?.text = NSLocalizedString("Cost", comment: "")
            cell.detailTextLabel?.text = String(person!.cost)
            break;
        case 6:
            cell.textLabel?.text = NSLocalizedString("Interest", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.profit)
            if person!.profit >= 0{
                cell.detailTextLabel?.textColor = .red
            }else{
                cell.detailTextLabel?.textColor = .green
            }
            break;
        case 7:
            cell.textLabel?.text = NSLocalizedString("Simple", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.simple*100) + "%"
            break;
        case 8:
            cell.textLabel?.text = NSLocalizedString("Years", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.annualized*100) + "%"
            break;
        case 9:
            cell.textLabel?.text = NSLocalizedString("Buy Date", comment: "")
            cell.detailTextLabel?.text = YJCache.shared.dateFormatter.string(from: person!.buy_date!)
            break;
        case 10:
            cell.textLabel?.text = NSLocalizedString("Days", comment: "")
            cell.detailTextLabel?.text = String(person!.days)
            break;
        default:
            break;
        }

        return cell
    }


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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: YJEditViewController.self) {
            let dest:YJEditViewController = segue.destination as! YJEditViewController
            dest.indexPath = indexPath
            dest.person = person
            dest.type = 1
            dest.delegate = self
            
        }
    }
 

}
