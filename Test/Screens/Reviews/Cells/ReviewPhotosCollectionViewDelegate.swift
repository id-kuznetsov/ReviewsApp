import UIKit

final class ReviewPhotosCollectionView: UIView {
    
    private var photoURLs: [URL] = []
    private var imageProvider: ImageProviderProtocol?
    
    private lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumLineSpacing = Layout.photosSpacing
        flow.minimumInteritemSpacing = Layout.photosSpacing
        flow.itemSize = Layout.photoSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
    }

    required init?(coder: NSCoder) { fatalError() }

    func setPhotos(_ urls: [URL]?, imageProvider: ImageProviderProtocol?) {
        self.photoURLs = urls ?? []
        self.imageProvider = imageProvider
        collectionView.isHidden = self.photoURLs.isEmpty
        collectionView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

extension ReviewPhotosCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoURLs.count
    }
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        if let imageProvider {
            cell.configure(with: photoURLs[indexPath.item], imageProvider: imageProvider) 
        }
        return cell
    }
}

private extension ReviewPhotosCollectionView {
    struct Layout {
        static let photoSize = CGSize(width: 55.0, height: 66.0)
        static let photosSpacing: CGFloat = 8.0
    }
}
