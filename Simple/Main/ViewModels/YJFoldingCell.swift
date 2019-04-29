//
//  YJFoldingCell.swift
//  Simple
//
//  Created by JotingYou on 2019/4/21.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import FoldingCell

protocol YJFoldingCellDelegate:NSObjectProtocol {
    func foldCell(cell:YJFoldingCell)
    func showDetail(cell:YJFoldingCell)
}


class YJFoldingCell: FoldingCell {

    weak var delegate:YJFoldingCellDelegate?
    
    var person:People?
    

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var  nameLabel:UILabel!
    @IBOutlet weak var profitLabel:UILabel!
    @IBOutlet weak var fundNameLabel:UILabel!
    @IBOutlet weak var rateLabel:UILabel?
    @IBOutlet weak var yearsLabel:UILabel?
    //detail view label
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var detailUnitValueLabel: UILabel!
    @IBOutlet weak var detailFundNameLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    
    @IBOutlet weak var detailFundCodeLabel: UILabel!
    
    @IBOutlet weak var detailCostLabel: UILabel!
    @IBOutlet weak var detailAmountLabel: UILabel!
    @IBOutlet weak var detailBuyDateLabel: UILabel!
    @IBOutlet weak var detailDaysLabel: UILabel!
    @IBOutlet weak var detailProfitLabel: UILabel!
    @IBOutlet weak var accountingLabel: UILabel!

    @IBOutlet weak var detailValueLabel: UILabel!
    
    
    
    
    @IBAction func showDetail(_ sender: Any) {
        self.delegate?.foldCell(cell: self)
    }
    
    @IBAction func editPerson(_ sender: Any) {
        self.delegate?.showDetail(cell: self)
    }
    
    
    
    func setPerson(person:People){
        self.person = person
        nameLabel.text = person.name
        fundNameLabel.text = person.stock?.name
        
        updateTimeLabel.text = YJCache.shared.dateFormatter.string(from: person.stock!.update_time!)
        detailUnitValueLabel.text =  String( person.stock!.unit_value)
        detailFundNameLabel.text = person.stock?.name
        detailTitleLabel.text = person.name
        
        detailFundCodeLabel.text = person.stock?.id
        
        detailCostLabel.text = String(format:"%.4lf",person.cost)
        detailAmountLabel.text = String(person.amount)
        detailBuyDateLabel.text = YJCache.shared.dateFormatter.string(from: person.buy_date!)
        detailDaysLabel.text = String(person.days)
        accountingLabel.text = String(format:"%.2f", person.value_proportion * 100) + "%"
        detailValueLabel.text = String(format:"%.3lf",person.total_value)
        if person.isValued {
            profitLabel.text = String(format: "%.3lf", person.profit)
            detailProfitLabel.text = String(format: "%.3lf", person.profit)

            if person.profit >= 0 {
                profitLabel.textColor = .red
                rateLabel?.textColor = .red
                yearsLabel?.textColor = .red
                detailProfitLabel.textColor = .red
            }else{
                profitLabel.textColor = .green
                rateLabel?.textColor = .green
                yearsLabel?.textColor = .green
                detailProfitLabel.textColor = .green
            }
            rateLabel?.text = String(format: "%.2f", person.simple*100) + "%"
            yearsLabel?.text = String(format: "%.2f", person.annualized*100) + "%"
        }else{
            profitLabel.text = NSLocalizedString("Waiting", comment: "")
            rateLabel?.text = NSLocalizedString("Waiting", comment: "")
            yearsLabel?.text = NSLocalizedString("Waiting", comment: "")
            detailProfitLabel.text = NSLocalizedString("Waiting", comment: "")
        }

    }
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        editButton.layer.cornerRadius = 10
        editButton.layer.masksToBounds = true
        super.awakeFromNib()

        
        // Initialization code
    }
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.26, 0.2, 0.2,0.2]// timing animation for each view
        return durations[itemIndex]
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
