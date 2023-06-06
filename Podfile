source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '14.0' # or platform :osx, '10.10' if your target is OS X.

target 'ThinkWhat' do
    use_frameworks!
    pod 'SwiftyVK'
    pod "TTRangeSlider"
    pod "YoutubePlayer-in-WKWebView"
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
               end
          end
   end
end