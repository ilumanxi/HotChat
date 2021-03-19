//
//  ChatMemberContainerViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import WMSegmentControl

class ChatMemberContainerViewController: UIViewController {
    
    
    lazy var segment: WMSegment =  {
        let view = WMSegment(frame: CGRect(x: 0, y: 0, width: 94, height: 29))
        view.buttonTitles = ["女", "男"].joined(separator: ",")
        view.borderWidth = 0.5
        view.borderColor = UIColor(hexString: "#FF403E")
        view.textColor = UIColor(hexString: "#FF423E")
        view.selectorTextColor = .white
        view.selectorColor = UIColor(hexString: "#FF3F3F")
        view.normalFont = .systemFont(ofSize: 16, weight: .medium)
        view.SelectedFont = .systemFont(ofSize: 16, weight: .medium)
        view.isRounded = true
        return view
    }()
    
    
    lazy var viewControllers: [ChatMemberViewController] = {
        
        return [
            ChatMemberViewController(groupId: groupId, sex: .female),
            ChatMemberViewController(groupId: groupId, sex: .male)
        ]
    }()
    
    let groupId: String
    
    init(groupId: String) {
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "成员列表"
        view.backgroundColor = .white
        
        setupViews()
        
        segment.onValueChanged = { [unowned self]  index in
            self.showMember(member: viewControllers[index])
        }
        

        
    }
    

    func setupViews()  {
        
        view.addSubview(segment)
        segment.snp.makeConstraints { maker in
            maker.top.equalTo(safeTop).offset(4)
            maker.trailing.equalToSuperview().offset(-15)
            maker.size.equalTo(CGSize(width: 94, height: 29))
        }
        
        
        let viewController = viewControllers[0]
        let contentView = viewController.view!
        addChild(viewController)
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 4).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        
        viewController.didMove(toParent: self)
    }
    
    private func showMember(member: ChatMemberViewController) {
        
        let newViewController = member
        let oldViewController = children[0]
        
        if member == oldViewController {
            return
        }
        
        let newView = newViewController.view
        let containerView = self.view!
        
        newView?.translatesAutoresizingMaskIntoConstraints = false
        addChild(newViewController)
        
        transition(from: oldViewController, to: newViewController, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            newView?.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            newView?.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            newView?.topAnchor.constraint(equalTo: self.segment.bottomAnchor, constant: 4).isActive = true
            newView?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }, completion: { _ in
            oldViewController.removeFromParent()
        })
    }

}
