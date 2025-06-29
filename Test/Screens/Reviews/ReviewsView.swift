import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupRefreshControl()
        setupLoadingIndicator()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        loadingIndicator.center = center
    }
    
    func configure(with state: ReviewsViewModel.State, insertedItems: Bool) {
        if state.isFirstLoading && state.items.isEmpty {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false

            if insertedItems {
                let startIndex = max(0, tableView.numberOfRows(inSection: 0))
                let endIndex = state.items.count
                if endIndex > startIndex {
                    let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                }
            } else {
                tableView.reloadData()
            }

            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }

    
    private func setupRefreshControl() {
        tableView.refreshControl = refreshControl
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewCountCell.self, forCellReuseIdentifier: ReviewCountCellConfig.reuseId)
    }

    private func setupLoadingIndicator() {
        addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
    }

}
