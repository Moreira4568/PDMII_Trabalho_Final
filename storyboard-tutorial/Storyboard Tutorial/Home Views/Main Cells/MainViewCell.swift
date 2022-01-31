//
//  MainViewCell.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 25/12/2021.

import UIKit

class MainViewCell: UITableViewCell {

    @IBOutlet weak var NewsImage: UIImageView!
    @IBOutlet weak var NewsTitle: UILabel!
    @IBOutlet weak var NewsDesc: UILabel!
    @IBOutlet weak var NewsDate: UILabel!
    
    var radius = 10

    
    
    private var urlString: String = ""
    
    // Setup movies values
    func setCellWithValuesOf(_ news: News) {
        updateUI(title: news.title, imageUrl: news.imageUrl, summary: news.summary,
            date: news.publishedAt)
    }
    
    // Update the UI Views
    private func updateUI(title: String?, imageUrl: String?, summary: String?, date: String?) {
        
        self.NewsTitle.text = title
        self.NewsDesc.text = summary
        self.NewsDate.text = convertDateFormater(date)
        
        NewsImage.layer.cornerRadius = CGFloat(radius)

        
        guard let posterImageURL = URL(string: imageUrl!) else {
            self.NewsImage.image = UIImage(named: "noImageAvailable")
            return
        }
        
        // Before we download the image we clear out the old one
        self.NewsImage.image = nil
 
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
                    self.NewsImage.image = image
                }
            }
        }.resume()
    }
    
    // MARK: - Convert date format
    func convertDateFormater(_ date: String?) -> String {
        var fixDate = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "pt_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let originalDate = date {
            if let newDate = dateFormatter.date(from: originalDate) {
                
                dateFormatter.dateFormat = "EEEE, MMM d"
                
                fixDate = dateFormatter.string(from: newDate)
            }
        }
        return fixDate
    }
}
