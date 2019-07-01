//
//  ViewController.swift
//  QYXBannerView
//
//  Created by 邱云翔 on 2019/6/30.
//  Copyright © 2019 邱云翔. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var bannerView : BannerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //简单地用了颜色变化做了效果
        self.bannerView = BannerView.init(frame:CGRect.init(x: 0, y: 150, width: self.view.bounds.size.width, height: 100))
        self.view.addSubview(self.bannerView!)
        self.bannerView?.bannerOriginalDataArray = [UIColor.red,UIColor.blue,UIColor.yellow,UIColor.lightGray,UIColor.cyan,UIColor.brown]
    }


}

