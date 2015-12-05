/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    private var myButton: UIButton!
    
    var _countNumberLabel:UILabel!
    let _countDownMax:Int = 24 * 60
    var _countDownNum:Int = 24 * 60
    var _circleView:UIView!
    let workload = PFObject(className: "Workload")
    
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        PFUser.logInWithUsernameInBackground("GOUurfrwHyvBimJEsLVFugyxb", password:"testpass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                // save Accesslog
                let accessLog = PFObject(className: "Accesslog")
                accessLog["url"] = "iOS"
                accessLog["user"] = PFUser.currentUser()
                accessLog.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
                print("logged in!")
                // Do stuff after successful login.
            } else {
                // The login failed. Check error to see why.
            }
        }
        
        // show start button
        myButton = UIButton()
        myButton.frame = CGRectMake(0,0,200,40)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        
        myButton.setTitle("無音で24分集中！", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        myButton.setTitle("Let's Start !!", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
        
        // カウントダウン数値ラベル設定
        _countNumberLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        _countNumberLabel.font = UIFont(name: "HelveticaNeue", size: 54)
        // 中心揃え
        _countNumberLabel.textAlignment = NSTextAlignment.Center
        _countNumberLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.view.addSubview(_countNumberLabel)
        
        _circleView = UIView(frame : CGRectMake((self.view.frame.width/2)-100, (self.view.frame.height/2)-100, 200, 200))
        _circleView.layer.addSublayer(drawCircle(_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.2)))
        _circleView.layer.addSublayer(drawCircle(_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0)))
        
        _countNumberLabel.hidden = true
        _circleView.hidden = true
        self.view.addSubview(_circleView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func onClickMyButton(sender: UIButton){
        myButton.hidden = true
        _countNumberLabel.hidden = false
        //_circleView.hidden = false
        
        // insert Workload
        workload["user"] = PFUser.currentUser()
        let iconUrl = "https://graph.facebook.com/10152403406713381/picture?height=40&width=40"
        workload["icon_url"] = iconUrl
        
        let query = PFQuery(className:"Workload")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(name: "JST")
        
        let date:NSDate = NSDate()
        
        let dateStr: String = formatter.stringFromDate(date)
        //let dateStr: String = "2015-12-6"
        
        
        
        let midnight: NSDate? = formatter.dateFromString(dateStr)

        
        print(midnight)
        query.whereKey("createdAt", greaterThan: midnight!)
        query.whereKey("user", equalTo:PFUser.currentUser()!)
        query.whereKey("is_done", equalTo:true)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                
                
                self.workload["number"] = objects!.count + 1
                
                self.workload.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
                
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    
    // 遷移毎に実行
    override func viewWillAppear(animated: Bool) {
        // 数値をリセット
        _countDownNum = _countDownMax
        _countNumberLabel.text = String(_countDownNum)
        // アニメーション開始
        circleAnimation(_circleView.layer.sublayers![1] as! CAShapeLayer)
    }
    
    func drawCircle(viewWidth:CGFloat, strokeColor:UIColor) -> CAShapeLayer {
        let circle:CAShapeLayer = CAShapeLayer()
        // ゲージ幅
        let lineWidth: CGFloat = 20
        // 描画領域のwidth
        let viewScale: CGFloat = viewWidth
        // 円のサイズ
        let radius: CGFloat = viewScale - lineWidth
        // 円の描画path設定
        circle.path = UIBezierPath(roundedRect: CGRectMake(0, 0, radius, radius), cornerRadius: radius / 2).CGPath
        // 円のポジション設定
        circle.position = CGPointMake(lineWidth / 2, lineWidth / 2)
        // 塗りの色を設定
        circle.fillColor = UIColor.clearColor().CGColor
        // 線の色を設定
        circle.strokeColor = strokeColor.CGColor
        // 線の幅を設定
        circle.lineWidth = lineWidth
        return circle   }
    
    func circleAnimation(layer:CAShapeLayer) {
        // アニメーションkeyを設定
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // callbackで使用
        drawAnimation.setValue(layer, forKey:"animationLayer")
        // callbackを使用する場合
        drawAnimation.delegate = self
        // アニメーション間隔の指定
        drawAnimation.duration = 1.0
        // 繰り返し回数の指定
        drawAnimation.repeatCount = 1.0
        // 起点と目標点の変化比率を設定 (0.0 〜 1.0)
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        // イージング設定
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.addAnimation(drawAnimation, forKey: "circleAnimation")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let layer:CAShapeLayer = anim.valueForKey("animationLayer") as! CAShapeLayer
        _countDownNum--
        // 表示ラベルの更新
        
        let _min:Int = _countDownNum / 60
        let _sec:Int = _countDownNum - _min * 60
        
        var _min2:String = _min.description
        var _sec2:String = _sec.description
        
        if _min < 10 {
            _min2 = "0" + _min2
        }
        if _sec < 10 {
            _sec2 = "0" + _sec2
        }
        
        _countNumberLabel.text = String(_min2 + " : " + _sec2)
        
        if _countDownNum <= 0 {
            
            workload["is_done"] = true
            workload.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                print("Object has been saved.")
            }
            
            
            //次の画面へ遷移(navigationControllerの場合)
            //let nextViewController:ViewController = ViewController()
            //self.navigationController?.pushViewController(nextViewController, animated: false)
            
        } else {
            circleAnimation(layer)
        }
    }
    
}
