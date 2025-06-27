/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// avatar
    let avatarURL: String?
    /// rating
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String

}
