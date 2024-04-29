//
//  QueenlyTryOn.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

@objc
public protocol QueenlyTryOnDelegate {
    func queenlyTryOnDidPresent(_ queenlyTryOnVC: QueenlyARTryOnViewController)
    func queenlyTryOnDidFinish(_ queenlyTryOnVC: QueenlyARTryOnViewController)
    func queenlyTryOn(_ queenlyTryOnVC: QueenlyARTryOnViewController, didFailWithError error: QTryOnError)
}

@objc
public class QueenlyTryOn: NSObject {
    
    private static let api = QAPI()
    
    static var authKey: String = ""
    static var accountId: String = ""
    static var userId: String = ""
    static var account: QAccount = QAccount()
    static var logo: UIImage? = nil
    static var brandColor: UIColor = UIColor(red: 0.41, green: 0.16, blue: 0.92, alpha: 1.00)
    
    @objc
    public static func configure(authKey: String, accountId: String, completion: @escaping (_ isAuthorized: Bool) -> ()) {
        QueenlyTryOn.authKey = authKey
        QueenlyTryOn.accountId = accountId
        
        let accountManager = QAccountManager()
        let imageHandler = QImageHandler()
        accountManager.fetchAccount { account, error in
            if let account = account {
                QueenlyTryOn.account = account
                imageHandler.loadImage(fromUrl: account.accountLogoUrl) { image in
                    QueenlyTryOn.logo = image
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @objc
    public static func setUserId(_ userId: String) {
        QueenlyTryOn.userId = userId
    }
    
    @objc
    public static func setBrandColor(_ color: UIColor) {
        QueenlyTryOn.brandColor = color
    }
    
    @objc
    public static func isEligibleForVTO(productTitle: String, completion: @escaping (_ isEligible: Bool, _ error: QAPIError?) -> ()) {
        let productTitleFormatted = productTitle.uppercased().getUrlQueryFormattedString()
        api.loadData(fromUrlString: "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-eligibleforvto?productId=\(productTitleFormatted)&idType=TITLE_STYLED&accountId=\(accountId)&authenticationKey=\(authKey)") { data in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([Bool].self, from: data)
                    completion(json.first ?? false, nil)
                } catch {
                    print("Error: \(error)")
                    completion(false, api.parseError(data))
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
}
