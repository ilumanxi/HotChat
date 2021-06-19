//
//  ViewController.swift
//  vvv
//
//  Created by 风起兮 on 2021/6/18.
//

import UIKit

extension TUIMessageController: IndicatorDisplay {
    
}

class WaitingMessageViewController: UIViewController {
    
    @IBOutlet weak var linearImageView: UIImageView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    private var maskView  = UIView()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        initializeAnimation()
    }
    
    private func setupUI()  {
        maskView.backgroundColor = .black
        maskView.layer.cornerRadius = linearImageView.bounds.height / 2
        maskView.clipsToBounds = true
        maskView.frame  = linearImageView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: linearImageView.bounds.width * 1))
        linearImageView.mask = maskView
    }
    
    private func initializeAnimation() {
        let bounds = linearImageView.bounds
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.maskView.frame  = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width * 0.2))
        }, completion: nil)
       
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = 0.75
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        rotationAnimation.toValue = CGFloat.pi * 2
        iconImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func finalAnimation(block: @escaping () -> Void) {
        let bounds = linearImageView.bounds
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.maskView.frame  = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width * 0))
        } completion: { _ in
            block()
        }
    }
    
    @objc func dismiss() {
        finalAnimation {
            self.dismiss(animated: true, completion: nil)
        }
    }
}



