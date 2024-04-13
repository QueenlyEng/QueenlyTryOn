//
//  Bundle+Extension.swift
//
//  Created by Mica Morales on 4/12/24.
//

import Foundation

#if !SWIFT_PACKAGE
extension Bundle {
    static var module: Bundle {
        return Bundle.main
    }
}
#endif
