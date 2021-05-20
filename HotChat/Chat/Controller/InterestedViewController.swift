//
//  InterestedViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Koloda
import RxSwift
import RxCocoa

class InterestedViewController: UIViewController, IndicatorDisplay, StoryboardCreate {
    static var storyboardNamed: String { return "Chat" }
    
    
    
    @IBOutlet weak var indexLabel: UILabel!
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    var data: [Message] = []
    
    let messageAPI = Request<MessageAPI>()
    let dynamicAPI  = Request<DynamicAPI>()
    
    var last: Pagination<Message>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        showOrHideIndicator(loadingState: .initial)
       
        refreshData()
    }
    
    func refreshData() {
        requestData()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.last = response.data
                self.data.append(contentsOf:  response.data?.list ?? [])
                self.kolodaView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showOrHideIndicator(loadingState: self.data.isEmpty ? .noContent : .contentLoaded)
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                if self.data.isEmpty {
                    self.show(error)
                    self.showOrHideIndicator(loadingState: .error)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func requestData() ->Single<Response<Pagination<Message>>>  {
        return  messageAPI.request(.knowPeople).verifyResponse()
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
        readUser(message: message)

    }
}


// MARK: KolodaViewDelegate

extension InterestedViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        if self.last?.hasNext ?? false {
            requestNext()
        }
        else if koloda.currentCardIndex == (self.last?.count ?? 0) {
            showOrHideIndicator(loadingState: .noContent, text: "想认识你的人都被你看完了", image: UIImage(named: "chat-no-content"))
        }
    }
    
    func requestNext() {
        let position = kolodaView.currentCardIndex
        requestData()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.last = response.data
                let list = response.data?.list ?? []
                
                self.data.append(contentsOf:  list)
                self.kolodaView.insertCardAtIndexRange(position..<position + list.count, animated: true)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.show(error)
            })
            .disposed(by: rx.disposeBag)
    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        indexLabel.text = "\(index + 1)/\(last?.count ?? 0)"
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
        cardView.sexView.set(message)
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

