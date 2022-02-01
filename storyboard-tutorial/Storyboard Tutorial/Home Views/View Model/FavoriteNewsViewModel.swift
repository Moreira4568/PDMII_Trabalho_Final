import Foundation

class FavoriteNewsViewModel {
    
    private var newsData = [News]()
    
    
    func fetchFavoriteNewsData(completion: @escaping () -> ()) {

        FavoritesNewsApiService.getFavoritesNewsData { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.newsData = data
                completion()
            case .failure(let error):
                print("Error processing json data: \(error)")
            }

    }
        
}
    
    func numberOfRowsInSection(section: Int) -> Int {
        if newsData.count != 0 {
            return newsData.count
        }
        return 0
    }
    
    func cellForRowAt (indexPath: IndexPath) -> News {
       
        return newsData[indexPath.row]
    }
}
