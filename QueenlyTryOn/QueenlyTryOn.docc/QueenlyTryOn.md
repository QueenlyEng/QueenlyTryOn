# ``Queenly Virtual Try On SDK``

## Overview
Build virtual try on into your iOS mobile app.

The Queenly Virtual Try-On iOS SDK helps you build a customizable virtual try-on feature into your iOS app. We provide powerful and customizable UI screens and elements that you can use out-of-the-box to allow your customers to try on your products with both generative AI and Augmented Reality.

## Set Up Queenly

### Swift Package Manager Integration

1. In Xcode, select File > Add Packages… and enter https://github.com/QueenlyEng/QueenlyTryOn as the repository URL.* *Link coming soon!

2. Select the latest version number from our releases page.

3. Add the QueenlyTryOn product to the target of your app.

### Cocoapods Integration

1. If you haven’t already, install the latest version of CocoaPods.

2. If you don’t have an existing Podfile, run the following command in the terminal to create one: pod init

3. Add pod 'QueenlyTryOn' to your Podfile

4. Run pod install

5. Use the .xcworkspace file to open your project in Xcode, instead of the .xcodeproj

### Carthage Integration *Instructions coming soon!

## Integration

i. Add Camera and Photo Library Usage Description in your Info.plist 

ii. Initialize QueenlyTryOn in AppDelegate - Configure the SDK with a provided authentication key, and account id to send requests to the Queenly server.  
```
    QueenlyTryOn.configure(authKey: "fLnTCkr5iTeM5gQhbl21WZOqK1JR3lOs9PjwIwPUdQ1N62Up",
    accountId: "16553") { isAuthorized in
    }
```

iii. Check if product can be used in try on environment. Refer to code below:
```
    QueenlyTryOn.isEligibleForVTO(productTitle: "some-title") { isEligible, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Error - \(error.type.rawValue)")
            } else {
                if isEligible {
                    // add or unhide button - refer to the next step on how to create the try on button
                }
            }
        }
    }
```

iv. If eligible, create a QueenlyTryOnButton with accountId, productId , presentingVC and an optional color. This button is customizable with a default title of “🪞Try on this item”. Sample code in Swift below:
```
  let button1 = QueenlyTryOnButton(productId: "someId", color: nil, presentingVC: self)
  button1.translatesAutoresizingMaskIntoConstraints = false
  button1.delegate = self
  button1.setTitle("Try on this top", font: .systemFont(ofSize: 14, weight: .medium))
  button1.setIcon(UIImage(named: "ar_icon")?.withRenderingMode(.alwaysTemplate),
                 dimension: CGSize(width: 20, height: 20))
  button1.contentSpacing = 10

  button1.heightAnchor.constraint(equalToConstant: 44).isActive = true

  let button2 = QueenlyTryOnButton(productId: "someId", color: "Green", presentingVC: self)
  button2.translatesAutoresizingMaskIntoConstraints = false
  button2.delegate = self
  button2.backgroundColor = .black
  button2.buttonTintColor = .white
  button2.heightAnchor.constraint(equalToConstant: 44).isActive = true
```

iv. Handle callbacks - The QueenlyTryOnDelegate object receives messages at various stages of the try on process.

```
  func queenlyTryOnDidPresent(_ queenlyTryOnVC: QueenlyARTryOnViewController)
  func queenlyTryOnDidFinish(_ queenlyTryOnVC: QueenlyARTryOnViewController)
  func queenlyTryOn(_ queenlyTryOnVC: QueenlyARTryOnViewController, didFailWithError error: QueenlyTryOnError)
```

3. Yay you're done :D

