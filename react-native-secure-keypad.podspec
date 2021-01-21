require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-secure-keypad"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://h-brick.com.git", :tag => "#{s.version}" }
  # s.frameworks = "AudioToolbox"
  s.resources = 'ios/Library/Resources/**/*.{png}'

  s.xcconfig = { 
    # here on LDFLAG, I had to set -l and then the library name (without lib prefix although the file name has it).
    #  'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/',
   "FRAMEWORK_SEARCH_PATHS" => '"${PODS_ROOT}/../../node_modules/react-native-secure-keypad/ios/Library"',
  }
  s.source_files = "ios/**/*.{h,m,mm,swift}"
    
  s.dependency "React-Core"
  s.prefix_header_contents = '
  #import <Availability.h>

  #define SYSTEM_VERSION_EQUAL_TO(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame)
  #define SYSTEM_VERSION_GREATER_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending)
  #define SYSTEM_VERSION_LESS_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)
  #define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
  #define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

  #define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  #define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
  #define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

  #define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
  #define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
  #define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
  #define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

  #define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
  #define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
  #define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
  #define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

  #ifndef __IPHONE_3_0
  #warning "This project uses features only available in iOS SDK 3.0 and later."
  #endif

  #ifdef __OBJC__
      #import <UIKit/UIKit.h>
      #import <Foundation/Foundation.h>
  #endif
  '

end
