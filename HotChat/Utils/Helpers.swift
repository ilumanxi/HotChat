//
//  Helpers.swift
//  MoreMenu
//
//  Created by 风起兮 on 2019/4/8.
//  Copyright © 2019 风起兮. All rights reserved.
//

import UIKit
import SnapKit

class BackButton: UIButton {
    
    static let defaultSize: CGSize = CGSize(width: 22, height:22)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: BackButton.defaultSize))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return BackButton.defaultSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return BackButton.defaultSize
    }
}

extension UIWindow {
    
       func present(_ viewController: UIViewController) {
           var runLoopFindPresentedViewController = rootViewController
           while ((runLoopFindPresentedViewController?.presentedViewController) != nil) {
               runLoopFindPresentedViewController = runLoopFindPresentedViewController?.presentedViewController
           }
           runLoopFindPresentedViewController?.present(viewController, animated: true, completion: nil)
      }
}

extension UIViewController {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }

    var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    var safeAreaTop: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.top
        } else {
            return topLayoutGuide.length
        }
    }

    
    func addChild(_ viewController: UIViewController, to containerView: UIView) {
        addChild(viewController)
        containerView.addChildSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func addChild(_ viewController: UIViewController, to layoutGuide: UILayoutGuide) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            ])
    }
    
}


extension UIViewController {
    var safeTop: SnapKit.ConstraintItem {
        
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.top
        } else {
            return topLayoutGuide.snp.bottom
        }
    }
    
    var safeBottom: SnapKit.ConstraintItem {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.bottom
        } else {
            return bottomLayoutGuide.snp.top
        }
    }
    
}


extension UIView {
    // Add a subview as `self` is a container. Layout the added `child` to match `self` size.
    func addChildSubview(_ child: UIView) {
        
        addSubview(child)
        child.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

extension UIView {
    
    public var safeTop: SnapKit.ConstraintItem {
        
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.snp.top
        } else {
            return snp.top
        }
    }
    
    public var safeBottom: SnapKit.ConstraintItem {
        
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.snp.bottom
        } else {
            return snp.bottom
        }
    }
}

extension UIView {
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}


class MinimumHitButton: UIButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        var touchBounds = self.bounds
        let diameter: CGFloat = 44.0   //Minimum Hit Target Size
        let minimum = min(touchBounds.width, touchBounds.height)
        if minimum < diameter {
            let expansion = diameter - minimum
            touchBounds = touchBounds.insetBy(dx: -expansion, dy: -expansion)
        }
        
        return touchBounds.contains(point)
    }
}


class InsertLabel: UILabel {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       textAlignment = .center
    }
    
    var insert: CGFloat = 4 {
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insert
        size.height += insert
        return size
    }
}


extension UIColor {
    
    static var random: UIColor {
        return UIColor.random()
    }
    
    static func random(
         hue: CGFloat = CGFloat.random(in: 0...1),
         saturation: CGFloat = CGFloat.random(in: 0.5...1), // from 0.5 to 1.0 to stay away from white
         brightness: CGFloat = CGFloat.random(in: 0.5...1), // from 0.5 to 1.0 to stay away from black
         alpha: CGFloat = 1) -> UIColor
    {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
}



extension Data {
    
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        assert(count >= MemoryLayout.size(ofValue: value), "Numeric conversion error, does not match \(T.self)")
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    func toValue<T>() -> T where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        assert(count >= MemoryLayout.size(ofValue: value), "Numeric conversion error, does not match \(T.self)")
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    
   var bytes: UnsafeRawPointer {
        return (self as NSData).bytes
    }
}


extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    
    func toAttributedString(fontSize: CGFloat, textColor: UIColor, lineSpacing: CGFloat, alignment: NSTextAlignment  = .left) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        var attributes: [NSAttributedString.Key : Any] = [:]
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = UIFont.systemFont(ofSize: fontSize)
        attributes[.foregroundColor] = textColor
       return NSAttributedString(string: self, attributes: attributes)
    }
}

extension NSMutableAttributedString{
    func setAttributeaddAttribuetWithColorAndFont(color:UIColor,font:CGFloat,startIndex:Int,endIndex:Int) {
        self.addAttributes(
            [NSAttributedString.Key.foregroundColor : color,
             NSAttributedString.Key.font : UIFont.systemFont(ofSize: font)],
            range: NSRange(location: startIndex, length: endIndex))
    }
}


extension Thread {
    
    @objc class func safeSync(block: @escaping () -> Void) {
        if isMainThread {
            block()
        }
        else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
    
    @objc class func safeAsync(block: @escaping () -> Void) {
        if isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
}


extension Array {
    
    mutating func modifyForEach(_ body: (_ index: Index, _ element: inout Element) -> ()) {
        for index in indices {
            modifyElement(at: index) { body(index, &$0) }
        }
    }

    mutating func modifyElement(at index: Index, _ modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}

enum Log {
    static func assertionFailure(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line)
    {
        Swift.assertionFailure("[HotChat] \(message())", file: file, line: line)
    }
    
    static func fatalError(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Never
    {
        Swift.fatalError("[HotChat] \(message())", file: file, line: line)
    }
    
    static func precondition(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    )
    {
        Swift.precondition(condition(), "[HotChat] \(message())", file: file, line: line)
    }
    
    static func print(_ items: Any...) {
        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }
        Swift.print("[HotChat] \(s)")
    }
}


protocol StoryboardCreate: class {
    static var bundle: Bundle? { get }
    static var storyboardNamed: String { get }
    static var controllerIdentifier: String? { get }
    static func loadFromStoryboard() -> Self
   
}

extension StoryboardCreate where Self: UIViewController {
    
     static var bundle: Bundle? { return nil }
    
     static var identifier: String? { return nil }
    
     static var controllerIdentifier: String? { return nil }
    
     static func loadFromStoryboard() -> Self {
        let bundle = self.bundle ?? .main
        
        let storyboard = UIStoryboard(name: storyboardNamed, bundle: bundle)
        let identifier = controllerIdentifier ?? String(describing: Self.self)
        
        guard let viewControler = storyboard.instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError(
              "Failed to dequeue a Controler with identifier \(identifier) matching type \(Self.self). "
                + "Check that the controllerIdentifier is set properly in your \(storyboardNamed) .Storyboard "
                + "and that you registered the \(bundle) storyboard beforehand")
        }
        
        return viewControler
    }
}

extension UIDevice {
    
    static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
    }()
}

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [CGColor]) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        
        UIGraphicsBeginImageContext(gradient.bounds.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
