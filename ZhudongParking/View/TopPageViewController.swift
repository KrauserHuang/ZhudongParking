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

enum MainPageItem {
    case payForParking
    case parkingInfo
    case toBeipu
    case toHealthManagement
}

extension MainPageItem: CaseIterable {
    var imageName: String {
        switch self {
        case .payForParking: return "payment"
        case .parkingInfo: return "park"
        case .toBeipu: return "cart"
        case .toHealthManagement: return "health"
        }
    }
    var title: String {
        switch self {
        case .payForParking: return "停車繳費"
        case .parkingInfo: return "停車資訊"
        case .toBeipu: return "在地好康"
        case .toHealthManagement: return "健康速檢"
        }
    }
    var backgroundColor: UIColor {
        switch self {
        case .payForParking:
            return UIColor.convertHexStringToUIColor(hexString: "81D3F8")
        case .parkingInfo:
            return UIColor.convertHexStringToUIColor(hexString: "FF7878")
        case .toBeipu:
            return UIColor.convertHexStringToUIColor(hexString: "D3A4FF")
        case .toHealthManagement:
            return UIColor.convertHexStringToUIColor(hexString: "FFB326")
        }
    }
}

class TopPageViewController: UIViewController {
    
    @IBOutlet weak var bannerScrollView: UIScrollView!
    @IBOutlet weak var bannerStack: UIStackView!
    @IBOutlet weak var bannerPageControl: UIPageControl!
    
    @IBAction func bannerPageChangeAction(_ sender: UIPageControl) {
        let point = CGPoint(x: bannerScrollView.bounds.width * CGFloat(sender.currentPage), y: 0)
        bannerScrollView.setContentOffset(point, animated: true)
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
    enum Section {
        case all
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MainPageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MainPageItem>
    
    private lazy var dataSource = configureDataSource()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createGridLayout())
        collectionView.delegate = self
        collectionView.register(UINib(nibName: MainPageCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: MainPageCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    let mainPageItems = MainPageItem.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

//        自動輪播圖片時間
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
        bannerScrollView.delegate = self
        fetchBanner()
        configureCollectionView()
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
extension TopPageViewController {
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: bannerScrollView.bottomAnchor,
                              left: view.leftAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              right: view.rightAnchor)
        collectionView.dataSource = dataSource
        updateSnapshot()
        collectionView.isScrollEnabled = false
    }
    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainPageCollectionViewCell.reuseIdentifier, for: indexPath) as! MainPageCollectionViewCell
            
            print(self, #function)
            print(itemIdentifier)
            cell.configure(with: itemIdentifier)
            
            return cell
        }
        return dataSource
    }
    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.all])
        snapshot.appendItems(mainPageItems, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    func createGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5,
//                                                     leading: 5,
//                                                     bottom: 5,
//                                                     trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
// MARK: - UICollectionViewDelegate
extension TopPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .payForParking:
            delegate?.payAction(self)
        case .parkingInfo:
            delegate?.parkingAction(self)
        case .toBeipu:
//            let schemeStr = "beipu://"
//            let urlStr = "https://apps.apple.com/app/id1636198260"
//            if let url = URL(string: schemeStr), UIApplication.shared.canOpenURL(url) { //跳轉app
//                UIApplication.shared.open(url)
//            } else if let url = URL(string: urlStr) { //跳轉App Store
//                UIApplication.shared.open(url)
//            }
            let vc = WKWebViewController()
            vc.urlStr = "https://hcparking.jotangi.net/parking_web/index.php"
            vc.setNavigationTitle("在地好康")
            self.navigationController?.pushViewController(vc, animated: true)
        case .toHealthManagement:
            let schemeStr = "healthmanage://"
            let urlStr = "https://apps.apple.com/app/id1610454916"
            if let url = URL(string: schemeStr), UIApplication.shared.canOpenURL(url) { //跳轉app
                UIApplication.shared.open(url)
            } else if let url = URL(string: urlStr) { //跳轉App Store
                UIApplication.shared.open(url)
            }
        }
    }
}
