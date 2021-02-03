//
//  YJDetailTableViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol YJDetailTVCDelegate:NSObjectProtocol {
    func didEdited(index:IndexPath?)
}
class YJDetailTableViewController: UITableViewController,YJEditViewControllerDelegate {
    func didFinished(tag: Int, indexPath: IndexPath?) {
        self.tableView.reloadData()
        self.delegate?.didEdited(index: indexPath)
    }

    
    weak var delegate:YJDetailTVCDelegate?
    var indexPath:IndexPath?
    
    var person:Holds?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(needReload), name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: nil)
    }
    @objc func needReload(){
        tableView.reloadData()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 260
        }else{
            return 44
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 14
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "detailCell")
        }

        switch indexPath.row {
        case 0:
            guard let imageView:UIImageView = cell.viewWithTag(1) as? UIImageView else{
                DDLogError("Cell set failed:Not found imageView")
                return cell
            }
            YJHttpTool.setImageFor(imageView,person?.stock!.id)
            break
        case 1:
            cell.textLabel?.text = NSLocalizedString("Name", comment: "")
            cell.detailTextLabel?.text = person!.owner!.name
            break;
        case 2:
            cell.textLabel?.text = NSLocalizedString("Stock Name", comment: "")
            cell.detailTextLabel?.text = person!.stock?.name
            break;
        case 3:
            cell.textLabel?.text = NSLocalizedString("Stock Number", comment: "")
            cell.detailTextLabel?.text = person!.stock?.id
            break;
        case 4:
            cell.textLabel?.text = NSLocalizedString("Amount", comment: "")
            cell.detailTextLabel?.text = String(person!.amount)
            break;
        case 5:
            cell.textLabel?.text = NSLocalizedString("Unit Value", comment: "")
            cell.detailTextLabel?.text = String(person!.stock!.unit_value)
            break;
        case 6:
            cell.textLabel?.text = NSLocalizedString("Cost", comment: "")
            cell.detailTextLabel?.text = String(format:"%.4lf",person!.cost)
            break;
        case 7:
            cell.textLabel?.text = NSLocalizedString("Interest", comment: "")
            cell.detailTextLabel?.text = String(format:"%.3lf",person!.currentProfit!.profit)
            if person!.currentProfit!.profit >= 0{
                cell.detailTextLabel?.textColor = .red
            }else{
                cell.detailTextLabel?.textColor = .green
            }
            break;
        case 8:
            cell.textLabel?.text = NSLocalizedString("Value", comment: "")
            cell.detailTextLabel?.text = String(format:"%.3lf",person!.currentProfit!.total_value)
            break;
        case 9:
            cell.textLabel?.text = NSLocalizedString("Simple", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.currentProfit!.simple*100) + "%"
            break;
        case 10:
            cell.textLabel?.text = NSLocalizedString("Years", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.currentProfit!.annualized*100) + "%"
            break;
        case 11:
            cell.textLabel?.text = NSLocalizedString("Years", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2lf",person!.currentProfit!.annualized*100) + "%"
            break;
        case 12:
            cell.textLabel?.text = NSLocalizedString("Accounting", comment: "")
            cell.detailTextLabel?.text = String(format:"%.2f", person!.currentProfit!.value_proportion * 100) + "%"
            break;
        case 13:
            cell.textLabel?.text = NSLocalizedString("Days", comment: "")
            cell.detailTextLabel?.text = String(person!.currentProfit!.days)
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
    deinit {        NotificationCenter.default.removeObserver(self)
    }

}
