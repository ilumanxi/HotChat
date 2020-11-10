//
//  MeViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HBDNavigationBar
import RxSwift
import RxCocoa
import DynamicColor


extension LabelView {
    
    func setUser(_ user: User) {
        switch user.sex {
        case .male:
            image = UIImage(named: "me-sex-man")
            backgroundColor = UIColor(hexString: "#91D2FF")
        default:
            image = UIImage(named: "me-sex-woman")
            backgroundColor = UIColor(hexString: "#FB64F9")
        }
        text = Date(timeIntervalSince1970: user.birthday).age.description
        
    }
}


typealias TappedAction  = () -> Void

class RightDetailFormEntry: FormEntry {

    let image: UIImage?
    let text: String
    let detailText: String?
    let onTapped: TappedAction?
    
    init(image: UIImage?, text: String, detailText: String? = nil, onTapped: TappedAction? = nil) {
        self.image = image
        self.text = text
        self.detailText = detailText
        self.onTapped = onTapped
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        
        cell.imageView?.image = image
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
}

class WalletFormEntry: FormEntry {
    
    let user: User
    let onTapped: TappedAction?
    init(user: User, onTapped: TappedAction? = nil) {
        self.user = user
        self.onTapped = onTapped
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletViewCell.self)
        return cell
    }
}


class MeViewController: UITableViewController, Autorotate {
    
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
    
    private var user: User! {
        didSet {
            refreshDisplay()
        }
    }
    
    private var sections: [FormSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hbd_barHidden = true
        user = LoginManager.shared.user
        
        setupSections()

    }
    
    
    func setupSections()  {
        
        var walletEntries: [FormEntry] = []
        
        if user.girlStatus {
            walletEntries.append(RightDetailFormEntry(image: UIImage(named: "me-wallet"), text: "我的钱包", detailText: "历史总收益：\(user.userEnergy)", onTapped: pushEarnings))
        }
        else {
            walletEntries.append(RightDetailFormEntry(image: UIImage(named: "me-wallet"), text: "我的钱包", detailText: "能量\(user.userEnergy)", onTapped: pushWallet))
        }
        
        let wallet: FormSection  = FormSection(
            entries: walletEntries,
            headerText: nil
        )
      
       var detailEntries: [FormEntry] = [
            RightDetailFormEntry(image: UIImage(named: "me-money"), text: "奖励任务"),
            RightDetailFormEntry(image: UIImage(named: "me-invitation"), text: "6万邀请奖"),
            RightDetailFormEntry(image: UIImage(named: "me-nobility"), text: "会员特权"),
            RightDetailFormEntry(image: UIImage(named: "me-anti-fraud"), text: "防骗中心"),
            RightDetailFormEntry(image: UIImage(named: "me-call"), text: "通话设置"),
            RightDetailFormEntry(image: UIImage(named: "me-anchor"), text: "主播认证", onTapped: pushAuthentication)
        ]
        
        if self.user.sex! == .male {
            detailEntries.remove(at: 5)
        }
        

       let detail =  FormSection(
            entries: detailEntries,
            headerText: nil
        )
        
        var basicEntries: [FormEntry] =  [
            RightDetailFormEntry(image: UIImage(named: "me-grade"), text: "等级"),
            RightDetailFormEntry(image: UIImage(named: "me-authentication"), text: "认证", onTapped: pushAuthentication),
            RightDetailFormEntry(image: UIImage(named: "me-notification"), text: "通知", detailText: "未开启"),
            RightDetailFormEntry(image: UIImage(named: "me-help"), text: "帮助"),
            RightDetailFormEntry(image: UIImage(named: "me-setting"), text: "设置", onTapped: pushSetting)
        ]
        
        if self.user.sex! == .female {
            basicEntries.remove(at: 1)
        }
        
        
        let basic =  FormSection(
             entries: basicEntries,
             headerText: nil
         )
        
        self.sections = [wallet, detail, basic]
        
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    func requestData() {
        
        userAPI.request(.userinfo(userId: nil), type: Response<User>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.user = response.data
                    self?.setupSections()
                }
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func refreshDisplay() {
        
        guard let user = self.user else { return }
        
        meHeaderView.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        meHeaderView.nicknameLabel.text = user.nick
        meHeaderView.sexView.setUser(user)
        meHeaderView.vipButton.isHidden = user.vipType.isHidden
        meHeaderView.vipButton.setTitle(user.vipType.description, for: .normal)
        meHeaderView.vipButton.backgroundColor = user.vipType.backgroundColor
        meHeaderView.followButton.setTitle("\(user.userFollowNum) 关注", for: .normal)
        meHeaderView.fansButton.setTitle("\(user.userFansNum) 粉丝", for: .normal)
        
        meHeaderView.setNeedsLayout()
        meHeaderView.layoutIfNeeded()
    }
    
    
    func pushAuthentication() {
        let vc = AuthenticationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushWallet()  {
        let vc = WalletViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushEarnings() {
        let vc = EarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushSetting() {
        
        let vc = SettingViewController.loadFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  50
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
            vc.user = user
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
