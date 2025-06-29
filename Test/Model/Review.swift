/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// Аватар
    let avatarUrl: String?
    /// Рейтинг
    let rating: Int
    /// Фото в отзыве
    let photos: [String]?
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String

}
