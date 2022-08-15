//
//  TopPageViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
protocol TopPageViewControllerDelegate: AnyObject {
    func payAction(_ viewController: TopPageViewController)
    func parkingAction(_ viewController: TopPageViewController)
}

class TopPageViewController: UIViewController {
    @IBOutlet weak var bannerScrollView: UIScrollView!
    @IBOutlet weak var bannerStack: UIStackView!
    @IBOutlet weak var bannerPageControl: UIPageControl!
    
    @IBAction func bannerPageChangeAction(_ sender: UIPageControl) {
        let point = CGPoint(x: bannerScrollView.bounds.width * CGFloat(sender.currentPage), y: 0)
        bannerScrollView.setContentOffset(point, animated: true)
    }
    @IBAction func payAction(_ sender: Any) {
        delegate?.payAction(self)
    }
    @IBAction func shopAction(_ sender: Any) {
        let schemeStr = "beipu://"
        let urlStr = "https://apps.apple.com/app/id1636198260"
        if let url = URL(string: schemeStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else if let url = URL(string: urlStr){
            UIApplication.shared.open(url)
        }
    }
    @IBAction func parkingAction(_ sender: Any) {
        delegate?.parkingAction(self)
    }
    @IBAction func healthAction(_ sender: Any) {
        let schemeStr = "healthmanage://"
        let urlStr = "https://apps.apple.com/app/id1610454916"
        if let url = URL(string: schemeStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else if let url = URL(string: urlStr){
            UIApplication.shared.open(url)
        }
    }

    weak var delegate: TopPageViewControllerDelegate?
    var bannerList = [Banner](){
        didSet{
            for banner in self.bannerList {
                banner.renewImage = { [weak self] in
                    self?.readScroll()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        自動輪播圖片時間
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
        bannerScrollView.delegate = self
        fetchBanner()
    }
    
    @objc func scroll(){
//        輪播圖片
        if bannerPageControl.currentPage == bannerPageControl.numberOfPages-1 {
            bannerPageControl.currentPage = 0
        }else {
            bannerPageControl.currentPage += 1
        }
        bannerPageChangeAction(bannerPageControl)
    }
    
    func fetchBanner(){
        let url = API_URL + URL_BANNERLIST
        WebAPI.shared.request(urlString: url, parameters: "") { isSuccess, data, error in
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {return}
            var banners = [Banner]()
            for result in results{
                let banner = Banner(from: result)
                banners.append(banner)
            }
            self.bannerList = banners
        }
    }
    
    func readScroll(){
//        移除輪播圖原有圖片
        for subview in bannerStack.subviews{
            subview.removeFromSuperview()
        }
//        加入輪播圖
        for banner in bannerList {
            let imageView = UIImageView(frame: bannerScrollView.bounds)
            imageView.image = banner.banner_picture
            imageView.contentMode = .scaleAspectFill
//            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
//            let ratio = banner.banner_picture.size.width / banner.banner_picture.size.height
//            let height = UIScreen.main.bounds.width - 30 / ratio
//            imageView.frame.size = CGSize(width: UIScreen.main.bounds.width - 30, height: height > 180 ? 180: height)
            bannerStack.addArrangedSubview(imageView)
            if bannerStack.arrangedSubviews.count == 1{
                imageView.widthAnchor.constraint(equalTo: bannerScrollView.frameLayoutGuide.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: bannerScrollView.frameLayoutGuide.heightAnchor).isActive = true
            }
        }
//        設定小圓點
        bannerPageControl.numberOfPages = bannerStack.arrangedSubviews.count
    }
}

extension TopPageViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        設定拖曳輪播頁面時更新小圓點
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        bannerPageControl.currentPage = Int(page)
    }
}
