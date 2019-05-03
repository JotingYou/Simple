//
//  YJAttentionPicCell.swift
//  Simple
//
//  Created by JotingYou on 2019/5/3.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJAttentionPicCell: UICollectionViewCell {
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 布局
        setupLayout()
    }
    // 布局
    func setupLayout() {
        self.addSubview(self.imageView)
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = 5
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var picModel :YJAPicInfos? {
        didSet {
            guard let model = picModel else {return}
            self.imageView.sd_setImage(with: URL(string:model.originUrl! ),completed: nil)
        }
    }
}
