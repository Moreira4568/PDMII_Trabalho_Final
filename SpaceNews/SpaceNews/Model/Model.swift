import Foundation


struct News: Codable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite, summary, publishedAt, updatedAt: String
    let featured: Bool
}

struct Comments: Codable {
    let idNotice: Int
    let userName: String
    let commentBody: String
    let commentDate: Date
}

