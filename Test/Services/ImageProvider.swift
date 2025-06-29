//
//  ImageProvider.swift
//  Test
//
//  Created by Ilya Kuznetsov on 30.06.2025.
//

import UIKit

protocol ImageProviderProtocol {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

final class ImageProvider: ImageProviderProtocol {
    private let cache = NSCache<NSURL, UIImage>()
    private let queue = DispatchQueue(
        label: "image-provider-queue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }

        queue.async {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
                var image: UIImage?
                if let data, let img = UIImage(data: data) {
                    self?.cache.setObject(img, forKey: url as NSURL)
                    image = img
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            task.resume()
        }
    }
}

