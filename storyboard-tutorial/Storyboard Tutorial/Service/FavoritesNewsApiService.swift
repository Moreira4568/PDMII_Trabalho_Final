//
//  FavoritesNewsApiService.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 01/02/2022.
//


import Foundation
import Firebase

class FavoritesNewsApiService {
    
    static var dataTask: URLSessionDataTask?
    static var favoriteNews: [News] = []
    
    static func getFavoritesNewsData(completion: @escaping (Result<[News], Error>) -> Void) {
        
        //Decalara o firestore e guarda os dados do user logado
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        favoriteNews = []
        
        db.collection("likes")
            .whereField("idUser", isEqualTo: user?.uid)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshot = querySnapshot?.documents {
                    for doc in snapshot {
                        let favoriteNewsUrl = "https://api.spaceflightnewsapi.net/v3/articles/\(String(describing: doc.get("idNotice") ?? ""))"
                        
                        guard let url = URL(string: favoriteNewsUrl) else {return}
                        
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
                  
                            
                            if response.statusCode == 200 {
                                print("Favorite article \(String(describing: doc.get("idNotice") ?? "")) fetched with success")
                            } else {
                                print("Response status code: \(response.statusCode)")
                            }
                            
                            guard let data = data else {
                                // Handle Empty Data
                                print("Empty Data")
                                return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                
                                let jsonData = try decoder.decode(News.self, from: data)
                                
                                favoriteNews.append(jsonData)
                            
                                DispatchQueue.main.async {
                                    completion(.success(favoriteNews))
                                }
                            } catch let error {
                                print(error)
                      
                            
                            }
                            
                        }
                        dataTask?.resume()
                        
                    }
                }

            }
        }
    }
}

