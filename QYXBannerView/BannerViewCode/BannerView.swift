//
//  BannerView.swift
//  QYXBannerView
//
//  Created by 邱云翔 on 2019/6/30.
//  Copyright © 2019 邱云翔. All rights reserved.
//

//五个视图进行重用

import UIKit

/* scrollerView在bannerView上的位置设置 */
let scrollViewEdges = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 50)

class BannerView: UIView,UIScrollViewDelegate {
    
    /* 背景滑动视图 */
    var scrollView : UIScrollView? //滑动视图
    
    /* 原始数据源 */
    @objc dynamic var bannerOriginalDataArray : Array<Any>? //
    
    /* 处理后的数据，真实用到的数据源 */
    lazy private var bannerDataArray : Array<Any>? = {
        return Array<Any>()
    }()
    
    /* 视图数组，生成的视图放入这个数组中 */
    lazy var bannerViewArray : Array<BannerOfCustomerView> = {
        return Array<BannerOfCustomerView>()
    }()
    
    /* 当前下标 */
    var currentIndex : NSInteger = 0 //
    
    /* 计时器 */
    var timer : Timer?
    
    /* 初始化 */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpThings() //其他事物
        self.setUpViews() //视图
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* 设置基础事务 */
    func setUpThings() {
        //
        self.currentIndex = 0
        
        //添加观察者用来处理数组的变化，适应小于5张的情况
        self.addObserver(self, forKeyPath: "bannerOriginalDataArray", options: .new , context: nil)
        
        //添加计时器
        self.timer = Timer.init(timeInterval: 5, repeats: true, block: {[weak self] (timer) in
            UIView.animate(withDuration: 0.4, animations: {
                self?.scrollView?.setContentOffset(CGPoint.init(x: self!.scrollView!.bounds.size.width + self!.scrollView!.contentOffset.x, y: 0), animated: false)
            }, completion: { (complet) in
                self?.scrollViewDidEndDecelerating(self!.scrollView!)
            })
        })
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.common)
        self.timer?.fire()
    }
    
    /* 设置视图 */
    func setUpViews() {
        
        //设置背景scrollerView
        self.scrollView = UIScrollView.init(frame: CGRect.init(x: scrollViewEdges.left, y: scrollViewEdges.top, width: self.bounds.size.width - scrollViewEdges.left - scrollViewEdges.right, height: self.bounds.size.height - scrollViewEdges.top - scrollViewEdges.bottom))
        self.scrollView?.bounces = false //关闭回弹便于计算
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.clipsToBounds = false //这个属性使我们能看到左右两张
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.contentSize = CGSize.init(width: self.scrollView!.bounds.size.width*5, height: self.scrollView!.bounds.size.height)
        self.scrollView?.delegate = self
        self.scrollView?.setContentOffset(CGPoint.init(x: self.scrollView!.bounds.size.width * 2, y: 0), animated: false)
        self.addSubview(self.scrollView!)
        
        //设置五个视图
        let scrollSize = self.scrollView?.bounds.size
        for i in 0...4 {
            let bannerItemView = BannerOfCustomerView.init(frame: CGRect.init(x: CGFloat(i) * scrollSize!.width, y: 0, width: scrollSize!.width, height: scrollSize!.height))
            bannerItemView.clipsToBounds = false
            self.scrollView?.addSubview(bannerItemView)
            self.bannerViewArray.append(bannerItemView)
        }
    }
    
    /* 观察者回调 */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bannerOriginalDataArray" {
            if self.bannerOriginalDataArray != nil {
                if self.bannerOriginalDataArray!.count < 5 {
                    //低于5张图片时处理数据
                    self.bannerDataArray?.removeAll()
                    guard self.bannerOriginalDataArray!.count != 0 else {
                        //0个时表示无数据
                        return
                    }
                    for i in 0...4 {
                        self.bannerDataArray?.append(self.bannerOriginalDataArray![i%self.bannerOriginalDataArray!.count])
                    }
                } else {
                    self.bannerDataArray?.removeAll()
                    self.bannerDataArray?.append(contentsOf: self.bannerOriginalDataArray!)
                }
            }
        }
    }
    
    /* UIScrollViewDelegate */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.bannerDataArray?.count == 0 {
            self.timer?.fireDate = Date.distantFuture
            return
        }
        
        //关闭回弹便于此处计算
        if scrollView.contentOffset.x == 0 {
            self.currentIndex-=2
        } else if scrollView.contentOffset.x == scrollView.bounds.size.width {
            self.currentIndex-=1
        } else if scrollView.contentOffset.x == scrollView.bounds.size.width * 3 {
            self.currentIndex+=1
        } else if scrollView.contentOffset.x == scrollView.bounds.size.width * 4 {
            self.currentIndex+=2
        }
        
        //防止数组越界
        self.currentIndex = self.safeNumber(index: self.currentIndex)
        let leftMostIndex = self.safeNumber(index: self.currentIndex - 2)
        let leftIndex = self.safeNumber(index: self.currentIndex - 1)
        let rightIndex = self.safeNumber(index: self.currentIndex + 1)
        let rightMostIndex = self.safeNumber(index: self.currentIndex + 2)
        
        //此处赋值，颜色只用来做测试效果
        let indexArray : Array<NSInteger> = [leftMostIndex,leftIndex,self.currentIndex,rightIndex,rightMostIndex]
        let colorArray = self.bannerDataArray as! Array<UIColor>
        for i in 0...4 {
            self.bannerViewArray[i].backView?.backgroundColor = colorArray[indexArray[i]]
        }
        
        //赋值完毕之后立刻调整为中间视图
        self.scrollView?.setContentOffset(CGPoint.init(x: self.scrollView!.bounds.size.width*2, y: 0), animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.timer != nil {
            self.timer?.fireDate = Date.distantFuture
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //设置3秒之后启动
        self.timer?.fireDate = Date.init(timeInterval: 3, since: Date.init())
    }
    
    /* 保证数组不越界 */
    func safeNumber(index:NSInteger) -> NSInteger {
        switch index {
        case self.bannerDataArray?.count:
            return 0
        case self.bannerDataArray!.count + 1:
            return 1
        case -1:
            return self.bannerDataArray!.count - 1
        case -2:
            return self.bannerDataArray!.count - 2
        default:
            return index
        }
    }
    
    /* 处理超出区域的滑动 */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            var newPoint = CGPoint.init(x: 0, y: 0)
            newPoint.x = point.x - self.scrollView!.frame.origin.x + self.scrollView!.contentOffset.x
            newPoint.y = point.y - self.scrollView!.frame.origin.y + self.scrollView!.contentOffset.y
            if self.scrollView!.point(inside: newPoint, with: event) {
                return self.scrollView!.hitTest(newPoint, with: event)
            }
            return self.scrollView
        }
        return nil
    }
    
    /* 启动 */
    public func start() {
        self.scrollViewDidEndDecelerating(self.scrollView!)
    }
    
    /* 销毁 */
    deinit {
        self.timer?.invalidate()
        self.removeObserver(self, forKeyPath: "bannerOriginalDataArray")
    }
}
