//
//  ViewController.swift
//  Pairs
//
//  Created by 风起兮 on 2021/1/27.
//

import UIKit
import AMPopTip
import Kingfisher


extension CGRect {
    
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        
        set {
            
        }
    }
    
    func point(angle: CGFloat) -> CGPoint {
    
        let angle: CGFloat = angle
        let distance = width / 2
        
        let x =  center.x + distance * cos(angle)
        let y = center.y + distance * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
}



class VerticalButton: UIControl {
    

    var imageView: UIImageView!
    
    var titleLabel: UILabel!
    
    var cotentStackView: UIStackView!
    
    let defaultImageSize = CGSize(width: 58, height: 58)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendActions(for: .touchUpInside)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
       let height =  defaultImageSize.height + cotentStackView.spacing + titleLabel.sizeThatFits(size).height
        
        return CGSize(width: defaultImageSize.width, height: height)
    }
    
    func commonInit() {
        
        imageView = UIImageView()
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        cotentStackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        cotentStackView.spacing = 2
        cotentStackView.axis = .vertical
        cotentStackView.alignment = .center
        cotentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cotentStackView)
        
        
        imageView.widthAnchor.constraint(equalToConstant: defaultImageSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: defaultImageSize.height).isActive = true
        
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)

        cotentStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cotentStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        imageView.layer.cornerRadius = defaultImageSize.width / 2
        imageView.clipsToBounds = true
        super.layoutSubviews()
    }
}

@IBDesignable
class CircleView: UIView {
    
    
    @IBInspectable
    var lineWidth: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderColors: [UIColor]? = [UIColor(hexString: "FF9DB4"), UIColor(hexString: "FF9DB4")] {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            
        }
        get {
            super.backgroundColor
        }
    }
   
    
    var gradientLayer: CAGradientLayer!
    
    var shapeLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        gradientLayer = CAGradientLayer()
        shapeLayer = CAShapeLayer()
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    
    override func layoutSubviews() {
        
        let path = UIBezierPath(arcCenter: bounds.center, radius: bounds.width / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPhase = 0.8
        shapeLayer.path = path.cgPath
        
        gradientLayer.colors = borderColors?.compactMap { $0.cgColor }
        gradientLayer.cornerRadius = bounds.height / 2
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = bounds
        
        super.layoutSubviews()
    }
}

class CircleImageView: UIImageView {
    
    
    var layoutAlignmentRectInsets: UIEdgeInsets = .zero
    
    override var alignmentRectInsets: UIEdgeInsets {
        
        return layoutAlignmentRectInsets
    }
}

class PairsViewController: UIViewController, StoryboardCreate, IndicatorDisplay {
    
    static var storyboardNamed: String { "Community" }
    
    @IBOutlet weak var outerCircleView: CircleView!
    
    @IBOutlet weak var innerCircleView: CircleView!
    
    @IBOutlet weak var pinkImageView: CircleImageView!
    
    @IBOutlet weak var cyanImageView: CircleImageView!
    
    
    @IBOutlet weak var orangeImageView: CircleImageView!
    
    @IBOutlet weak var buleImageView: CircleImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var pairButton: GradientButton!
    
    var callType: CallType = .video
    
    let API = Request<FateMatchAPI>()
    
