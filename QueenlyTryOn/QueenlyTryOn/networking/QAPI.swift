//
//  QAPI.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import Foundation

struct QAPI {    
    func loadData(fromUrlString urlString: String, completion: @escaping (_ data: Data?) -> ()) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error loading data:", error?.localizedDescription ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                completion(data)
            }
            
            task.resume()
        } else {
            completion(nil)
        }
    }
    
    func parseError(_ data: Data?) -> QAPIError? {
        guard let data = data else { return nil }
        do {
            let decoder = JSONDecoder()
            let errorMessageData = try decoder.decode([String].self, from: data)
            if let errorMessage = errorMessageData.first, errorMessage.contains("Invalid authentication key") {
                return QAPIError(type: .invalidAuthKey)
            }
            return QAPIError(type: .unknown)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func logSession(productTitle: String, actionType: QTryOnActionType) {
        let sessionId = UUID().uuidString
        let productTitleFormatted = productTitle.uppercased().getUrlQueryFormattedString()
        let urlString = "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-logvtosession?sessionId=\(sessionId)&productId=\(productTitleFormatted)&actionType=\(actionType.rawValue)&userId=\(QueenlyTryOn.userId)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error logging session:", error.localizedDescription)
                    return
                }
            }
            
            task.resume()
        }
    }
}
