import Foundation

enum APIError: Error, CustomStringConvertible {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case emptyData
    case unknown
    
    var description: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .network(let error):
            return "A network error occurred: \(error.localizedDescription)"
        case .decoding(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .emptyData:
            return "The data was empty."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

struct Anime: Codable, Equatable, Identifiable {
    let id: Int
    let title: String
    let synopsis: String?
    let imageURL: URL?
    let score: Double?
    let episodes: Int?
}

protocol FavoritesStore {
    func loadFavorites(completion: @escaping (Result<[Anime], Error>) -> Void)
    func saveFavorites(_ favorites: [Anime], completion: @escaping (Result<Void, Error>) -> Void)
}

struct Endpoint {
    let baseURL: URL
    let path: String
    let queryItems: [URLQueryItem]
    
    var url: URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
    
    static func topAnime(page: Int) -> Endpoint {
        let base = URL(string: "https://api.jikan.moe/v4")!
        return Endpoint(baseURL: base,
                        path: "/top/anime",
                        queryItems: [URLQueryItem(name: "page", value: "\(page)")])
    }
}

struct TopAnimeResponse: Codable {
    let data: [AnimeDTO]
}

struct AnimeDTO: Codable {
    let mal_id: Int
    let title: String
    let synopsis: String?
    let images: ImagesDTO
    let score: Double?
    let episodes: Int?
    
    func toModel() -> Anime {
        Anime(
            id: mal_id,
            title: title,
            synopsis: synopsis,
            imageURL: URL(string: images.jpg.image_url),
            score: score,
            episodes: episodes
        )
    }
    
    struct ImagesDTO: Codable {
        let jpg: JPGDTO
        
        struct JPGDTO: Codable {
            let image_url: String
        }
    }
}
