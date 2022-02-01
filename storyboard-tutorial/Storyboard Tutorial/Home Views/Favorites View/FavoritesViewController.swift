import UIKit
import SafariServices
import Firebase
import UserNotifications

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    static let identifier = "FavoritesViewController"
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var CellContainer: MainViewCell!
    @IBOutlet weak var FirstCellContainer: FirstViewCell!
    

    private var viewModel = FavoriteNewsViewModel()

    @IBOutlet weak var mainImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        super.viewWillDisappear(true)
        loadNewsDataCache()
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    @objc func refresh(_ sender: AnyObject) {
        loadNewsDataCache()
        refreshControl.endRefreshing()
    }
    
    private func loadNewsDataCache() {
        viewModel.fetchFavoriteNewsData { [weak self] in
            self?.tableView.dataSource = self
            self?.tableView.reloadData()
        }
    }
}

// MARK: - TableView
extension FavoritesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainViewCell
            let news = viewModel.cellForRowAt(indexPath: indexPath)
            cell.setCellWithValuesOf(news)
            return cell
        
        
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        
        vc.news = viewModel.cellForRowAt(indexPath: indexPath)
        
        navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }
    
}









