import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Полное имя.
    let authorFullName: NSAttributedString
    /// Аватар
    let avatarURL: URL?
    /// Рейтинг.
    let ratingImage: UIImage
    /// Изображения в отзывах
    let photoURLs: [URL]?
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Провайдер изображений (для асинхронной загрузки и кэширования)
    let imageProvider: ImageProviderProtocol

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.update(with: self)
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let avatarView = UIImageView()
    fileprivate let authorNameLabel = UILabel()
    fileprivate let ratingView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    private let photosCollectionView = ReviewPhotosCollectionView()
    
    private var imageProvider: ImageProviderProtocol?
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorNameLabel.attributedText = nil
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
        avatarView.image = UIImage(named: "EmptyAvatar")
        imageProvider = nil
    }

    func setPhotos(_ urls: [URL]?) {
        photosCollectionView.setPhotos(urls ?? [], imageProvider: imageProvider)
    }
    
    func update(with config: ReviewCellConfig) {
        self.config = config
        self.imageProvider = config.imageProvider
        
        authorNameLabel.attributedText = config.authorFullName
        ratingView.image = config.ratingImage
        reviewTextLabel.attributedText = config.reviewText
        reviewTextLabel.numberOfLines = config.maxLines
        createdLabel.attributedText = config.created
        setPhotos(config.photoURLs)
        
        if let avatarURL = config.avatarURL {
            avatarView.setImage(from: avatarURL, placeholder: UIImage(named: "EmptyAvatar"), using: config.imageProvider)
        } else {
            avatarView.image = UIImage(named: "EmptyAvatar")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarView.frame = layout.avatarFrame
        authorNameLabel.frame = layout.authorFullNameLabelFrame
        ratingView.frame = layout.ratingFrame
        if layout.photosFrame != .zero {
            photosCollectionView.frame = layout.photosFrame
        }
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAvatarView()
        setupAuthorNameLabel()
        setupRatingView()
        setupCollectionView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }

    func setupAvatarView() {
        contentView.addSubview(avatarView)
        avatarView.contentMode = .scaleAspectFit
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = Layout.avatarCornerRadius
    }
    
    func setupAuthorNameLabel() {
        contentView.addSubview(authorNameLabel)
        authorNameLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupRatingView() {
        contentView.addSubview(ratingView)
    }
    
    func setupCollectionView() {
        contentView.addSubview(photosCollectionView)
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(didTapShowMoreButton), for: .touchUpInside)
    }
    
    @objc func didTapShowMoreButton() {
        guard let config else { return }
        config.onTapShowMore(config.id)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var avatarFrame = CGRect.zero
    private(set) var authorFullNameLabelFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var photosFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {

        let width = maxWidth - insets.left - insets.right

        var maxY = insets.top
        var showShowMoreButton = false
        
        avatarFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )
        
        let maxX = avatarFrame.maxX + avatarToUsernameSpacing

        authorFullNameLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.authorFullName.boundingRect(width: width).size
        )
        maxY = authorFullNameLabelFrame.maxY + usernameToRatingSpacing
        
        ratingFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.ratingImage.size
        )
        maxY = ratingFrame.maxY + ratingToTextSpacing
        
        if let urls = config.photoURLs, !urls.isEmpty {
            photosFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY + ratingToPhotosSpacing),
                size: CGSize(width: min(CGFloat(urls.count) * (Self.photoSize.width + photosSpacing) - photosSpacing,
                                       width - (maxX - insets.left)),
                             height: Self.photoSize.height)
            )
            maxY = photosFrame.maxY + photosToTextSpacing
        } else {
            photosFrame = .zero
        }
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            let reviewWidth = width - maxX - insets.right
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: config.reviewText.boundingRect(width: reviewWidth, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
