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
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newsSource: UIButton!
    @IBOutlet weak var likeButtonElement: UIButton!
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
    @IBOutlet weak var commentMyName: UILabel!
    static let identifier = "DetailViewController"
    private var db = Firestore.firestore()
    var stringArr = [Comments]()
    var news: News?
    var radius = 10
    let user = Auth.auth().currentUser
    var myUserName: String = ""
    var id: String = ""
    var email: String = ""
    var image: UIImage!
    
    @IBAction func likeButton(_ sender: Any) {
        makeLike()
        print("New like")
    }
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
    
    func getMyData() {
        self.db.collection("users")
            .whereField("idUser", isEqualTo: user?.uid as Any)
            .getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                self.myUserName = String(describing: document.get("userName") ?? "")
                self.id = self.user?.uid ?? ""
                self.email = self.user?.email ?? ""
                
                self.commentMyName.text = self.myUserName
                self.verifyLike()
                self.getComments()
                }
            }
    }
    
    @IBAction func shareInstagram(_ sender: Any) {
        guard let image = self.image, let url = URL(string: news?.url ?? "") else {
            return
        }
        let shareSheetvc = UIActivityViewController(
            activityItems: [image,url],
            applicationActivities: nil
        )
        shareSheetvc.excludedActivityTypes = [.mail]
        
        present(shareSheetvc, animated: true)
    }
    
    func verifyLike(){
        db.collection("likes")
            .whereField("idUser", isEqualTo: self.user?.uid)
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
    
    func makeLike() {
        db.collection("likes")
            .whereField("idUser", isEqualTo: user?.uid as Any)
            .whereField("idNotice", isEqualTo: news?.id)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count < 1 {
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("likes").addDocument(data: [
                        "idNotice": self.news?.id,
                        "idUser": self.user?.uid,
                    ])
                    print("like")
                    self.verifyLike()
                } else {
                    self.db.collection("likes")
                        .whereField("idUser", isEqualTo: self.user?.uid as Any)
                        .whereField("idNotice", isEqualTo: self.news?.id)
                        .getDocuments { (snapshot, error) in
                        if let snapshot = snapshot?.documents {
                            for doc in snapshot {
                                self.db.collection("likes").document(doc.documentID).delete()
                                self.verifyLike()
                            }
                        }
                    }

               
                    
                }
            }
        }
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)

        present(alertController, animated: true)
    }
    
    func newComment(){
        if inputComments.text != "" {
            var ref: DocumentReference? = nil
            ref = db.collection("comments").addDocument(data: [
                "idNotice": news?.id,
                "userName": self.myUserName,
                "commentBody": inputComments.text,
                "commentDate": Date()
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }

                self.stringArr.insert(Comments(
                                        idNotice: news?.id ?? 0,
                                        userName: self.myUserName,
                                        commentBody: String(describing: inputComments.text ?? ""),
                    commentDate: (Date() as? Timestamp)?.dateValue() ?? Date()
                )
                                      , at: 0)
                inputComments.text = ""
               
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                self.tableView.endUpdates()
                self.commentsCount.text = String(self.stringArr.count)
        }else {
            showAlert(title: "Comentário vazio", message: "Por favor insira um comentário antes de publicar.")
        }

    }
    
    func getComments(){
        db.collection("comments").whereField("idNotice", isEqualTo: news?.id as Any).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.stringArr.insert(Comments(
                                            idNotice: self.news?.id ?? 0,
                                            userName: String(describing: document.get("userName") ?? ""),
                                            commentBody: String(describing: document.get("commentBody") ?? ""),
                        commentDate: (document.get("CommentDate") as? Timestamp)?.dateValue() ?? Date()
                    )
                                          , at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                    self.tableView.endUpdates()
                    self.commentsCount.text = String(self.stringArr.count)
                }
            }
        }
        
        
    }
    
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
                    self.image = image
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
    
    @IBAction func newsSourceRedirect(_ sender: Any) {
        let safariVC = SFSafariViewController(url: NSURL(string: self.news?.url ?? "")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyData()
        Image.layer.cornerRadius = CGFloat(radius)
        inputComments.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

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
}



extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else {return UITableViewCell()}
        cell.commentBody.text = stringArr[indexPath.row].commentBody
        cell.commentUserName.text = stringArr[indexPath.row].userName
        
        var formatter = DateFormatter()
        formatter.locale = .init(identifier: "pt_POSIX")
        formatter.dateFormat = "EEEE, MMM d"
        var formatteddate = formatter.string(from: stringArr[indexPath.row].commentDate)
        
        cell.commentDate.text = formatteddate

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
