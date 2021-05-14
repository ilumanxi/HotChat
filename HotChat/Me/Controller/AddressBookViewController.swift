//
//  AddressBookViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/9.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Aquaman



class AddressBookViewController: UIViewController, AquamanChildViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .refreshingContent {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    var user: User!
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    func aquamanChildScrollView() -> UIScrollView {
        return scrollView
    }
    
    let buyAPI = Request<BuyAPI>()
    
    fileprivate var info: AddressBookInfo? {
        didSet {
            display()
        }
    }
    
    @IBOutlet weak var qqLabel: UILabel!
    
    @IBOutlet weak var qqButton: UIButton!
    
    @IBOutlet weak var wechatLabel: UILabel!
    @IBOutlet weak var wechatButton: UIButton!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshData()
    }
    
    func refreshData() {
        
        if info == nil {
            state = .refreshingContent
        }
        
        buyAPI.request(.checkBuyUserContact(toUserId: user.userId), type: Response<AddressBookInfo>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.info = response.data
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                if self?.info == nil {
                    self?.state = .error
                }
            })
            .disposed(by: rx.disposeBag)
    }


    func display()  {
        label(qqLabel, button: qqButton, status: info!.qq!)
        label(wechatLabel, button: wechatButton, status: info!.weixin!)
        label(phoneLabel, button: phoneButton, status: info!.contactPhone!)
        
    }
    
    
    func label(_ label: UILabel, button: UIButton, status: AddressBookStatus) {
        
        if let gesture = label.gestureRecognizers?.first {
            label.removeGestureRecognizer(gesture)
        }
        if status.value.isEmpty {
            label.text = "未填写"
            label.isUserInteractionEnabled = false
            button.alpha = 0
        }
        else if !status.status { //没有购买
            label.text = "信息真实"
            label.isUserInteractionEnabled = false
            button.alpha = 1
        }
        else {
            label.text = status.value
            label.isUserInteractionEnabled = true
            button.alpha = 0
            let tap = UITapGestureRecognizer()
            label.addGestureRecognizer(tap)
            tap.rx.event.subscribe(onNext: { [weak self] _ in
                UIPasteboard.general.string = status.value
                self?.showMessageOnWindow("复制成功")
            })
            .disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func qqButtonTapped(_ sender: Any) {
        buy(status: info!.qq!, type: 1)
    }
    
    @IBAction func wechatButtonTapped(_ sender: Any) {
        buy(status: info!.weixin!, type: 2)
    }
    
    @IBAction func phoneButtonTapped(_ sender: Any) {
        buy(status: info!.contactPhone!, type: 3)
    }
    
    func buy(status: AddressBookStatus, type: Int) {
       
        let vc =  TipAlertController(title: "温馨提示", message:  status.title, leftButtonTitle: "取消", rightButtonTitle: "确定支付")
        vc.onRightDidClick.delegate(on: self) { (self, _) in
            self.buy(type: type)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func tipRecharge()  {
        let vc =  TipAlertController(title: "温馨提示", message:  "您的能量不足，请充值", leftButtonTitle: "取消", rightButtonTitle: "立即充值")
        vc.onRightDidClick.delegate(on: self) { (self, _) in
            self.wallet()
        }
        present(vc, animated: true, completion: nil)
    }
    
    func wallet() {
        let vc = WalletViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func buy(type: Int) {
        
        showIndicator("支付中...")
        buyAPI.request(.buyContact(type: type, toUserId: user.userId), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
                //resultCode：1200购买失败 1201能量不足 1202购买成功 1203购买过了
                guard
                    let resultCode = response.data?["resultCode"] as? Int,
                    let resultMsg = response.data?["resultMsg"] as? String
                else { return }
                
                if resultCode == 1202 || resultCode == 1203 {
                    self?.refreshData()
                }
                else if resultCode == 1201 {
                    self?.tipRecharge()
                }
                else {
                    self?.show(resultMsg)
                }

            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
