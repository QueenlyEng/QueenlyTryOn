//
//  QTryOnSet.swift
//
//
//  Created by Mica Morales on 6/12/24.
//

import Foundation

struct QTryOnSet {
    var top: QItem?
    var bottom: QItem?
    var set: QItem?
    
    var itemStack: [QItem] = []
    var lastAddedItem: QItem? {
        return itemStack.last ?? allItems.last
    }
    
    var allItems: [QItem] {
        if let set = set {
            return [set]
        }
        if let top = top, isSwimwear(top) {
            return [top, bottom].compactMap { $0 }
        }
        return [bottom, top].compactMap { $0 }
    }
    
    var allProductIds: Set<String> {
        return Set(allItems.compactMap { $0.productId })
    }
    
    
    mutating func addItem(_ item: QItem) {
        if (item.styleTags.contains("top") && !isSet(item)) || isSwimwear(item) {
            top = item
            set = nil
        } else if item.styleTags.isInterstecting(with: ["bottom", "skirt", "shorts", "pants", "leggings"]) && !isSet(item) {
            bottom = item
            set = nil
        } else {
            set = item
            top = nil
            bottom = nil
        }
        
        itemStack.append(item)
    }
    
    mutating func removeItem(_ item: QItem) {
        if let top = top, top.productId == item.productId {
            self.top = nil
        } else if let bottom = bottom, bottom.productId == item.productId {
            self.bottom = nil
        } else if let set = set, set.productId == item.productId {
            self.set = nil
        }
        
        if let index = (itemStack.firstIndex { $0.productId == item.productId }) {
            itemStack.remove(at: index)
        }
    }
    
    private func isSet(_ item: QItem) -> Bool {
        return item.styleTags.isInterstecting(with: ["dress", "romper", "jumpsuit", "set"])
    }
    
    private func isSwimwear(_ item: QItem) -> Bool {
        return item.styleTags.isInterstecting(with: ["swimsuit", "bodysuit", "bikini"])
    }
}
