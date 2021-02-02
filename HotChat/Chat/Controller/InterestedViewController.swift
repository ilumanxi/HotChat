//
//  InterestedViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Koloda

class InterestedViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var indexLabel: UILabel!
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    var data: [Message] = [] {
        didSet {
            kolodaView.reloadData()
        }
    }
    
    let messageAPI = Request<MessageAPI>()
    let dynamicAPI  = Request<DynamicAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        showOrHideIndicator(loadingState: .initial)
        
        messageAPI.request(.knowPeople, type: Response<[String : Any]>.self)
            .verifyResponse()
            .map {
                return [Message].deserialize(from: $0.data?["list"] as? [Any])?.compactMap{ $0 } ?? []
            }
            .subscribe(onSuccess: { [weak self] result in
                self?.data = result
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.showOrHideIndicator(loadingState: result.isEmpty ? .noContent : .contentLoaded)
                }
            }, onError: { [weak self] error in
                self?.show(error)
                self?.showOrHideIndicator(loadingState: .error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        kolodaView.swipe(.left)
        
        let message = data[kolodaView.currentCardIndex - 1]
        
        readUser(message: message)
    }
    
    
    func readUser(message: Message) {
        messageAPI.request(.readUser(userId: message.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func follow(message: Message){
        dynamicAPI.request(.follow(message.userId), type: ResponseEmpty.self)
            .subscribe(onSuccess: { response in
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        kolodaView.swipe(.right)
        let message = data[kolodaView.currentCardIndex - 1]
        follow(message: message)

    }
}


// MARK: KolodaViewDelegate

extension InterestedViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        showOrHideIndicator(loadingState: .noContent, text: "想认识你的人都被你看完了", image: UIImage(named: "chat-no-content"))
    }
    

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        indexLabel.text = "\(index + 1)/\(koloda.countOfCards)"
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        let user  = data[index]
        
        let vc = UserInfoViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let message = data[index]
        switch direction {
        case .left:
            readUser(message: message)
        case .right:
            follow(message: message)
        default: break
        }

    }

}

// MARK: KolodaViewDataSource

extension InterestedViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return data.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        
        let message = data[index]
        let tags =  message.labelList.compactMap{ $0.label }.joined(separator: " ")
        
        let cardView = InterestedCardView.loadFromNib()
        cardView.avatarImageView.kf.setImage(with: URL(string: message.headPic))
        cardView.nicknameLabel.text = message.nick
        
        var text = ""
        
        if !message.region.isEmpty {
            text.append(" \(message.region)")
        }
        
        if !tags.isEmpty {
            text.append(" \(tags)")
        }
        
        cardView.infoLabel.text = text
        
        cardView.contentLabel.text = message.content
        cardView.sexView.setSex(message)
        cardView.gradeView.setGrade(message)
        cardView.authenticationButton.isHidden = !message.girlStatus
        return cardView
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
        let view = InterestedCardOverlayView.loadFromNib()
        view.backgroundColor = UIColor.clear
        return view
    }
}

