//
//  MeViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DynamicColor

@objc
extension LabelView {
    
    @objc
    func setSex(_ user: User) {
        switch user.sex {
        case .male:
            image = UIImage(named: "me-sex-man")
            colors = [UIColor(hexString: "#7854EE"), UIColor(hexString: "#2C6AF5")]
        default:
            image = UIImage(named: "me-sex-woman")
            colors = [UIColor(hexString: "#FEB21F"), UIColor(hexString: "#F73E74")]
        }
        text = user.age.description
    }

}


extension UIButton {
    @objc
    func setVIP(_ vipType: VipType) {
       isHidden = vipType.isHidden
       setImage(vipType.image, for: .normal)
    }
}


typealias TappedAction  = () -> Void


extension UIRectCorner {
    
    
    var maskedCorners: CACornerMask {
        switch self {
        case .topLeft:
        return .layerMinXMinYCorner
        case .topRight:
            return .layerMaxXMinYCorner
        case .bottomLeft:
            return .layerMinXMaxYCorner
        case .bottomRight:
            return .layerMaxXMaxYCorner
        case .allCorners:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            return []
        }
    }
}

class InsetGroupedCell: UITableViewCell {
    
    override var frame: CGRect {
        get {
            super.frame
        }
        set {
            super.frame = newValue.insetBy(dx: 20, dy: 0)
        }
    }
    
    var rectCorner: UIRectCorner = []

    override func layoutSubviews() {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: rectCorner,
            cornerRadii: CGSize(width: 10, height: 10))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer

        super.layoutSubviews()
    }
}

class RightDetailFormEntry: FormEntry {

    let image: UIImage?
    let text: String
    let detailText: String?
    let onTapped: TappedAction?
    let accessoryView: UIView?
    
    
    init(image: UIImage?, text: String, detailText: String? = nil, accessoryView: UIView? = nil, onTapped: TappedAction? = nil) {
        self.image = image
        self.text = text
        self.detailText = detailText
        self.accessoryView = accessoryView
        self.onTapped = onTapped
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        
        cell.imageView?.image = image
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        cell.accessoryView = accessoryView
        
        return cell
    }
}

class WalletFormEntry: FormEntry {
    
    let image: UIImage?
    let text: String
    let energy: String
    let tCoin: String
    let onTapped: TappedAction?
    init(image: UIImage?, text: String, energy: String, tCoin: String, onTapped: TappedAction? = nil) {
        self.image = image
        self.text = text
        self.energy = energy
        self.tCoin = tCoin
        self.onTapped = onTapped
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletViewCell.self)
        cell.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        cell.iconImageView.image = image
        cell.titleLabel.text = text
        cell.energyLabel.text = energy
        cell.tCoinLabel.text = tCoin
        return cell
    }
}


class MeViewController: UITableViewController, Autorotate, IndicatorDisplay {
    
    enum Section: Int {
        case wallet
        case gameplay
        case paly
        
        var imageView: UIImageView? {
            switch self {
            case .wallet:
                return nil
            default:
                let image = UIImage(named: "arrow-right-gray")
                let imageView = UIImageView(image: image)
                return imageView
            }
        }
        
    }
    
    
    @IBOutlet weak var meHeaderView: MeHeaderView!
    
    
    let userAPI = Request<UserAPI>()
    
    let consumerAPI = Request<ConsumerAPI>()
        
    private var earning: EarningMonthPreview?
    
    private var sections: [FormSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarBackgroundImage =  UIImage(color: UIColor(hexString: "#F6F7F9"), size: self.navigationController!.navigationBar.bounds.size)
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, for: .normal)
        
        tableView.backgroundColor = UIColor(hexString: "#F6F7F9")
        tableView.sectionHeaderHeight = 10
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        
        setDisplay()
        
