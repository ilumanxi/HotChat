//
//  AnchorAuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import Photos
import RxSwift
import RxCocoa

class FiledFormEntry: NSObject, FormEntry {
    
    var title: String
    var text: String?
    var isEdit: Bool
    let onTextChanged = Delegate<String, Void>()
    private var disposeBag: DisposeBag!
    init(title: String, text: String?, isEdit: Bool = true) {
        self.title = title
        self.text = text
        self.isEdit = isEdit
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FiledViewCell.self)
        cell.fieldTextLabel.text = title
        cell.textField.text = text
        cell.textField.isEnabled = isEdit
        
        disposeBag = DisposeBag()
        
        cell.textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] in
                self?.onTextChanged.call($0)
            })
            .disposed(by: disposeBag)
        
        return cell
    }
}

class CardFormEntry: NSObject, FormEntry {
    
    var image: UIImage?
    var text: String
    var detailText: String
    var card: URL?
    
    let onPresenting = Delegate<(), UIViewController>()
    
    let onImageChanged = Delegate<URL, Void>()
    
    init(image: UIImage?, text: String, detailText: String, card: URL?) {
        self.image = image
        self.text = text
        self.detailText = detailText
        self.card = card
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CardViewCell.self)
        cell.exampleLabel.text = text
        cell.exampleImageView.image = image
        cell.cardImageView.kf.setImage(with: card)
        cell.cardLabel.text = detailText
        cell.cardButton.removeTarget(nil, action: #selector(cardButtonTapped), for: .touchUpInside)
        cell.cardButton.addTarget(self, action: #selector(cardButtonTapped), for: .touchUpInside)
        
        return cell
    }
    
    @objc func cardButtonTapped() {
        imagePicker { (images, _, _) in
            if let image = images.first {
                let url =  writeImage(image)
                self.onImageChanged.call(url)
            }
           
        }
    }
    
    private func imagePicker(_ selectImageBlock: @escaping ( ([UIImage], [PHAsset], Bool) -> Void )) {
        
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = 1
        config.allowSelectVideo = false
        config.maxPreviewCount = 0
                
        
        let imagePickerController = ZLPhotoPreviewSheet(selectedAssets: [])
        imagePickerController.selectImageBlock = selectImageBlock
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        imagePickerController.showPhotoLibrary(sender: presentingViewController)
    }
    
}


class AnchorAuthentication {
    var name: String?
    var card: String?
    var handHeld: Media?
    var front: Media?
    var back: Media?
    
}

class AnchorAuthenticationViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var name: String?
    
    private var card: String?
    
    
    private var sections: [FormSection] = []
    
    let anchorAuthentication = AnchorAuthentication()
    
    private var nameForm: FiledFormEntry {
        let entry  = FiledFormEntry(title: "姓名", text: anchorAuthentication.name)
        entry.onTextChanged.delegate(on: self) { (self, text) in
            self.anchorAuthentication.name = text
        }
        return entry
    }
    
    private var cardForm: FiledFormEntry {
        let entry  = FiledFormEntry(title: "身份证", text: anchorAuthentication.card)
        entry.onTextChanged.delegate(on: self) { (self, text) in
            self.anchorAuthentication.card = text
        }
        
        return entry
    }
    
    private var cardPhotoForm: FiledFormEntry {
        let entry  = FiledFormEntry(title: "手持身份照", text: nil, isEdit: false)
        return entry
    }
    
    private var handHeldCardForm: CardFormEntry {
        let entry =  CardFormEntry(
            image: UIImage(named: "me-card-hand-held"),
            text: "a.需保证身份证号码可见",
            detailText: "手持身份证照",
            card: anchorAuthentication.handHeld?.display
        )
        entry.onPresenting.delegate(on: self) { (_, _) -> UIViewController in
            return self
        }
        entry.onImageChanged.delegate(on: self) { (self, url) in

            self.upload(url) {  remote in
                self.anchorAuthentication.handHeld = Media(remote: URL(string: remote.picUrl), local: url)
            }
        }
        return entry
    }
    
    private var frontCardForm: CardFormEntry {
        let entry =  CardFormEntry(
            image: UIImage(named: "me-card-front"),
            text: "b.需保证画面清晰可见",
            detailText: "身份证正面照",
            card: anchorAuthentication.front?.display
        )
        entry.onPresenting.delegate(on: self) { (_, _) -> UIViewController in
            return self
        }
        entry.onImageChanged.delegate(on: self) { (self, url) in
            self.upload(url) {  remote in
                self.anchorAuthentication.front = Media(remote: URL(string: remote.picUrl), local: url)
            }

        }
        return entry
    }
    
    private var backCardForm: CardFormEntry {
        let entry =  CardFormEntry(
            image: UIImage(named: "me-card-back"),
            text: "c.需保证有效期限可见",
            detailText: "身份证背面照",
            card: anchorAuthentication.back?.display
        )
        entry.onPresenting.delegate(on: self) { (_, _) -> UIViewController in
            return self
        }
        entry.onImageChanged.delegate(on: self) { (self, url) in
            self.upload(url) {  remote in
                self.anchorAuthentication.back = Media(remote: URL(string: remote.picUrl), local: url)
            }
        }
        return entry
    }
    
    let uploadAPI = Request<UploadFileAPI>()
    let authenticationAPI = Request<AuthenticationAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的认证"
        
        setupTableView()
        
        setupSections()

        // Do any additional setup after loading the view.
    }
    
    func  setupSections()  {
        
        self.sections = [
            FormSection(
                entries: [
                nameForm,
                cardForm,
                cardPhotoForm,
                handHeldCardForm,
                frontCardForm,
                backCardForm
            ],
            headerText: nil
            )
        ]
    }

    
    func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(UINib(nibName: CardViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: CardViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: FiledViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: FiledViewCell.reuseIdentifier)
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        self.showIndicator()
        authenticationAPI.request(.liveEditAttestation(anchorAuthentication), type: Response<Authentication>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.navigationController?.popViewController(animated: true)
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func upload(_ url: URL) -> Single<Response<[RemoteFile]>> {
        return uploadAPI.request(.upload(url)).checkResponse()
    }
    
    func upload(_ url: URL, block: @escaping (RemoteFile) -> Void) {
        self.showIndicator()
        self.upload(url)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                block(response.data!.first!)
                self?.setupSections()
                self?.tableView.reloadData()
                self?.hideIndicator()
                
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: self.rx.disposeBag)
    }

}


extension AnchorAuthenticationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].formEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
}