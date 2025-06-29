import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State, Bool) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: SnakeCaseJSONDecoder
    private let imageProvider: ImageProviderProtocol

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: SnakeCaseJSONDecoder = SnakeCaseJSONDecoder(),
        imageProvider: ImageProviderProtocol = ImageProvider()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
        self.imageProvider = imageProvider
    }
    
    func getImageProvider() -> ImageProviderProtocol {
        imageProvider
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    private func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            let oldCount = state.items.count
            let newItems = reviews.items.map(makeReviewItem)
            state.items += newItems
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count

            state.items.removeAll(where: { $0 is ReviewCountCellConfig })

            if !state.shouldLoad {
                let countText = "\(reviews.count) отзывов"
                    .attributed(font: .reviewCount, color: .reviewCount)
                let countItem = ReviewCountCellConfig(reviewCountText: countText)
                state.items.append(countItem)
            }
            
            let added = state.items.count > oldCount
            onStateChange?(state, added)
        } catch {
            state.shouldLoad = true
            onStateChange?(state, false)
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewCellConfig)?.id == id }),
            var item = state.items[index] as? ReviewCellConfig
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state, false)
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let authorFullName = ("\(review.firstName) \(review.lastName)").attributed(font: .username)
        let avatarURL: URL? = {
            if let avatarString = review.avatarUrl,
               let url = URL(string: avatarString) {
                return url
            }
            return Bundle.main.url(forResource: "EmptyAvatar", withExtension: "jpg")
        }()
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let photoURLs: [URL] = (review.photos ?? []).compactMap { URL(string: $0) }
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let item = ReviewItem(
            authorFullName: authorFullName,
            avatarURL: avatarURL,
            ratingImage: ratingImage,
            photoURLs: photoURLs,
            reviewText: reviewText,
            created: created,
            onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            },
            imageProvider: imageProvider
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}

// MARK: - Refresh

extension ReviewsViewModel {
    func refresh() {
        state = State()
        onStateChange?(state, false) 
        getReviews()
    }
}
