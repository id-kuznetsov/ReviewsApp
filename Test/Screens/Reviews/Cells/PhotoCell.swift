//
//  PhotoCell.swift
//  Test
//
//  Created by Ilya Kuznetsov on 29.06.2025.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let reuseId = String(describing: PhotoCell.self)
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = Layout.cellCornerRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func configure(with url: URL, imageProvider: ImageProviderProtocol) {
        imageProvider.loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}

private enum Layout {
    static let cellCornerRadius: CGFloat = 8
}

