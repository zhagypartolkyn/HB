# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'HB' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HB
 # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # [ FIREBASE START]
	pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
	pod 'Firebase/Firestore'
	pod 'Firebase/Database'
	pod 'Firebase/Storage'
	pod 'Firebase/Messaging'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Functions'
  pod 'GoogleSignIn'                      # Google Auth
  pod 'FBSDKLoginKit'                     # Facebook Auth
  # [ FIREBASE END]
  
  
  # [ SPPermissions START]
	pod 'SPPermissions/Camera'
  pod 'SPPermissions/Microphone'
	pod 'SPPermissions/PhotoLibrary'
	pod 'SPPermissions/Notification'
	pod 'SPPermissions/Location'
  # [ SPPermissions END]

  pod 'Mantis'                       # Photo Cropper
  pod 'FlagPhoneNumber'              # Phone number input
  
  pod 'SwiftDate'
	pod 'SwiftLocation'
  pod 'MessageKit'
  pod 'MessageInputBar'

	pod 'Kingfisher'
	pod 'SDWebImage'
  pod 'SDWebImageSwiftUI'
  
  pod 'Tabman'
  pod 'IQKeyboardManager'
  
  pod 'SVProgressHUD'
  pod 'SkeletonView'

  pod 'SnapKit'
  pod 'GooglePlaces'
  

  pod 'Introspect'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
      end
    end
  end

end
