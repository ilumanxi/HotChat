//
//  Toolbar.swift
//  LegalLiability
//
//  Created by 风起兮 on 2020/5/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import ActiveLabel
import SnapKit


@IBDesignable
class LegalLiabilityToolBar: UIView {
    
    var text: String? {
        didSet {
            titleLabel.text = text
            invalidateIntrinsicContentSize()
        }
    }
    
    
    let onPushing = Delegate<(), UINavigationController>()
    
    public static let defaultHeight: CGFloat = 35
    
    public static let defaultSpace: CGFloat = 16
    
    private var cachedIntrinsicContentSize: CGSize = CGSize(width: UIView.layoutFittingExpandedSize.width, height: LegalLiabilityToolBar.defaultHeight)

    fileprivate let contentView = UIView()
    
    fileprivate let stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.spacing = defaultSpace
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    

    
    fileprivate let spacer = UIView()
    
     lazy fileprivate var titleLabel: UILabel = {
        let label = ActiveLabel()
        
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .textGray
        let agreementType = ActiveType.custom(pattern: "《用户协议》") //Regex that looks for "《用户协议》"
        let privacyType = ActiveType.custom(pattern: "《隐私政策》") //Regex that looks for "《隐私政策》"
        let normalColor = UIColor(hexString: "#525AF8")
        let selectedColor = normalColor.withAlphaComponent(0.7)
        label.customColor[agreementType] = normalColor
        label.customColor[privacyType] = normalColor
        label.customSelectedColor[agreementType] = selectedColor
        label.customSelectedColor[privacyType] = selectedColor
        label.enabledTypes = [agreementType, privacyType]
        
        label.handleCustomTap(for: agreementType) { [weak self] element in
            let viewController = UIViewController()
            viewController.view.backgroundColor = .white
            viewController.title = element
            self?.push(viewController)
        }
        label.handleCustomTap(for: privacyType) { [weak self] element in
            let viewController = UIViewController()
            viewController.title = element
            viewController.view.backgroundColor = .white
            self?.push(viewController)
        }
        label.text = "登录即同意贪聊《用户协议》与《隐私政策》"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
         makeUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func makeUI() {

        preservesSuperviewLayoutMargins = true
        
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.height.equalTo(LegalLiabilityToolBar.defaultHeight).priority(999)
            maker.leadingMargin.trailingMargin.equalToSuperview()
            maker.bottom.equalTo(self.safeBottom).priority(999)
            maker.bottom.lessThanOrEqualToSuperview().offset(-34)
            maker.top.greaterThanOrEqualToSuperview().priority(999)
        }
         
        let views: [UIView]  = [titleLabel]
          
        for view in views {
            stackView.addArrangedSubview(view)
        }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { maker in
            maker.leadingMargin.equalToSuperview()
            maker.trailingMargin.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
    }
    
    private func push(_ viewController: UIViewController) {
        guard let navigationController = onPushing.call() else {
            return
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
//    public override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }
    
    public override var intrinsicContentSize: CGSize {
        return self.cachedIntrinsicContentSize
    }
}

