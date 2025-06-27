import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Отзывы"
        setupViewModel()
        setupRefreshControl()
        viewModel.getReviews()
    }
    
    private func setupRefreshControl() {
        reviewsView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state, insertedItems in
            DispatchQueue.main.async {
                self?.reviewsView.configure(with: state, insertedItems: insertedItems)
            }
        }
    }

}
