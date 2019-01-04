
Pod::Spec.new do |s|

  s.name         = "QIMCommon"
  s.version      = "0.0.5-beta"
  s.summary      = "Qunar chat App 6.0+ version QIMCommon"
  s.description  = <<-DESC
                   Qunar QIMCommon解决方案

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "http://gitlab.corp.qunar.com/qchat/libQIMCommon-iOS.git", :tag=> s.version.to_s}

  s.ios.deployment_target   = '9.0'
  s.resource_bundles = {'QIMCommonResource' => ['QIMCommon/QIMKitCommonResource/*.{png,aac,caf,pem}']}

  s.subspec 'PublicCommon' do |pc|

    pc.platform     = :ios, "9.0"

    pc.public_header_files = "QIMCommon/QIMKit/**/*.{h}", "QIMCommon/NoArc/**/*.{h}"

    pc.source_files = ""QIMCommon/Source/**/*.{h,m,c}", "QIMCommon/QIMKit/**/*.{h,m,c}", "QIMCommon/NoArc/**/*.{h,m}"
    pc.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'DEBUGLOG=1'}

    pc.requires_arc = false  
    pc.requires_arc = ['QIMCommon/Source/**/*', "QIMCommon/QIMKit/**/*.{h,m,c}"]

  end

    s.dependency 'QIMOpenSSL', '~> 1.0.1-beta'
    s.dependency 'QIMKitVendor', '~> 1.1.0-beta'
    s.dependency 'QIMDataBase', '~> 1.0.0-beta'
    s.dependency 'QIMPublicRedefineHeader', '~> 0.0.2-beta'
    s.dependency 'ASIHTTPRequest'
    s.dependency 'YYCache'
    s.dependency 'YYModel'
    s.dependency 'ProtocolBuffers'
    s.dependency 'CocoaAsyncSocket'
    s.dependency 'UICKeyChainStore'
    # 避免崩溃
    s.dependency 'AvoidCrash'
    
    s.dependency 'CocoaLumberjack'
    
    s.frameworks = 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'AudioToolbox', 'AVFoundation', 'UserNotifications', 'CoreTelephony','QuartzCore', 'CoreGraphics', 'Security'
    s.libraries = 'sqlite3.0', 'stdc++', 'bz2'

end
