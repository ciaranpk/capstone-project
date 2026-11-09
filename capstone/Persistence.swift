import Foundation

final class UserDefaultsFavoritesStore: FavoritesStore {
    private let key = "favorites.anime"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard

    func loadFavorites(completion: @escaping (Result<[Anime], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let data = self.userDefaults.data(forKey: self.key) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let favorites = try self.decoder.decode([Anime].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(favorites))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func saveFavorites(_ favorites: [Anime], completion: @escaping (Result<[Anime], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try self.encoder.encode(favorites)
                self.userDefaults.set(data, forKey: self.key)
                DispatchQueue.main.async {
                    completion(.success(favorites))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func toggleFavorite(_ anime: Anime, completion: @escaping (Result<[Anime], Error>) -> Void) {
        loadFavorites { result in
            switch result {
            case let .success(favorites):
                var updatedFavorites = favorites
                if let index = updatedFavorites.firstIndex(where: { $0.id == anime.id }) {
                    updatedFavorites.remove(at: index)
                } else {
                    updatedFavorites.append(anime)
                }
                self.saveFavorites(updatedFavorites, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func isFavorite(_ anime: Anime) -> Bool {
        guard let data = userDefaults.data(forKey: key),
              let favorites = try? decoder.decode([Anime].self, from: data) else {
            return false
        }
        return favorites.contains(where: { $0.id == anime.id })
    }
}
