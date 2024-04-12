//
//  QAccountManager.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import Foundation

struct QAccountManager {
    let api = QAPI()
    
    func fetchAccount(completion: @escaping (_ account: QAccount?, _ error: QAPIError?) -> ()) {
        api.loadData(fromUrlString: "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-accountinfo?accountId=\(QueenlyTryOn.accountId)&authenticationKey=\(QueenlyTryOn.authKey)") { data in
            let res = parseJSON(data)
            completion(res.account, res.error)
        }
    }
    
    func parseJSON(_ data: Data?) -> (account: QAccount?, error: QAPIError?) {
        guard let data = data else { return (nil, nil) }
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([QAccount].self, from: data)
            return (items.first, nil)
        } catch {
            return (nil, api.parseError(data))
        }
    }
}
