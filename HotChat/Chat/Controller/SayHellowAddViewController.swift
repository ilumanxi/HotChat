//
//  SayHellowAddViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SayHellowAddViewController: UIViewController, IndicatorDisplay {
    
    let onAdded = Delegate<Void, Void>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var greetingsAddedView: GreetingsAddedView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var limitLabel: UILabel!
    
    
    @IBOutlet weak var addButton: UIButton!
    
    var limitLength: Int = 50
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return greetingsAddedView
    }
    
    
    let API = Request<ChatGreetAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        observerState()
        
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        greetingsAddedView =  Bundle.main.loadNibNamed("GreetingsAddedView", owner: self, options: nil)?.first as? GreetingsAddedView
        textView.contentInset = UIEdgeInsets(top: 8, left: 10, bottom: 24, right: 10)
    }
    
    func observerState() {
        
        let textSignal =  textView.rx.text.orEmpty.share(replay: 1)
        
        let textLengthSignal =  textSignal
            .map{ ($0 as NSString).length }
            .share(replay: 1)
        
        textSignal
            .filter { [unowned self] text in
                text.length > self.limitLength
            }
            .map{ [unowned self] text in
                (text as NSString).substring(to: self.limitLength)
            }
            .bind(to: textView.rx.text)
            .disposed(by: rx.disposeBag)
        
        textSignal
            .map{ !$0.isEmpty }
            .bind(to: addButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        textLengthSignal
            .map{ [unowned self] length in
                "\(length)/\(self.limitLength)"
            }
            .bind(to: limitLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.textView.becomeFirstResponder()
        }
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        showIndicator(nil, in: greetingsAddedView)
        API.request(.addGreet(content: textView.text ?? ""), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] _ in
                self.hideIndicator(from: self.greetingsAddedView)
                self.onAdded.call()
                self.dismiss(animated: true, completion: nil)
                
            }, onError: { [unowned self] error in
                self.hideIndicator(from: self.greetingsAddedView)
                self.show(error.localizedDescription, in: self.greetingsAddedView)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == view {
            dismiss(animated: true, completion: nil)
        }
    }

}
