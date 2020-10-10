//
//  InterestedViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Koloda

class InterestedViewController: UIViewController {
    
    
    @IBOutlet weak var indexLabel: UILabel!
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    let cardCount: Int = 7
    
    private var currentIndex: Int = 0 {
        didSet {
            indexLabel.text = "\(currentIndex + 1)/\(cardCount)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = 0
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }

}


// MARK: KolodaViewDelegate

extension InterestedViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {

    }
    

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        currentIndex = index
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }

}

// MARK: KolodaViewDataSource

extension InterestedViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return cardCount
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let  view = InterestedCardView.loadFromNib()
        
        return view
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
        let view = InterestedCardOverlayView.loadFromNib()
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }
}

