source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0' # or platform :osx, '10.10' if your target is OS X.

target 'ThinkWhat' do
    use_frameworks!
    pod 'GoogleSignIn'
    pod 'SwiftyVK'
    pod "TTRangeSlider"
    pod 'SwiftyJSON'
    pod 'L10n-swift', '~> 5.10'
    pod "Agrume"
    pod "FlagKit"
    pod 'Alamofire', '~> 5.5'
    pod "YoutubePlayer-in-WKWebView"
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end