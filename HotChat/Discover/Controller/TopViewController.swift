//
//  TopViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/9.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
import HandyJSON

enum TopType: Int, CaseIterable {
    /// 魅力
    case charm = 1
    /// 富豪
    case estate = 2
}


enum TopTag: Int, CaseIterable, HandyJSONEnum {
    
    case day = 1
    
    case week = 2
    
    case month = 3
    
    /// 总榜单
    case general = 4
    
    
    var title: String {
        switch self {
        case .day:
            return "日榜"
        case .week:
            return "周榜"
        case .month:
            return "月榜"
        case .general:
            return "总榜"
        }
    }
    
}

extension TopType {
    
    var title: String {
        switch self {
        case .charm:
            return "魅力榜"
        case .estate:
            return "富豪榜"
        }
    }
    
    
    var textColor: UIColor {
        switch self {
        case .charm:
            return UIColor(hexString: "#C5EDFF")
        case .estate:
            return UIColor(hexString: "#D5B3FE")
            
        }
    }
    

    var selectedTextColor: UIColor {
        switch self {
        case .charm:
            return UIColor.white
        case .estate:
            return UIColor.white
        }
    }
    
    var colors: [UIColor] {
        
        switch self {
        case .charm:
            return [UIColor(hexString: "#B575F8"), UIColor(hexString: "#940ADB")]
        case .estate:
            return [UIColor(hexString: "#48C6FE"), UIColor(hexString: "#486BF9")]
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .charm:
            return UIColor(hexString: "#DABCFF")
        case .estate:
            return UIColor(hexString: "#7AD3FD")
            
        }
    }
    
    var defaultTextColor: UIColor {
        switch self {
        case .charm:
            return UIColor(hexString: "#D5B3FE")
        case .estate:
            return UIColor(hexString: "#C5EDFF")
        }
    }
    
    var sliderBackgroundColor: UIColor {
        switch self {
        case .charm:
            return UIColor(hexString: "#D5B3FE")
        case .estate:
            return UIColor(hexString: "#7AD3FD")
        }
    }
    
    var tags: [TopTag] {
        switch self {
        case .charm:
            return [.day, .week, .month]
        case .estate:
            return [.day, .week, .general]
        }
    }
    
    var titles: [String] {
        
        return tags.compactMap { $0.title }
    }
    
    var backgroundImage: UIImage? {
        switch self {
        case .charm:
            return UIImage(named: "top-charm-bg")
        case .estate:
            return UIImage(named: "top-estate-bg")
        }
    }
    
    var image: UIImage {
        switch self {
        case .charm:
            return UIImage(named: "top-charm")!
        case .estate:
            return UIImage(named: "top-estate")!
        }
    }

}


class TopViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var segmentedControl: TwicketSegmentedControl!
    
    
    let headerView = TopHeaderView.loadFromNib()
    
    
    @IBOutlet weak var navigationView: GradientView!
    
    @IBOutlet weak var topView: GradientView!
    
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    
    
    let topType: TopType
    
    
    init(topType: TopType) {
        self.topType = topType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let API = Request<TopAPI>()
    
    
    var data: [TopTag: TopList] = [:]
    
    var current: TopList? {
        
        let tag = topType.tags[segmentedControl.selectedSegmentIndex]
        return data[tag]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.register(UINib(nibName: "TopViewCell", bundle: nil), forCellReuseIdentifier: "TopViewCell")
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = .white
        
        navigationView.colors = topType.colors
        topView.colors = topType.colors
        headerView.contentView.colors = topType.colors
        headerView.backgroundImageView.image = topType.backgroundImage

        tableView.tableHeaderView = headerView
        segmentedControl.backgroundView.layer.borderWidth = 0.5
        segmentedControl.backgroundView.layer.borderColor = topType.borderColor.cgColor
        segmentedControl.segmentsBackgroundColor = .clear
        segmentedControl.containerView.backgroundColor = .clear
        segmentedControl.sliderBackgroundColor = topType.sliderBackgroundColor
        segmentedControl.backgroundColor = .clear
        segmentedControl.defaultTextColor = topType.defaultTextColor
        segmentedControl.highlightTextColor = topType.selectedTextColor
        segmentedControl.setSegmentItems(topType.titles)
        segmentedControl.delegate = self
        
        requestData()
        
        
        headerView.onAvatarTapped.delegate(on: self) { (self, index) in
            guard let top = self.current, index < top.topList.count else {
                return
            }
            
            let user = top.topList[index]
            
            let vc = UserInfoViewController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func requestData()  {
        
        let type = topType.rawValue
        let tag = topType.tags[segmentedControl.selectedSegmentIndex].rawValue
        
        dispaly()
        
        API.request(.topList(type: type, tag: tag), type: Response<TopList>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.handle(response)
            }, onError: { [weak self] error in
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }

    
    func handle(_ response: Response<TopList>) {
        
        
        data[response.data!.tag!] = response.data
        
        dispaly()
        
    }
    
    func dispaly() {
        
        
        if (current?.topList.count ?? 0) >= 1 , let user =  current?.topList.first {
            headerView.top1NameLabel.text = user.nick
            headerView.top1AvatarImageView.kf.setImage(with: URL(string: user.headPic))
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = topType.image
            let font = headerView.top1CountLabel.font!
            textAttachment.bounds =  CGRect(x: 0, y: -(font.lineHeight - font.pointSize) / 2, width: topType.image.size.width, height: topType.image.size.height)
            
            let attributedText = NSMutableAttributedString(attachment: textAttachment)
            attributedText.append(NSAttributedString(string: " \(user.energy)"))
            headerView.top1CountLabel.attributedText = attributedText
        }
        else {
            headerView.top1NameLabel.text = "虚位以待"
            headerView.top1AvatarImageView.image = UIImage(named: "top-profile")
            headerView.top1CountLabel.attributedText = nil
        }
        
        
        if (current?.topList.count ?? 0) >= 2 , let user =  current?.topList[1] {
            headerView.top2NameLabel.text = user.nick
            headerView.top2AvatarImageView.kf.setImage(with: URL(string: user.headPic))
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = topType.image
            let font = headerView.top2CountLabel.font!
            textAttachment.bounds =  CGRect(x: 0, y: -(font.lineHeight - font.pointSize) / 2, width: 13, height: 13)
            
            let attributedText = NSMutableAttributedString(attachment: textAttachment)
            attributedText.append(NSAttributedString(string: " \(user.energy)"))
            headerView.top2CountLabel.attributedText = attributedText
        }
        else {
            headerView.top2NameLabel.text = "虚位以待"
            headerView.top2AvatarImageView.image = UIImage(named: "top-profile")
            headerView.top2CountLabel.attributedText = nil
        }
        
        if (current?.topList.count ?? 0) >= 3 , let user = current?.topList[2] {
            headerView.top3NameLabel.text = user.nick
            headerView.top3AvatarImageView.kf.setImage(with: URL(string: user.headPic))
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = topType.image
            let font = headerView.top3CountLabel.font!
            textAttachment.bounds =  CGRect(x: 0, y: -(font.lineHeight - font.pointSize) / 2, width: 12, height: 12)
            
            let attributedText = NSMutableAttributedString(attachment: textAttachment)
            attributedText.append(NSAttributedString(string: " \(user.energy)"))
            headerView.top3CountLabel.attributedText = attributedText
        }
        else {
            headerView.top3NameLabel.text = "虚位以待"
            headerView.top3AvatarImageView.image = UIImage(named: "top-profile")
            headerView.top3CountLabel.attributedText = nil
        }
        
        if let user = current?.userInfo {
            bottomView.isHidden = !user.isShow
            
            topLabel.text = user.rankId
            avatarImageView.kf.setImage(with: URL(string: user.headPic))
            nameLabel.text = user.nick
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = topType.image
            let font = countLabel.font!
            textAttachment.bounds =  CGRect(x: 0, y: -(font.lineHeight - font.pointSize) / 2, width: 12, height: 12)
            
            let attributedText = NSMutableAttributedString(attachment: textAttachment)
            attributedText.append(NSAttributedString(string: " \(user.preEnergy)"))
            
            let string = user.rankStatus == 1 ? "距上一位差 " :"距上榜差 "
            
            attributedText.insert(NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#999999")]), at: 0)
            
            countLabel.attributedText = attributedText
        }
        else {
            topLabel.text = nil
            avatarImageView.image = nil
            nameLabel.text = nil
            countLabel.attributedText = nil
        }
        self.tableView.reloadData()
    }
}

extension TopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = current!.list[indexPath.row]
        
        let vc = UserInfoViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TopViewController: UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = current!.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TopViewCell.self)
        
        cell.topLabel.text = user.rankId
        cell.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        cell.nameLabel.text = user.nick
        cell.nameLabel.textColor = user.vipType.textColor
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = topType.image
        let font = cell.countLabel.font!
        textAttachment.bounds =  CGRect(x: 0, y: -(font.lineHeight - font.pointSize) / 2, width: 12, height: 12)
        
        let attributedText = NSMutableAttributedString(attachment: textAttachment)
        attributedText.append(NSAttributedString(string: " \(user.energy)"))
        cell.countLabel.attributedText = attributedText
        
        return cell
    }
    
    
    
}


extension TopViewController: TwicketSegmentedControlDelegate {
    
    
    func didSelect(_ segmentIndex: Int) {
        requestData()
    }
}
