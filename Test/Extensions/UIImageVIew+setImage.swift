//
//  UIImageVIew+setImage.swift
//  Test
//
//  Created by Ilya Kuznetsov on 30.06.2025.
//

import UIKit

extension UIImageView {
    func setImage(from url: URL, placeholder: UIImage?, using provider: ImageProviderProtocol) {
        self.image = placeholder
        provider.loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image ?? placeholder
            }
        }
    }
}
