import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    var radius = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.layer.cornerRadius = CGFloat(radius)
        passwordTextField.layer.cornerRadius = CGFloat(radius)
        signInButton.layer.cornerRadius = CGFloat(radius)
        
        
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "muted")]
        )
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "muted")]
        )
        
        
          //Procura um ou mais toque
           let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

          view.addGestureRecognizer(tap)
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
          NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    //Corre função quando existe um toque
    @objc func dismissKeyboard() {
        //Esconde o teclado
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)

        present(alertController, animated: true)
    }
    
    
    func signIn() {
        
        let password: String
        let email: String
        var validInputs = false
        
        // One or more characters followed by an "@",
        // then one or more characters followed by a ".",
        // and finishing with one or more characters
        let emailPattern = #"^\S+@\S+\.\S+$"#
        
        // At least 8 characters
        let passwordPattern = #"(?=.{8,})"#

        
        password = passwordTextField.text!
        email = emailTextField.text!
        
        
        let emailResult = email.range(
            of: emailPattern,
            options: .regularExpression
        )
        let validEmail = (emailResult != nil)
        
        let passwordResult = password.range(
            of: passwordPattern,
            options: .regularExpression
        )
        let validPassword = (passwordResult != nil)
        
        
        if !validEmail || !validPassword  {
            if !validEmail {
                showAlert(title: "O email não é válido.", message: "Verifique o seu email antes de submeter.")
            }
            if !validPassword {
                showAlert(title: "A password não é válida.", message: "É necessário no mínimo 8 caracteres.")
            }
        }else {
            validInputs = true
        }
        
        if validInputs == true {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if (error?._code == nil) {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let TabViewController = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                    TabViewController.modalPresentationStyle = .fullScreen
                    self.present(TabViewController, animated: true, completion: nil)
                    
                }else {
                    switch AuthErrorCode(rawValue: error!._code) {
                    case .emailAlreadyInUse:
                        self.showAlert(title: "Este email já se encontra em uso.", message: "Verifique se inseriu o email correto.")
                    default:
                        self.showAlert(title: "Falha no Login.", message: "Verifique as suas credenciais ou a sua conexão à internet.")
                    }

                }
            }
            
        }
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        signIn()
    }


}

