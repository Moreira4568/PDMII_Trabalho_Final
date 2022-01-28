//
//  DetailViewController.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 24/01/2022.
//

import Foundation
import UIKit
import Firebase
import SafariServices

class DetailViewController: UIViewController, SFSafariViewControllerDelegate{
    
    @IBOutlet weak var newsSource: UIButton!
    @IBOutlet weak var likeButtonElement: UIButton!
    @IBAction func likeButton(_ sender: Any) {
        makeLink()
        print("New like")
    }
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsBody: UILabel!
    @IBOutlet weak var submitCommentBTN: UIButton!
    @IBOutlet weak var inputComments: UITextField!
    @IBOutlet weak var newsDetails: UILabel!
    @IBOutlet weak var imageDate: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    static let identifier = "DetailViewController"
    private var db = Firestore.firestore()
    var stringArr = [Comments]()
    
    var news: News?
    @IBAction func btnSubmitComment(_ sender: Any) {
    newComment()
    }
    
    @IBAction func qrCodeButton(_ sender: Any) {

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "QrCodeViewController") as? QrCodeViewController else {
            return
        }
        vc.imageUrl = news?.url ?? ""
        show(vc, sender: true)
    }
    
    func verifyLike(){
        db.collection("likes")
            .whereField("idUser", isEqualTo: 12334)
            .whereField("idNotice", isEqualTo: news?.id)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print(querySnapshot!.documents.count)
                if querySnapshot!.documents.count == 1 {
                    var iconImage:UIImage? = UIImage(systemName: "hand.thumbsup.fill")
                    self.likeButtonElement.setBackgroundImage(iconImage, for: UIControl.State.normal)
                } else {
                    var iconImage:UIImage? = UIImage(systemName: "hand.thumbsup")
                    self.likeButtonElement.setBackgroundImage(iconImage, for: UIControl.State.normal)
                }
            }
        }
        db.collection("likes").whereField("idNotice", isEqualTo: news?.id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.likesCount.text = String(querySnapshot!.documents.count)
            }
        }
        
    }
    
    func makeLink() {
        db.collection("likes")
            .whereField("idUser", isEqualTo: 12334)
            .whereField("idNotice", isEqualTo: news?.id)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count < 1 {
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("likes").addDocument(data: [
                        "idNotice": self.news?.id,
                        "idUser": 12334,
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                    print("like")
                    self.verifyLike()
                } else {
                    self.db.collection("likes")
                        .whereField("idUser", isEqualTo: 12334)
                        .whereField("idNotice", isEqualTo: self.news?.id)
                        .getDocuments { (snapshot, error) in
                        if let snapshot = snapshot?.documents {
                            for doc in snapshot {
                                //Do delete
                                self.db.collection("likes").document(doc.documentID).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed!")
                                        self.verifyLike()
                                    }
                                }
                            }
                        }
                    }

               
                    
                }
            }
        }
    }
    
    func newComment(){
    var ref: DocumentReference? = nil

    ref = db.collection("comments").addDocument(data: [
        "idNotice": news?.id,
        "userName": "Carlos Moreira",
        "commentBody": inputComments.text,
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }

        self.stringArr.insert(Comments(
                                idNotice: news?.id ?? 0,
                                userName: "Carlos Moreira",
                                commentBody: String(describing: inputComments.text ?? ""))
                              , at: 0)
        inputComments.text = ""
       
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
        self.tableView.endUpdates()
        self.commentsCount.text = String(self.stringArr.count)
    }
    
    func getComments(){
        db.collection("comments").whereField("idNotice", isEqualTo: news?.id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.stringArr.insert(Comments(
                                            idNotice: self.news?.id ?? 0,
                                            userName: String(describing: document.get("userName") ?? ""),
                                            commentBody: String(describing: document.get("commentBody") ?? ""))
                                          , at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                    self.tableView.endUpdates()
                    self.commentsCount.text = String(self.stringArr.count)
                }
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        verifyLike()
        getComments()
        // MARK: - Get image data
        func getImageDataFrom(url: URL) {
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
                        self.Image.image = image
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
        self.imageDate.text = convertDateFormater(news?.publishedAt)
        self.titleLabel?.text = news?.title
        self.newsDetails?.text = news?.summary
        self.newsSource?.setTitle(news?.newsSite, for: .normal)
        
        
        // Before we download the image we clear out the old one
        self.Image.image = nil
        
        guard let posterImageURL = URL(string: news!.imageUrl) else {
            self.Image.image = UIImage(named: "noImageAvailable")
            return
        }
        getImageDataFrom(url: posterImageURL)
    }
    
    @IBAction func newsSourceRedirect(_ sender: Any) {
        let safariVC = SFSafariViewController(url: NSURL(string: self.news?.url ?? "")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
}



extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
        

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else {return UITableViewCell()}
        
        cell.commentBody.text = stringArr[indexPath.row].commentBody
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }


}
