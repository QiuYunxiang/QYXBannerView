//
//  BannerOfCustomerView.swift
//  QYXBannerView
//
//  Created by 邱云翔 on 2019/6/30.
//  Copyright © 2019 邱云翔. All rights reserved.
//

//自定义view，进行扩展

import UIKit

/* 设置backview距离俯视图的edges */
let backViewEdges = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)

class BannerOfCustomerView: UIView {
    
    var backView : UIView? //测试用的视图
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    func setUpViews()  {
        //
        self.backgroundColor = UIColor.clear
        
        //
        self.backView = UIView.init(frame: CGRect.init(x: backViewEdges.left, y: backViewEdges.top, width: self.bounds.size.width - backViewEdges.left - backViewEdges.right, height: self.bounds.size.height - backViewEdges.top - backViewEdges.bottom))
        self.addSubview(self.backView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

/// 点击事件代理
protocol BannerOfCustomerViewDelegate {
    func bannerViewDidHandle(tap:UITapGestureRecognizer)
}
