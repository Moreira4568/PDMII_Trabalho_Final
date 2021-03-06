import Foundation

class NewsViewModel {
    
    private var apiService = ApiService()
    private var cacheStore = CacheController()
    private var newsData = [News]()
    
    func fetchNewsDataWithCache(completion: @escaping () -> ()) {

        cacheStore.getArticlesByCache { [weak self] (result) in
        self?.newsData = result
            print("Dados Atualizados")
            completion()
        }
    }
    
    func fetchNewsData(completion: @escaping () -> ()) {

    ApiService.getNewsData { [weak self] (result) in
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
