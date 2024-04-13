Pod::Spec.new do |spec|

  spec.name         = "QueenlyTryOn"
  spec.version      = "1.0.11"
  spec.summary      = "QueenlyTryOn is a framework to build virtual try on into your iOS mobile app."
  spec.description  = "The Queenly Virtual Try-On iOS SDK helps you build a customizable virtual try-on feature into your iOS app. We provide powerful and customizable UI screens and elements that you can use out-of-the-box to allow your customers to try on your products with both generative AI and Augmented Reality."
 
  spec.homepage     = "https://github.com/QueenlyEng/QueenlyTryOn"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors      = { "moralesmicaella" => "morales.micaella@gmail.com", "kaffyzoo" => "kathy.m.zhou@gmail.com" }

  spec.platform     = :ios, "14.0"

  spec.source       = { :git => "https://github.com/QueenlyEng/QueenlyTryOn.git", :tag => spec.version.to_s }


  spec.source_files  = "QueenlyTryOn/**/*.{h,m,swift}"

  spec.resources = ['QueenlyTryOn/**/*.{lproj,png,json,xcassets}']
  spec.ios.resource_bundle = {
    "QueenlyTryOn" => "QueenlyTryOn/**/*.{lproj,png,json,xcassets}"
  }
  
  spec.frameworks = "Foundation", "UIKit", "ARKit", "Vision", "Photos", "PhotosUI", "VideoToolbox"
  
  spec.swift_version = "5.9"

end
