# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

#plugin 'cocoapods-binary'

# ignore all warnings from all pods
inhibit_all_warnings!

#use_frameworks!
use_modular_headers!

#install! 'cocoapods', generate_multiple_pod_projects: true

install! 'cocoapods', disable_input_output_paths: true

target 'HotChat' do
  # Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!

  # Pods for HotChat
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'NSObject+Rx'
    pod 'RxReachability'
    pod 'RxSwiftUtilities'
    
    pod 'CryptoSwift'
    
    pod 'IBAnimatable'
    pod 'DynamicColor'

    pod 'HandyJSON', "~> 5.0.3-beta"
    
    pod 'Reusable'
    pod 'Kingfisher'
    pod 'TagListView'
#    pod 'Reusable'
    pod 'R.swift'
#    pod 'SwiftLint'
    pod 'SnapKit'
#    pod 'SwifterSwift'
    pod 'Toast-Swift'
    pod "CollectionKit"
    pod 'RealmSwift'
    pod 'HBDNavigationBar'
#    pod 'HXPageViewController'
#    pod 'WKWebViewJavascriptBridge'
    pod 'Moya', :subspecs => ['Core', 'RxSwift']
#    pod 'Alamofire'
    pod 'SPAlertController'
#    pod 'Presentr'
    pod 'MBProgressHUD'
    pod 'SwiftDate'
    pod 'NotificationBannerSwift'
#    pod 'BRPickerView'
    pod 'SegementSlide'
    pod 'FSPagerView'
    pod 'ActiveLabel'
    pod 'LGButton'
    pod "Koloda"
#    pod 'IBAnimatable'
    #列表视图空视图
    pod 'DZNEmptyDataSet'
    #图片浏览器
#    pod 'SKPhotoBrowser'
#    pod 'MediaBrowser'
    #图片选择器
#    pod 'TZImagePickerController'
    pod 'ZLPhotoBrowser'
    pod 'WechatOpenSDK'
    pod 'SwiftyStoreKit'
    
    #pod 'SYBPush/idfa',  :git => 'https://github.com/isandboy/SYBPush.git'
    pod 'SYBPush/normal',  :git => 'https://github.com/isandboy/SYBPush.git'
    pod 'TXIMSDK_TUIKit_iOS'
  #  pod 'MJRefresh', '~> 3.2.0', :modular_headers => true # 刷新，以后可以考虑用UIRefreshControl
  #  pod 'TYPagerController', :modular_headers => true

  target 'HotChatTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HotChatUITests' do
    # Pods for testing
  end

end



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        end
    end
end
