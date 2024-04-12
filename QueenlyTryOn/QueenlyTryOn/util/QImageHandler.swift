//
//  QImageHandler.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

struct QImageHandler {
    func image(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: QueenlyTryOn.self), with: nil)
    }
    
    func loadImage(fromUrl url: URL?, completion: @escaping (_ image: UIImage?) -> ()) {
        guard let url = url else {
            completion(nil)
            return
        }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
