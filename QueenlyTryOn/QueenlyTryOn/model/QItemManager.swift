//
//  QItemManager.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import Foundation
import ARKit

struct QItemManager {
    let api = QAPI()
    
    func fetchItem(productTitle: String, completion: @escaping (_ item: QItem?, _ error: QAPIError?) -> ()) {
        let productTitleFormatted = productTitle.uppercased().getUrlQueryFormattedString()
        api.loadData(fromUrlString: "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-vtoimagemodels?productId=\(productTitleFormatted)&idType=TITLE_STYLED&accountId=\(QueenlyTryOn.accountId)&authenticationKey=\(QueenlyTryOn.authKey)") { data in
            let res = parseItemJSON(data)
            completion(res.item, res.error)
        }
    }
    
    func fetchItems(productIds: [String],
                    completion: @escaping (_ items: [QItem]) -> ()) {
        var items: [QItem?] = Array(repeating: nil, count: productIds.count)
        let dispatchGroup = DispatchGroup()
        for i in 0..<productIds.count {
            let productId = productIds[i]
            let urlString = "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-vtoimagemodels?accountId=\(QueenlyTryOn.accountId)&authenticationKey=\(QueenlyTryOn.authKey)&productId=\(productId)"
            dispatchGroup.enter()
            api.loadData(fromUrlString: urlString) { data in
                if let item = parseItemJSON(data).item {
                    items[i] = item
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(items.compactMap { $0 })
        }
    }
    
    private func parseItemJSON(_ data: Data?) -> (item: QItem?, error: QAPIError?) {
        guard let data = data else { return (nil, nil) }
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([QItem].self, from: data)
            return (items.first, nil)
        } catch {
            return (nil, api.parseError(data))
        }
    }    
    
}
