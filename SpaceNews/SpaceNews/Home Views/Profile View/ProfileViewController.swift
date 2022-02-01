import Foundation
import UIKit
import Firebase

class ProfileViewController: UIViewController{
    private var db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    var radius = 10
    var myUserName: String = ""
    var id: String = ""
    var email: String = ""
    
    @IBOutlet weak var cacheTimeAmount: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    static let identifier = "ProfileViewController"

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        cacheTimeAmount.text = Int(sender.value).description
        
        self.db.collection("users")
            .whereField("idUser",  isEqualTo: user?.uid as Any)
            .getDocuments { (snapshot, error) in
            if let snapshot = snapshot?.documents {
                for doc in snapshot {
                    self.db.collection("users").document(doc.documentID).updateData([
                        "cacheTime": sender.value
                    ])
                }
            }
        }
        

    }
    
    func getMyData() {
        self.db.collection("users")
            .whereField("idUser", isEqualTo: user?.uid as Any)
            .getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                self.myUserName = String(describing: document.get("userName") ?? "")
                self.id = self.user?.uid ?? ""
                self.email = self.user?.email ?? ""
                self.stepper.value = document.get("cacheTime") as! Double
                self.cacheTimeAmount.text = String(describing: document.get("cacheTime") ?? "")
                self.emailLabel.text = self.email
                self.userNameLabel.text = self.myUserName
                }
            }
    }
    
    @IBAction func buttonTest(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Queres Terminar Sessão?", message: "Ao escolher sim irá sair da sua conta.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .destructive, handler: { (action: UIAlertAction!) in
            self.logoutUser()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let LoginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            LoginViewController.modalPresentationStyle = .fullScreen
            self.present(LoginViewController, animated: true, completion: nil)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        present(refreshAlert, animated: true, completion: nil)
    }

    func logoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         stepper.wraps = true
         stepper.autorepeat = true
         stepper.maximumValue = 10
         logOutButton.layer.cornerRadius = CGFloat(radius)
         getMyData()
        }


}
