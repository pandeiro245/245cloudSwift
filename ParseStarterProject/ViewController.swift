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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // save Accesslog
        let accessLog = PFObject(className: "Accesslog")
        accessLog["url"] = "iOS"
        accessLog.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
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
        self.view.addSubview(_circleView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func onClickMyButton(sender: UIButton){
        myButton.hidden = true
        print("onClickMyButton:")
        print("sender.currentTitile: \(sender.currentTitle)")
        print("sender.tag:\(sender.tag)")
        
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
        var circle:CAShapeLayer = CAShapeLayer()
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
        var drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
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
        _countNumberLabel.text = String(_countDownNum)
        
        if _countDownNum <= 0 {
            //次の画面へ遷移(navigationControllerの場合)
            //let nextViewController:ViewController = ViewController()
            //self.navigationController?.pushViewController(nextViewController, animated: false)
            
        } else {
            circleAnimation(layer)
        }
    }
    
}
