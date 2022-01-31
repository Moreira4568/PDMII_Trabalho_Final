import Foundation
import Firebase
import UserNotifications

class CacheController {
    let cache = NSCache<NSString, NSArray>()
    let cacheExpDate = NSCache<NSString, NSNumber>()
    let cacheTimeChosen = NSCache<NSString, NSNumber>()
    static let shared = CacheController()
    private var news = [News]()
    private var newsData = [News]()
    let center = UNUserNotificationCenter.current()
    
    func notification(body: String, title:String) {
        // Cria o conteudo da notificação
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Cria o trigger da aplicação
        let date = Date().addingTimeInterval(5)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Cria o pedido da notificação
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Regista a notificação
        self.center.add(request) { (error) in
            if error != nil {
                print("Erro de notificação", error)
            }
        }
        
    }

    // Função para guardar fetch da api na cache
    func setArticlesToCache(completion: @escaping (_ news: [News]) -> ()) {
        ApiService.getNewsData { [weak self] (result) in
            
            //Verifica o estado do fetch (sucesso ou falha)
            switch result {
            case .success(let data):
                self?.newsData = data
                
                //Decalara o firestore e guarda os dados do user logado
                let db = Firestore.firestore()
                let user = Auth.auth().currentUser
                
                 DispatchQueue.main.async {
                    
                    //Procura o user logado na base de dados e retorna o documento que lhe diz respeito
                    db.collection("users")
                        .whereField("idUser", isEqualTo: user?.uid as Any)
                        .getDocuments { (snapshot, error) in
                        for document in snapshot!.documents {
                            
                            //Guarda o tempo momentaneo
                            let currentDateTime = Date()
                            //Guarda o tempo de cache escolhido pelo utilizado (0 a 10 min)
                            let cachevalue = document.get("cacheTime") as! Int
                            
                            //Converte o tempo momentaneo em int
                            let timeIntervalCurrentDate = currentDateTime.timeIntervalSince1970
                            var currentDateInt = Int(timeIntervalCurrentDate)
                            
                            //Transforma o tempo de cache decidido pelo user em segundos
                            currentDateInt = currentDateInt + (cachevalue * 60)
                            
                            //Guarda na cache o tempo de cache escolhido pelo user, a data de expiração da cache e os dados do fetch, respetivamente.
                            self?.cacheTimeChosen.setObject(cachevalue as NSNumber, forKey: "cacheTimeChosen")
                            self?.cacheExpDate.setObject(currentDateInt as NSNumber, forKey: "ExpDate")
                            self?.cache.setObject(data as NSArray, forKey: "NewsCache")
                            
                            //Retorna o fetch de dados para as celulas
                            completion(self?.cache.object(forKey: "NewsCache") as! [News])
                            }
                        }
                 }
            case .failure(let error):
                print("Erro no fetch: \(error)")
            }
        }
    }
    
    //Metodo para receber as noticias da cache
    func getArticlesByCache(completion: @escaping (_ news: [News]) -> ()) {
        
        //Verifica se existe noticias em cache
        if ((self.cache.object(forKey: "NewsCache") == nil) || (self.cacheExpDate.object(forKey: "ExpDate") == nil)) {
            //Caso não existam é feito o fetch e guardado na cache
            self.setArticlesToCache { result in
                completion(result)
            }
            
        }
        
        //Caso existam artigos na cache
        else {
            
            //Decalara o firestore e guarda os dados do user logado
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            
            db.collection("users")
                .whereField("idUser", isEqualTo: user?.uid as Any)
                .getDocuments { (snapshot, error) in
                for document in snapshot!.documents {
                    
                    //Verifica se o tempo que foi guardado na cache ainda é o mesmo que o user tem nas suas definições
                    if document.get("cacheTime") as! Int == self.cacheTimeChosen.object(forKey: "cacheTimeChosen") as! Int {
                        
                        //Guarda o tempo momentaneo
                        let currentDateTime = Date()
                        //Converte o tempo momentaneo em int
                        let timeIntervalCurrentDate = currentDateTime.timeIntervalSince1970
                        let currentDateInt = Int(timeIntervalCurrentDate)
                        
                        //Verifica se a cache ainda continua válida
                        if (currentDateInt < self.cacheExpDate.object(forKey: "ExpDate") as! Int) {
                            print("A cache continua válida")
                            print(((self.cacheExpDate.object(forKey: "ExpDate") as! Int) - currentDateInt), "segundos restantes")
                        }
                        //Caso a cache já não se encontre válida
                        else {
                            print("A cache expirou")
                            
                            //Guarda os dados da cache expirada
                            let cachedArticles = self.cache.object(forKey: "NewsCache") as! [News]
                            
                            //Verifica se o artigo mais recente é igual ao da cache
                            //(Com isto só vale a pena atualizar a cache se for diferente.)
                            self.setArticlesToCache { result in
                                if result[0].id > cachedArticles[0].id {
                                    completion(result)
                                    
                                    //Envia uma notificação da notifica mais recente
                                    self.notification(body: result[0].summary, title: result[0].title)
                                }
                                //Caso a cache ainda se encontre atualiza
                                else {
                                    //Envia uma notificação da notifica mais recente
                                    //!APENAS PARA EFEITOS DE TESTE!
                                    self.notification(body: result[0].summary, title: result[0].title)
                                }
                            }
                        }
                    }
                    //Caso o utilizador tenha atualizado o tempo de cache nas definições
                    else {

                        //Guarda os dados da cache expirada
                        let cachedArticles = self.cache.object(forKey: "NewsCache") as! [News]
                        
                        //Verifica se o artigo mais recente é igual ao da cache
                        //(Com isto só vale a pena atualizar a cache se for diferente.)
                        self.setArticlesToCache { result in
                            if result[0].id > cachedArticles[0].id {
                                completion(result)
                                
                                //Envia uma notificação da notifica mais recente
                                self.notification(body: result[0].summary, title: result[0].title)
                            }
                            //Caso a cache ainda se encontre atualiza
                            else {
                                //Envia uma notificação da notifica mais recente
                                //!APENAS PARA EFEITOS DE TESTE!
                                self.notification(body: result[0].summary, title: result[0].title)
                            }
                        }
                    }
                }
            }
        }
    }
}

