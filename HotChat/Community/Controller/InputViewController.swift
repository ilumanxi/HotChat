//
//  InputViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/4.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class InputBarView: UIView {
    
    var cachedIntrinsicContentSize: CGSize = CGSize(width:UIView.layoutFittingExpandedSize.width, height: 44.0)
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override var intrinsicContentSize: CGSize {
        return cachedIntrinsicContentSize
    }
    
    
    var textField: UITextField
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        
        textField = TextFiled(frame: frame)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hexString: "#F7F6F6")
        textField.layer.cornerRadius = 19.5
        textField.placeholder = "想对TA说的话..."
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        
        super.init(frame: frame)
        layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textField)
        textField.heightAnchor.constraint(equalToConstant: 39).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class InputViewController: UIViewController {
    
    let inputBar = InputBarView()

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    let onSend = Delegate<String, Void>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        inputBar.textField.addTarget(self, action: #selector(send(sender:forEvent:)), for: .editingDidEndOnExit)
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.inputBar.textField.becomeFirstResponder()
        }
    }
    
   @objc func send(sender: UITextField, forEvent event: UIEvent) {
        
        dismiss(animated: true) { [weak self] in
            self?.onSend.call(sender.text ?? "")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        dismiss(animated: true, completion: nil)
    }
}
