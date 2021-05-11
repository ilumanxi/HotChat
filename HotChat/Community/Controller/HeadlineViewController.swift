//
//  HeadlineViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Jelly

class HeadlineViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var tipabel: UILabel!
    
    
    @IBOutlet weak var textView: PlaceholderTextView!
    
    let containerLayoutGuide: UILayoutGuide = UILayoutGuide()
    
    @IBOutlet weak var contentView: UIView!
    
    let API = Request<HeadlineAPI>()
    
    
    static var energy: Int = 5
    
    @IBOutlet weak var energyLabel: UILabel!
    
    
    var animator: Animator?
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bottomLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        
        API.request(.headlinesConfig, type: Response<[String : Any]>.self)
            .subscribe(onSuccess: { [unowned self] response in
                guard let energy  = response.data?["energy"] as? Int else {
                    return
                }
                HeadlineViewController.energy = energy
                energyLabel.text = "\(energy)能量值/条"
            }, onError: nil)
            .disposed(by: rx.disposeBag)
     
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillChangeFrameNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    private func setupUI() {
        view.addLayoutGuide(containerLayoutGuide)
        
        view.leadingAnchor.constraint(equalTo: containerLayoutGuide.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: containerLayoutGuide.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor).isActive = true
        
        bottomLayout = view.bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor)
        bottomLayout.isActive = true
        
        contentView.centerYAnchor.constraint(equalTo: containerLayoutGuide.centerYAnchor).isActive = true
        
        
        energyLabel.text = "\(Self.energy)能量值/条"
        
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "你的头条将会在首页停留"))
        string.append(NSAttributedString(string: "30S", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FF6A4D")]))
        string.append(NSAttributedString(string: "，\n预计"))
        string.append(NSAttributedString(string: "\(Int.random(in:30000...100000))人", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FF6A4D")]))
        string.append(NSAttributedString(string: "将会看到你的对话"))
        
        tipabel.attributedText = string
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    
    private func handle(_ notification: Notification) {
        
        let userInfo  = notification.userInfo
        
        
        guard let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let keyboardAnimationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
              let keyboardAnimationCurve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return
        }
        
        let isHidden = keyboardFrame.cgRectValue.maxY > self.view.bounds.height
        
        bottomLayout.constant = isHidden ? 0 : keyboardFrame.cgRectValue.height
        
        
        UIView.animate(
            withDuration: keyboardAnimationDuration.doubleValue,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue),
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                
            })
        
    
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        
        
        guard let content = textView.text, !content.isEmpty else {
            show("请写下你想说的话")
            
            return
        }
        view.endEditing(true)
        showIndicator()
        API.request(.topHeadlines(content: content), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
                guard let resultCode = response.data?["resultCode"] as? Int,
                      let resultMsg = response.data?["resultMsg"] as? String
                else {
                    return
                }
                
                if resultCode == 1120 { // 成功
                    self?.dismiss(animated: true, completion: nil)
                }
                else if resultCode == 1122 {  //  能量不足
                    self?.presentHeadlineTip(text: resultMsg, status: .recharge)
                }
                else {
                    self?.presentHeadlineTip(text: resultMsg, status: .violation)
                }
                
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func presentHeadlineTip(text: String, status: HeadlineTipViewController.Status)  {
        let vc = HeadlineTipViewController(text: text, status: status)
        vc.onRecharge.delegate(on: self) { (self, _) in
            let vc = WalletViewController()
            
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation-bar-back"), style: .done, target: self, action: #selector(self.close(_:)))
            let viewControllerToPresent = BaseNavigationController(rootViewController: vc)
            
            let interactionConfiguration = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .edge)
            let uiConfiguration = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.5))
            let presentation = SlidePresentation(uiConfiguration: uiConfiguration, direction: .right, size: .fullscreen, interactionConfiguration: interactionConfiguration)
            let animator = Animator(presentation: presentation)
            animator.prepare(presentedViewController: viewControllerToPresent)
            self.animator = animator
           
            self.present(viewControllerToPresent, animated: true) {
                
            }
            
        }
            
        present(vc, animated: true, completion: nil)
    }
    
    @objc func close(_ sender: Any) {
        
        presentedViewController?.dismiss(animated: true, completion: {
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }
}
