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
    var _countWorkloadNumberLabel:UILabel!
    
    var _countDownNum:Int = 24 * 60
    var _circleView:UIView!
    var startedAt:NSDate = NSDate()
    
    var workload = PFObject(className: "Workload")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        PFUser.logInWithUsernameInBackground("GOUurfrwHyvBimJEsLVFugyxb", password:"testpass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                // save Accesslog
                let accessLog = PFObject(className: "Accesslog")
                accessLog["url"] = "iOS"
                accessLog["user"] = PFUser.currentUser()
                accessLog.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Accesslog Object has been created.")
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
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:100)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        

        _countWorkloadNumberLabel = UILabel(frame: CGRectMake(0, 150, self.view.frame.width, self.view.frame.height))
        _countWorkloadNumberLabel.font = UIFont(name: "HelveticaNeue", size: 54)
        _countWorkloadNumberLabel.textAlignment = NSTextAlignment.Center
        _countWorkloadNumberLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.view.addSubview(_countWorkloadNumberLabel)

        
        // カウントダウン数値ラベル設定
        _countNumberLabel = UILabel(frame: CGRectMake(0, -100, self.view.frame.width, self.view.frame.height))
        _countNumberLabel.font = UIFont(name: "HelveticaNeue", size: 54)
        _countNumberLabel.textAlignment = NSTextAlignment.Center
        _countNumberLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.view.addSubview(_countNumberLabel)
        
        _circleView = UIView(frame : CGRectMake((self.view.frame.width/2)-100, (self.view.frame.height/2)-200, 200, 200))
        _circleView.layer.addSublayer(drawCircle(_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.2)))
        _circleView.layer.addSublayer(drawCircle(_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0)))
        
        _countNumberLabel.hidden = true
        _circleView.hidden = true
        self.view.addSubview(_circleView)
        
        initWorkload()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func onClickMyButton(sender: UIButton){
        self.workload.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Workload Object has been updated in onClick.")
        }
        
        myButton.hidden = true
        _countNumberLabel.hidden = false
        _circleView.hidden = false
        
        startedAt = NSDate()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("everySecond:"), userInfo: nil, repeats: true)
        self.circleAnimation(self._circleView.layer.sublayers![1] as! CAShapeLayer)
        
    }
    
    func drawCircle(viewWidth:CGFloat, strokeColor:UIColor) -> CAShapeLayer {
        let circle:CAShapeLayer = CAShapeLayer()
        let lineWidth: CGFloat = 20
        let viewScale: CGFloat = viewWidth
        let radius: CGFloat = viewScale - lineWidth
        circle.path = UIBezierPath(roundedRect: CGRectMake(0, 0, radius, radius), cornerRadius: radius / 2).CGPath
        circle.position = CGPointMake(lineWidth / 2, lineWidth / 2)
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = strokeColor.CGColor
        circle.lineWidth = lineWidth
        return circle   }
    
    func circleAnimation(layer:CAShapeLayer) {
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.setValue(layer, forKey:"animationLayer")
        drawAnimation.delegate = self
        drawAnimation.duration = 24 * 60.0
        drawAnimation.repeatCount = 1.0
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.addAnimation(drawAnimation, forKey: "circleAnimation")
    }
    
    func everySecond(timer: NSTimer) {
        let now = NSDate()
        //_countDownNum = 24 * 60 - Int(now.timeIntervalSinceDate(startedAt))
        _countDownNum = 5 - Int(now.timeIntervalSinceDate(startedAt))
        
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
        
        //print(String(_min2 + " : " + _sec2));
        
        _countNumberLabel.text = String(_min2 + " : " + _sec2)
        
        if _countDownNum <= 0 {
            complete(timer)
        }
    }
    
    func initWorkload() {
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
        let midnight: NSDate? = formatter.dateFromString(dateStr)
        query.whereKey("createdAt", greaterThan: midnight!)
        query.whereKey("user", equalTo:PFUser.currentUser()!)
        query.whereKey("is_done", equalTo:true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                self.workload["number"] = objects!.count + 1
                self._countWorkloadNumberLabel.text = "本日" + (objects!.count + 1).description + "回目"
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func complete(timer: NSTimer) {
        myButton.hidden = false
        _countNumberLabel.hidden = true
        _circleView.hidden = true
        
        timer.invalidate()
        
        workload["is_done"] = true
        workload.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Workload Object has been updated in complete.")
            var workload = PFObject(className: "Workload")
            self.startedAt = NSDate()
            self.initWorkload()
        }
        
        
        //次の画面へ遷移(navigationControllerの場合)
        let commentsViewController = CommentsViewController()
        self.navigationController?.pushViewController(commentsViewController, animated: false)
    }

    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let layer:CAShapeLayer = anim.valueForKey("animationLayer") as! CAShapeLayer
    }
}
