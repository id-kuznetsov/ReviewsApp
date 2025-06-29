import UIKit

// MARK: - Config

struct ReviewCountCellConfig {
    static let reuseId = String(describing: ReviewCountCellConfig.self)
    
    let reviewCountText: NSAttributedString
    fileprivate let layout = ReviewCountCellLayout()
}

extension ReviewCountCellConfig: TableCellConfig {
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.countLabel.attributedText = reviewCountText
        cell.config = self
    }
    
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Cell

final class ReviewCountCell: UITableViewCell {
    
    fileprivate var config: ReviewCountCellConfig?
    fileprivate let countLabel = UILabel()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(countLabel)
        countLabel.numberOfLines = 0
        countLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        countLabel.frame = layout.labelFrame(for: bounds.size)
    }
}

// MARK: - Layout

private final class ReviewCountCellLayout {
    
    // MARK: - Отступы
    private let horizontalInset: CGFloat = 16.0
    private let verticalInset: CGFloat = 12.0
    
    func labelFrame(for size: CGSize) -> CGRect {
        CGRect(
            x: horizontalInset,
            y: verticalInset,
            width: size.width - 2 * horizontalInset,
            height: size.height - 2 * verticalInset
        )
    }
    
    func height(config: ReviewCountCellConfig, maxWidth: CGFloat) -> CGFloat {
        let labelWidth = maxWidth - 2 * horizontalInset
        let textHeight = config.reviewCountText.boundingRect(width: labelWidth).height
        return textHeight + 2 * verticalInset
    }
}
