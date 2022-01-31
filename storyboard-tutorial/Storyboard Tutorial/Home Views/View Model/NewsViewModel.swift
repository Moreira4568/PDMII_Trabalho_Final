import Foundation

class NewsViewModel {
    
    private var apiService = ApiService()
    private var cacheStore = CacheController()
    private var newsData = [News]()
    
    func fetchNewsData(completion: @escaping () -> ()) {
        
        // weak self - prevent retain cycles
        cacheStore.getArticlesByCache { [weak self] (result) in
            


       // ApiService.getNewsData { [weak self] (result) in
       /*      switch result {
            case .success(let data):
                self?.newsData = data
                completion()
            case .failure(let error):
                // Something is wrong with the JSON file or the model
                print("Error processing json data: \(error)")
            }
 */
        self?.newsData = result
            print("Dados Atualizados")
            completion()
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
