//
//  YJMainHeaderView.swift
//  Simple
//
//  Created by JotingYou on 2019/4/26.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import SnapKit
class YJMainHeaderView: UIView {
    
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var grouped: UILabel!
    
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var trendLabel: UILabel!
    
    lazy var view:UIView = {
        
        return Bundle.main.loadNibNamed("YJMainHeaderView", owner: self, options: nil)?.first as! UIView
    }()

    //MARK: - Notification
    @objc func setValueForLabels() {
        valueLabel.text = String(format:"%.3lf",YJCache.shared.record!.total_value)
        interestLabel.text = String(format: "%.3lf", YJCache.shared.record!.total_interest)
        grouped.text = String(format: "%.2f", YJCache.shared.record!.grouped_rate * 100) + "%"
        trendLabel.text = String(format: "%.2f", YJCache.shared.record!.rate_trend * 100) + "%"
    }
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        view.subviews.last?.layer.masksToBounds = true
        view.subviews.last?.layer.cornerRadius = 10
        addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setValueForLabels), name: NSNotification.Name(rawValue: YJConst.recordChangedNotification), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(view)
        view.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }

    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}
