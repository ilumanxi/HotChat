# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'
 #plugin 'cocoapods-binary'
# https://blog.csdn.net/weixin_34183910/article/details/91389266
# ignore all warnings from all pods
#inhibit_all_warnings!

#TXIMSDK_TUIKit_live_iOS 使用了 *.xcassets 资源文件，需要加上这条语句防止与项目中资源文件冲突。
install! 'cocoapods', :disable_input_output_paths => true

target 'HotChat' do
  # Comment the next line if you don't want to use dynamic frameworks
#    use_frameworks!
    use_modular_headers!
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'NSObject+Rx'
    pod 'RxReachability'
    pod 'RxSwiftUtilities'
    pod 'RxCoreLocation'
    pod 'CryptoSwift'
    pod 'DynamicColor'
    pod 'HandyJSON', "~> 5.0.3-beta"
    pod 'Reusable'
    pod 'Kingfisher'
    pod 'TagListView'
    pod 'SnapKit'
    pod 'Toast-Swift'
    pod 'Moya', :subspecs => ['Core', 'RxSwift']
    pod 'SwiftDate'
    pod 'SegementSlide'
    pod 'PKHUD'
    pod 'URLNavigator'
    pod 'Tabman'
    
    pod 'FSPagerView'
    pod 'ActiveLabel'
    pod "Koloda"
    pod 'Cache'
    pod 'WechatOpenSDK'
    pod 'SwiftyStoreKit'
    pod 'MagazineLayout'
    pod 'Blueprints'
    pod 'WKWebViewJavascriptBridge'
    pod 'PIPKit'
    pod 'AMPopTip'
    
    pod 'TXIMSDK_TUIKit_iOS'
    pod 'TPNS-iOS'
    
    pod 'GKPhotoBrowser'
    pod 'Masonry'
    pod 'AFNetworking'
    pod 'InputKitSwift'
    pod 'SwifterSwift'
    pod 'Bugly'
    pod 'TZImagePickerController'
    pod 'HBDNavigationBar'
    pod 'MJRefresh'
    pod 'MJExtension'
    pod 'SPAlertController'
    pod 'MBProgressHUD'
    pod 'RangersAppLog'
    pod 'UMVerify'
    pod 'SVGAPlayer'
    
    #, :subspecs => [
     # 'Core',
      #'Log',
      #'Unique',  # 若需要采集IDFA，则引入Unique子库
      #'Host/CN'  # 若您的APP的数据存储在中国, 则选择 Host/CN。否则请根据地域选择相应 Host 子库
    #]
#    pod 'MLeaksFinder',  :configuration => 'Debug'
end
