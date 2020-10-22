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
        
        
      let wallet  = FormSection(entries: [WalletFormEntry(user: user, onTapped: pushWallet)], headerText: nil)
        
       let detail =  FormSection(
            entries: [
                RightDetailFormEntry(image: UIImage(named: "me-money"), text: "奖励任务"),
                RightDetailFormEntry(image: UIImage(named: "me-invitation"), text: "6万邀请奖"),
                RightDetailFormEntry(image: UIImage(named: "me-nobility"), text: "贵族特权"),
                RightDetailFormEntry(image: UIImage(named: "me-anti-fraud"), text: "防骗中心"),
                RightDetailFormEntry(image: UIImage(named: "me-call"), text: "通话设置"),
                RightDetailFormEntry(image: UIImage(named: "me-anchor"), text: "主播认证", onTapped: pushAuthentication),
            ],
            headerText: nil
        )
        
        let basic =  FormSection(
             entries: [
                 RightDetailFormEntry(image: UIImage(named: "me-grade"), text: "等级"),
                 RightDetailFormEntry(image: UIImage(named: "me-authentication"), text: "认证", onTapped: pushAuthentication),
                 RightDetailFormEntry(image: UIImage(named: "me-notification"), text: "通知", detailText: "未开启"),
                 RightDetailFormEntry(image: UIImage(named: "me-help"), text: "帮助"),
                 RightDetailFormEntry(image: UIImage(named: "me-setting"), text: "设置")
             ],
             headerText: nil
         )
        
        self.sections = [wallet, detail, basic]
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 105 : 44
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