    var users: [User] = [] {
        didSet {
            if !users.isEmpty {
                showUser()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "缘分匹配"
        
        navigationItem.leftBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "back-red"), style: .plain, target: self, action: #selector(back))]
        
        hbd_barAlpha = 0
        hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor : textColor]
        
        commonLayout()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()

        circleAnimation(
            animationView: pinkImageView,
            pathView: outerCircleView,
            duration: 6,
            startAngle: .pi  * 0.75,
            endAngle: .pi * 2.75)

        circleAnimation(
            animationView: cyanImageView,
            pathView: outerCircleView,
            duration: 6,
            startAngle: .pi * 1.25,
            endAngle: .pi * 3.25)

        circleAnimation(
            animationView: orangeImageView,
            pathView: innerCircleView,
            duration: 6 * 1.75,
            startAngle: .pi  * 0.75,
            endAngle: .pi * 2.75)

        circleAnimation(
            animationView: buleImageView,
            pathView: innerCircleView,
            duration: 6 * 1.75,
            startAngle: .pi * 1.25,
            endAngle: .pi * 3.25)
        
        buttonAnimation(videoButton)

        
        API.request(.matchList, type: Response<[User]>.self)
            .verifyResponse()
            .retry(3)
            .subscribe(onSuccess: { [weak self] response in
                self?.users = response.data ?? []
                
            }, onError: { [weak self] error in
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    var currentUserIndex = -1
    
    var currentPointIndex = -1
    
    let maximumShowCount = 4
    
    var timer: Timer?
    
    func showUser()  {
        
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
           
            if self.currentShowCount < self.maximumShowCount {
                self.showNext()
            }
        }
        timer?.fire()
    }
    
    func showNext() {
        let count = users.count
        let userIndex = (currentUserIndex + 1) % count
        let pointIndex = (currentPointIndex + 1) % maximumShowCount
        
        currentUserIndex = userIndex
        currentPointIndex = pointIndex
        showUserView(at: userIndex, pointIndex: pointIndex)
    }
    
    
    private var cacheViews: [VerticalButton] = []
    
    var currentShowCount = 0
    
    func showUserView(at userIndex: Int, pointIndex: Int) {
    
        let user = users[userIndex]
        
        let userInfoView = userView(title: user.region, url: URL(string: user.headPic))
        userInfoView.tag = userIndex
        
        let angles: [CGFloat] = [.pi, 1.5 * .pi, 2 * .pi, 0.5 * .pi]
        
        if pointIndex < 3 { //外圈
            userInfoView.center = outerCircleView.frame.point(angle: angles[pointIndex])
        }
        else {
            userInfoView.center = innerCircleView.frame.point(angle: angles[pointIndex])
        }
        containerView.addSubview(userInfoView)
        
        currentShowCount += 1
        
        userInfoView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 2) {
            userInfoView.transform = .identity
        } completion: { finish in
            let duration: TimeInterval = 3.0 + 1.0 * (TimeInterval(4 - pointIndex) + 0.01) / 4.0
            self.delay(duration: duration) {
                userInfoView.removeFromSuperview()
                self.containerView.viewWithTag(1000 + userIndex)?.removeFromSuperview()
                self.cacheViews.append(userInfoView)
                self.currentShowCount -= 1
            }
        }
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func delay(duration: CFTimeInterval, execute: @escaping () -> Void){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: execute)
    }
    
    private func userView(title: String, url: URL?) -> VerticalButton {
        
        let infoView: VerticalButton
        
        if cacheViews.isEmpty {
            infoView = VerticalButton()
        }
        else {
            infoView = cacheViews.removeFirst()
        }
        
        infoView.imageView.kf.setImage(with: url)
        infoView.titleLabel.text = title
        infoView.titleLabel.textColor = textColor
        infoView.sizeToFit()
        infoView.addTarget(self, action: #selector(userViewDidTapped), for: .touchUpInside)
        return infoView
    }
    
    
    let popTip = PopTip()
    
    @objc func userViewDidTapped(_ sender: VerticalButton) {
        let user = users[sender.tag]
        popTip.tag = 1000 + sender.tag
        popTip.show(text: user.introduce, direction: .auto, maxWidth: 200, in: containerView, from: sender.frame)
    }
    
    
    let textColor = UIColor(hexString: "#EC4F81")
    let disabledTextColor = UIColor(hexString: "#E29BAF")

    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var videoCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCenterXConstraint: NSLayoutConstraint!
    
    
    @IBAction func videoButtonTapped(_ sender: UIButton) {
        
       buttonAnimation(sender)

    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        buttonAnimation(sender)
    }
    
    
    @IBAction func pairButtonTapped(_ sender: Any) {
        
        showIndicator()
        API.request(.matchGirl(callType), type: Response<[String :Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                guard let self = self else { return }
                self.hideIndicator()
                if let userId = response.data?["userId"] as? String {
                    CallHelper.share.call(userID: userId, callType: self.callType, callSubType: .pair)
                }
                else {
                    let vc = PairCallViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if let _ = vc.navigationController {
                            vc.navigationController?.popViewController(animated: true)
                            self.showMessageOnWindow("你与她擦肩而过...")
                        }
                    }
                }
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
        
       
    }
    
    func buttonAnimation(_ button: UIButton) {
        
        let title = NSAttributedString(string: "开启匹配", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        let price: NSAttributedString
        
        if videoButton == button {
            
            callType = .video
            price = NSAttributedString(string: "\n(2500能量/分钟)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
            
            videoCenterXConstraint.priority = .defaultHigh
            audioCenterXConstraint.priority = .defaultHigh - 1
            
            videoButton.titleLabel?.font = .systemFont(ofSize: 16)
            audioButton.titleLabel?.font = .systemFont(ofSize: 12)
            
            videoButton.setTitleColor(textColor, for: .normal)
            audioButton.setTitleColor(disabledTextColor, for: .normal)
        }
        else {
            
            callType = .audio
            price = NSAttributedString(string: "\n(1000能量/分钟)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
            
            videoCenterXConstraint.priority = .defaultHigh - 1
            audioCenterXConstraint.priority = .defaultHigh
            
            videoButton.titleLabel?.font = .systemFont(ofSize: 12)
            audioButton.titleLabel?.font = .systemFont(ofSize: 16)
            
            videoButton.setTitleColor(disabledTextColor, for: .normal)
            audioButton.setTitleColor(textColor, for: .normal)
        }
        
        let string =  NSMutableAttributedString()
        string.append(title)
        
        if !AppAudit.share.energyStatus {
            string.append(price)
        }
        
        pairButton.titleLabel?.numberOfLines = 2
        pairButton.titleLabel?.textAlignment = .center
        pairButton.setAttributedTitle(string, for: .normal)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn ) {
            
            self.view.layoutIfNeeded()
        } completion: { finish in
            
        }
    }
    
    private func commonLayout() {
        
        pinkImageView.layoutAlignmentRectInsets = UIEdgeInsets(top: 0, left:  0, bottom: innerCircleView.lineWidth / 2, right: 0)
        cyanImageView.layoutAlignmentRectInsets = UIEdgeInsets(top: innerCircleView.lineWidth / 2, left:  0, bottom: 0, right: 0)
        orangeImageView.layoutAlignmentRectInsets = UIEdgeInsets(top: 0, left:  0, bottom: 0, right: innerCircleView.lineWidth / 2)
        buleImageView.layoutAlignmentRectInsets = UIEdgeInsets(top: 0, left:  innerCircleView.lineWidth / 2, bottom: 0, right: 0)
    }
    
    private func circleAnimation(animationView: UIView, pathView: UIView, duration: CFTimeInterval,  delay: TimeInterval = 0, startAngle: CGFloat, endAngle: CGFloat) {
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")

        pathAnimation.duration = duration
        pathAnimation.path = UIBezierPath(arcCenter: pathView.frame.center, radius: pathView.bounds.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        pathAnimation.calculationMode = .paced
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = .forwards
        pathAnimation.repeatCount = .greatestFiniteMagnitude
        pathAnimation.rotationMode = .rotateAuto
        animationView.layer.add(pathAnimation, forKey: "pathAnimation")
    }
}