        NotificationCenter.default.rx.notification(.userDidChange)
            .subscribe(onNext: { [weak self] _ in
                self?.setDisplay()
            })
            .disposed(by: rx.disposeBag)

    }
    
    
    func setDisplay() {
        refreshDisplay()
        setupSections()
    }
    
    func setupSections()  {
        
        let user = LoginManager.shared.user!
        
       var userEntrys: [FormEntry] = []
        
       userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-vip"), text: "购买VIP", onTapped: pushVip))
        
        let visitorList = user.visitorList.compactMap{ $0["headPic"] as? String }
        
        if visitorList.isEmpty {
            userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-visitor"), text: "我的访客", onTapped: pushVisitor))
        }
        else {
            
            let accessoryView: VisitorsAvatarView  = VisitorsAvatarView.loadFromNib()
            
            accessoryView.countLabel.text = "+\(user.visitorNum)"
            
            accessoryView.avatarStackView.subviews.forEach { view in
                accessoryView.avatarStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            let imageViews = visitorList
                .map { url -> UIImageView in
                    let imageView = UIImageView(frame: .zero)
                    imageView.kf.setImage(with: URL(string: url))
                    return imageView
                }
            
            imageViews.forEach { imageView in
                accessoryView.avatarStackView.addArrangedSubview(imageView)
                imageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
                imageView.layer.cornerRadius = 17
                imageView.clipsToBounds = true
            }
//            let size = accessoryView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            accessoryView.frame = CGRect(origin: .zero, size: CGSize(width: 150, height: 34))
            accessoryView.setNeedsLayout()
            accessoryView.layoutIfNeeded()
            userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-visitor"), text: "我的访客", accessoryView: accessoryView, onTapped: pushVisitor))
        }
        
        if user.sex == .female {
            userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-anchor"), text: "主播认证", onTapped: pushAuthentication))
        }
        
        if user.sex == .male {
            userEntrys.append( RightDetailFormEntry(image: UIImage(named: "me-authentication"), text: "用户认证", onTapped: pushAuthentication))
        }
        

        if !AppAudit.share.gradeStatus {
            userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-grade"), text: "我的等级", onTapped: pushLevel))
        }
        
        userEntrys.append(RightDetailFormEntry(image: UIImage(named: "my-invite"), text: "我的邀请", onTapped: pushInvite))
        
        userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-money"), text: "任务奖励", onTapped: pushTask))
        
        if user.girlStatus {
            userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-charge"), text: "收费中心", onTapped: pushCharge))
        }
        
        userEntrys.append(RightDetailFormEntry(image: UIImage(named: "me-help"), text: "帮助中心", onTapped: pushHelp))
        
       let userSection =  FormSection(
            entries: userEntrys,
            headerText: nil
        )
        
        self.sections = [userSection]
        
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    func requestData() {
        
        userAPI.request(.userinfo(userId: nil), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                LoginManager.shared.update(user: response.data!)
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
        
        if LoginManager.shared.user!.girlStatus {
            consumerAPI.request(.countMonthProfit, type: Response<EarningMonthPreview>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [weak self] response in
                    self?.earning = response.data
                    self?.setupSections()
                }, onError: nil)
                .disposed(by: rx.disposeBag)
        }
        else {
            userAPI.request(.userWallet, type: Response<Wallet>.self)
                .verifyResponse()
                .subscribe(onSuccess: { response in
                    let user = LoginManager.shared.user!
                    user.userTanbi = response.data!.userTanbi
                    user.userEnergy = response.data!.userEnergy
                    LoginManager.shared.update(user: user)
                }, onError: { error in
                    
                })
                .disposed(by: rx.disposeBag)
        }
    }
    
    
    func refreshDisplay() {
        
        let user = LoginManager.shared.user!
        
        meHeaderView.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        meHeaderView.nicknameLabel.text = user.nick
        meHeaderView.userIDLabel.text = user.userId
        meHeaderView.sexButton.set(user)
        meHeaderView.vipButton.setVIP(user.vipType)
        meHeaderView.vipButton.isHidden = false
        
        meHeaderView.followButton.titleLabel?.numberOfLines = 2
        meHeaderView.fansButton.titleLabel?.numberOfLines = 2
        meHeaderView.followButton.setAttributedTitle(number(number: user.userFollowNum, text: "关注"), for: .normal)
        meHeaderView.fansButton.setAttributedTitle(number(number: user.userFansNum, text: "粉丝"), for: .normal)
        meHeaderView.gradeView.setGrade(user)
        
        meHeaderView.energyLabel.text = user.userEnergy.description
        meHeaderView.coinLabel.text = user.userTanbi.description
        meHeaderView.earningButton.isHidden = !user.girlStatus
                
        meHeaderView.setNeedsLayout()
        meHeaderView.layoutIfNeeded()
    }
    
    func number(number: Int, text: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(NSAttributedString(string: number.description,
                                                 attributes: [
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
                                                    NSAttributedString.Key.foregroundColor : UIColor(hexString: "#333333")
                                                 ]))
        
        attributedText.append(NSAttributedString(string: "\n\(text)",
                                                 attributes: [
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .regular),
                                                    NSAttributedString.Key.foregroundColor : UIColor(hexString: "#999999")
                                                 ]))
        
        attributedText.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
        
        return attributedText
    }
    
    @IBAction func pushLevel() {
        let vc = WebViewController.H5(path: "index/index/level")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushVisitor() {
        
        if LoginManager.shared.user!.vipType != .empty || LoginManager.shared.user!.girlStatus {
            let vc = VisitorsController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = VisitorsVipController()
            vc.user = LoginManager.shared.user!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func copyUserID(_ sender: UIButton) {
        
        UIPasteboard.general.string = LoginManager.shared.user?.userId
        
        showMessageOnWindow("复制成功")
    }
    
    @IBAction func pushInvite() {
        let vc = WebViewController.H5(path: "index/index/myintive")
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func pushTask()   {
        let vc = WebViewController.H5(path: "h5/sign")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushCharge() {
        let vc = ChargeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushVip() {
        
        let vc = WebViewController.H5(path: "h5/vip")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushAuthentication() {
        let vc = AuthenticationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushWallet()  {
        let vc = WalletViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushEarnings() {
        let vc = EarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushHelp() {
        let vc = WebViewController.H5(path: "h5/help")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushSetting() {
        
        let vc = SettingViewController.loadFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
            
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].formEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let inserCell = cell  as? InsetGroupedCell else { return  }
        
        if self.tableView(tableView, numberOfRowsInSection: indexPath.section) == 1 {
            
            inserCell.rectCorner = .allCorners
        }
        else if indexPath.row == 0 {
            inserCell.rectCorner = [.topLeft, .topRight]
        }
        else if indexPath.row == (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
            inserCell.rectCorner = [.bottomLeft, .bottomRight]
        }
        else {
            inserCell.rectCorner = []
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let wallet = sections[indexPath.section].formEntries[indexPath.row] as? WalletFormEntry {
            wallet.onTapped?()
        }
        else if let rightDetail =  sections[indexPath.section].formEntries[indexPath.row] as? RightDetailFormEntry {
            rightDetail.onTapped?()
        }
    }
    
    fileprivate func config(cell: UITableViewCell, for indexPath: IndexPath) {
        cell.accessoryView = Section(rawValue: indexPath.section)?.imageView
    }
    
    
    @IBAction func followButtonDidTap(_ sender: Any) {
        let meContact = MeContactViewController(show: .follow)
        navigationController?.pushViewController(meContact, animated: true)
    }
    
    @IBAction func fansButtonDidTap(_ sender: Any) {
        let meContact = MeContactViewController(show: .fans)
        navigationController?.pushViewController(meContact, animated: true)
    }
    
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? UserInfoViewController {
            vc.user = LoginManager.shared.user
        }
        
    }
}


extension VipType: CustomStringConvertible {
    
    var description: String {
        
        switch self {
        case.empty:
            return ""
        case .month:
            return "VIP"
        case .quarter:
            return "季VIP"
        case .year:
            return "年VIP"
        case .experience:
            return "体验VIP"
        }
    }
    
    var image: UIImage? {
        switch self {
        case.empty:
            return UIImage(named: "vip-disabled")
        case .month:
            return UIImage(named: "vip-month")
        case .quarter:
            return UIImage(named: "vip-quarter")
        case .year:
            return UIImage(named: "vip-year")
        case .experience:
            return UIImage(named: "vip-experience")
        }
    }
    
    var isHidden: Bool {
        switch self {
        case.empty:
            return true
        default:
            return false
        }
    }
    
    var textColor: UIColor {
        switch self {
        case.empty:
            return UIColor(hexString: "#333333")
        default:
            return UIColor(hexString: "#F1AC23")
        }
    }
    
    var nameTextColor: UIColor {
        switch self {
        case.empty:
            return UIColor(hexString: "#999999")
        default:
            return UIColor(hexString: "#F1AC23")
        }
    }
    
    
    
    var backgroundColor: UIColor? {
        switch self {
        case.empty:
            return nil
        default:
            let gradient = DynamicGradient(colors: [UIColor(hexString: "#EB6E12"), UIColor(hexString: "#F5AD3C")])
            return gradient.pickColorAt(scale: 0.25)
        }
    }
    
}
