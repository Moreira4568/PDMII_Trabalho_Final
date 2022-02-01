//
//  FirstViewCell.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 27/12/2021.
//

import UIKit

class FirstViewCell: UITableViewCell {
    
    var radius = 10
    
    
    @IBOutlet weak var FirstNewsImage: UIImageView!
    
    
    @IBOutlet weak var FirstNewsTitle: UILabel!
    
    @IBOutlet weak var FirstNewsDate: UILabel!
    private var urlString: String = ""
    
    // Setup movies values
    func setCellWithValuesOf(_ news: News) {
        updateUI(title: news.title, imageUrl: news.imageUrl, summary: news.summary,
            date: news.publishedAt)
    }
    
    // Update the UI Views
    private func updateUI(title: String?, imageUrl: String?, summary: String?, date: String?) {
        
        self.FirstNewsTitle.text = title

        self.FirstNewsDate.text = UtilsFuncs.convertDateFormater(date)
        
        FirstNewsImage.layer.cornerRadius = CGFloat(radius)
        
        guard let posterImageURL = URL(string: imageUrl!) else {
            self.FirstNewsImage.image = UIImage(named: "noImageAvailable")
            return
        }
        
        // Before we download the image we clear out the old one
        // self.FirstNewsImage.image = nil
        
        getImageDataFrom(url: posterImageURL)

    }
        
    // MARK: - Get image data
    private func getImageDataFrom(url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Handle Error
            if let error = error {
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                // Handle Empty Data
                print("Empty Data")
                return
            }
            DispatchQueue.main.async {
                
                if let image = UIImage(data: data) {
                    self.FirstNewsImage.image = image
                }
                
            }
            
        }.resume()
    }
    

    
}
