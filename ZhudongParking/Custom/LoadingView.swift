//
//  LoadingView.swift
//
//  Created by 陳Mike on 2021/8/1.
//

import UIKit

class LoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    let backView = UIView()
    private let mainView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
    private let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 30)))
    private var countDownTimer: Timer?
    private var countDownValue = 0.0
    private var tempCount = 0.0
//    計時結束執行
    private var completion: (()->()) = {}
    
    private func setView(){
        backView.backgroundColor = .clear
        self.backgroundColor = .clear
        mainView.center = self.center
        mainView.backgroundColor = .black
        mainView.alpha = 0.4
        mainView.layer.cornerRadius = 5
        self.addSubview(mainView)
        let actView = UIActivityIndicatorView()
        if #available(iOS 13, *) {
            actView.style = .large
        }else{
            actView.style = .whiteLarge
        }
        actView.startAnimating()
        actView.hidesWhenStopped = true
        actView.center = self.center
        self.addSubview(actView)
    }
    func setLabel(wait sec: Int, completion: (()->())?){
//        新增計數Label
        guard sec > 0 else{return}
        label.textAlignment = .center
        addSubview(label)
        label.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalToSystemSpacingAfter: mainView.centerXAnchor, multiplier: 1).isActive = true
        countDownValue = Double(sec)
        self.completion = completion ?? {}
    }
    @objc private func countDown(){
        guard tempCount < countDownValue else{
//            停止計數
            countDownTimer?.invalidate()
            completion()
//            清空closure
            completion = {}
            return}
        DispatchQueue.main.async {
            self.label.text = "正在讀取中...\(Int(self.tempCount / self.countDownValue * 100))%"
//            每2%數一次
            self.tempCount += self.countDownValue / 50
        }
    }
    
//    加入畫面
    func setup(to view: UIWindow) {
        self.center = CGPoint(x: view.center.x, y: view.center.y)
        backView.frame = view.bounds
        view.addSubview(backView)
        view.addSubview(self)
        if countDownValue > 0 {
//            每2%進行一次
            countDownTimer = Timer.scheduledTimer(timeInterval: self.countDownValue / 50, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        }
//        countDownTimer.fire()
    }
//    移除畫面
    func removeView() {
        countDownTimer?.invalidate()
        backView.removeFromSuperview()
        self.removeFromSuperview()
    }
}


extension UIWindow {
//    加入讀取動畫
    func loadingAction(wait sec: Int = 0, completion: (()->())? = nil){
        DispatchQueue.main.async {
            let loading = LoadingView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)))
            loading.setLabel(wait: sec, completion: completion)
            loading.setup(to: self)
        }
    }
//    移除讀取動畫
    func finishLoading(){
        DispatchQueue.main.async {
            for view in self.subviews {
                if let loading = view as? LoadingView {
                    loading.removeView()
                }
            }
        }
    }
}

let RootWindow = UIApplication.shared.windows.first
