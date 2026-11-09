import Foundation

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTopAnime(page: Int, completion: @escaping (Result<[Anime], APIError>) -> Void) {
        guard let url = Endpoint.topAnime(page: page).url else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            // Handle error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            // Validate response and data
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let topResponse = try decoder.decode(TopAnimeResponse.self, from: data)
                let animeList = topResponse.data.map { $0.toAnime() }
                DispatchQueue.main.async {
                    completion(.success(animeList))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        task.resume()
    }
}
