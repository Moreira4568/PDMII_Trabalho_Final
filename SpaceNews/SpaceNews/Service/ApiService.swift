import Foundation

class ApiService {
    
    static var dataTask: URLSessionDataTask?
    
    static func getNewsData(completion: @escaping (Result<[News], Error>) -> Void) {
        
        let newsURL = "https://api.spaceflightnewsapi.net/v3/articles"
        
        guard let url = URL(string: newsURL) else {return}
        
        // Create URL Session - work on the background
        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Handle Error
            if let error = error {
                completion(.failure(error))
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                // Handle Empty Response
                print("Empty Response")
                return
            }
            print("Response status code: \(response.statusCode)")
            
            guard let data = data else {
                // Handle Empty Data
                print("Empty Data")
                return
            }
            
            do {
                // Parse the data
                let decoder = JSONDecoder()
                
                let jsonData = try decoder.decode([News].self, from: data)
                
            
                // Back to the main thread
                DispatchQueue.main.async {
                    completion(.success(jsonData))
                    // print(String.init(data: data, encoding: .ascii) ?? "No data")
                }
            } catch let error {
                print(error)
      
            
            }
            
        }
        dataTask?.resume()
    }
}
