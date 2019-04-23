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
    func editPerson(cell:YJFoldingCell)
}

class YJFoldingCell: FoldingCell {

    weak var delegate:YJFoldingCellDelegate?
    
    var person:People?
    
    @IBOutlet weak var  nameLabel:UILabel!
    @IBOutlet weak var profitLabel:UILabel!
    @IBOutlet weak var fundNameLabel:UILabel!
    @IBOutlet weak var rateLabel:UILabel?
    @IBOutlet weak var yearsLabel:UILabel?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func showDetail(_ sender: Any) {
        self.delegate?.foldCell(cell: self)
    }
    
    @IBAction func editPerson(_ sender: Any) {
        self.delegate?.editPerson(cell: self)
    }
    func setPerson(person:People){
        self.person = person
        nameLabel.text = person.name
        fundNameLabel.text = person.fund
        backViewColor = .lightGray
        if person.isValued {
            profitLabel.text = String(format: "%.2lf", person.profit)
            if person.profit >= 0 {
                profitLabel.textColor = .red
                rateLabel?.textColor = .red
                yearsLabel?.textColor = .red
            }else{
                profitLabel.textColor = .green
                rateLabel?.textColor = .red
                yearsLabel?.textColor = .red
            }
            rateLabel?.text = String(format: "%.2f", person.simple)
            yearsLabel?.text = String(format: "%.2f", person.annualized)
        }else{
            profitLabel.text = NSLocalizedString("Waiting", comment: "")
            rateLabel?.text = NSLocalizedString("Waiting", comment: "")
            yearsLabel?.text = NSLocalizedString("Waiting", comment: "")
        }

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
