//
//  MainViewController.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 25/12/2021.
//

import UIKit
import SafariServices
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var CellContainer: MainViewCell!
    @IBOutlet weak var FirstCellContainer: FirstViewCell!
    

    private var viewModel = NewsViewModel()

    @IBOutlet weak var mainImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        super.viewWillDisappear(true)
        loadNewsData()
        view.addSubview(tableView)
                tableView.delegate = self
                tableView.dataSource = self
        
        
    }
    
    private func loadNewsData() {
        viewModel.fetchNewsData { [weak self] in
            self?.tableView.dataSource = self
            self?.tableView.reloadData()
        }
    }
}

// MARK: - TableView
extension MainViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "primary_cell") as! FirstViewCell
            let news = viewModel.cellForRowAt(indexPath: indexPath)
            cell.setCellWithValuesOf(news)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainViewCell
            let news = viewModel.cellForRowAt(indexPath: indexPath)
            
            cell.setCellWithValuesOf(news)
            return cell
        }
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








