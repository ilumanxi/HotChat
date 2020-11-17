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
    
    var data: [Messsage] = [] {
        didSet {
            kolodaView.reloadData()
        }
    }
    
    let messsageAPI = Request<MesssageAPI>()
    let dynamicAPI  = Request<DynamicAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        showOrHideIndicator(loadingState: .initial)
        
        messsageAPI.request(.knowPeople, type: Response<[String : Any]>.self)
            .verifyResponse()
            .map {
                return [Messsage].deserialize(from: $0.data?["list"] as? [Any])?.compactMap{ $0 } ?? []
            }
            .subscribe(onSuccess: { [weak self] result in
                self?.data = result
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.showOrHideIndicator(loadingState: result.isEmpty ? .noContent : .contentLoaded)
                }
            }, onError: { [weak self] error in
                self?.show(error.localizedDescription)
                self?.showOrHideIndicator(loadingState: .error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        kolodaView.swipe(.left)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        kolodaView.swipe(.right)
        let message = data[kolodaView.currentCardIndex - 1]
        
        dynamicAPI.request(.follow(message.userId), type: ResponseEmpty.self)
            .subscribe(onSuccess: { response in
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
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
        cardView.infoLabel.text = "\(message.age)岁 \(tags)"
        return cardView
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
        let view = InterestedCardOverlayView.loadFromNib()
        view.backgroundColor = UIColor.clear
        return view
    }
}

