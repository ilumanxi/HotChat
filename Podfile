# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

# ignore all warnings from all pods
inhibit_all_warnings!

#TXIMSDK_TUIKit_live_iOS 使用了 *.xcassets 资源文件，需要加上这条语句防止与项目中资源文件冲突。
install! 'cocoapods', :disable_input_output_paths => true

target 'HotChat' do
  # Comment the next line if you don't want to use dynamic frameworks
#    use_frameworks!
   
   
   use_modular_headers!
   

  # Pods for HotChat
    
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'NSObject+Rx'
    pod 'RxReachability'
    pod 'RxSwiftUtilities'
    pod 'CryptoSwift'
    pod 'DynamicColor'
    pod 'HandyJSON', "~> 5.0.3-beta"
    pod 'Reusable'
    pod 'Kingfisher'
    pod 'TagListView'
    pod 'SnapKit'
    pod 'Toast-Swift'
    pod 'HBDNavigationBar'
    pod 'Moya', :subspecs => ['Core', 'RxSwift']
    pod 'SPAlertController'
    pod 'MBProgressHUD'
    pod 'SwiftDate'
    pod 'SegementSlide'
    pod 'FSPagerView'
    pod 'ActiveLabel'
    pod "Koloda"
    pod 'MJRefresh'
    pod 'GKPhotoBrowser'
    pod 'Cache'
    pod 'ZLPhotoBrowser'
    pod 'WechatOpenSDK'
    pod 'SwiftyStoreKit'
    pod 'MagazineLayout'
    pod 'Blueprints'
    
    pod 'SYBPush/normal',  :git => 'https://github.com/isandboy/SYBPush.git'
    pod 'TXIMSDK_TUIKit_iOS'
    pod 'Masonry'
  
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
