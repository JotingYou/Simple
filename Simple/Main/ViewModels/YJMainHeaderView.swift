//
//  YJMainHeaderView.swift
//  Simple
//
//  Created by JotingYou on 2019/4/26.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import Masonry
class YJMainHeaderView: UIView {
    
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var grouped: UILabel!
    
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var basicLabel: UILabel!
    
    lazy var view:UIView = {
        
        return Bundle.main.loadNibNamed("YJMainHeaderView", owner: self, options: nil)?.first as! UIView
    }()

    //MARK: - Notification
    @objc func setValueForLabels() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM,dd,hh:mm a"
        let timeStr = dateFormatter.string(from: YJCache.shared.totalRecord?.modified_time ?? Date())
        let strs:[Substring] = timeStr.split(separator: ",")
        
        monthLabel.text = String(strs.first!)
        dayLabel.text = String(strs[1])
        timeLabel.text = String(strs[2])
        
        valueLabel.text = String(format:"%.3lf",YJCache.shared.totalRecord?.total_value ?? 0)
        interestLabel.text = String(format: "%.3lf", YJCache.shared.totalRecord?.total_interest ?? 0)
        grouped.text = String(format: "%.2f", (YJCache.shared.totalRecord?.grouped_rate ?? 0) * 100) + "%"

    }
    @objc func setBasicLabel(){
        basicLabel.text = String(format: "%.2f", (YJCache.shared.totalRecord?.basic ?? 0) * 100) + "%"
    }
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        view.subviews.last?.layer.masksToBounds = true
        view.subviews.last?.layer.cornerRadius = 10
        addSubview(view)
        view.mas_makeConstraints {
            $0?.edges.equalTo()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setValueForLabels), name: NSNotification.Name(rawValue: YJConst.recordChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setBasicLabel), name: NSNotification.Name(rawValue: YJConst.recordChangedBasic), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(view)
        view.mas_makeConstraints{$0?.edges.equalTo()}

    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}
