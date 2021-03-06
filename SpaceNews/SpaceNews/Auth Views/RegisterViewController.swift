//
//  RegisterViewController.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 21/12/2021.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var db = Firestore.firestore()
    var radius = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Coloca cantos arredondados
        userTextField.layer.cornerRadius = CGFloat(radius)
        passwordTextField.layer.cornerRadius = CGFloat(radius)
        signInButton.layer.cornerRadius = CGFloat(radius)
        emailTextField.layer.cornerRadius = CGFloat(radius)
        
        //Muda a cor do placeholder
        userTextField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "muted")]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "muted")]
        )
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "muted")]
        )
        userTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: userTextField.frame.height))
        userTextField.leftViewMode = .always
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height:passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
          //Procura um ou mais toque
           let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
          view.addGestureRecognizer(tap)
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
            NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
          NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    //Corre fun????o quando existe um toque
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
    
    @IBAction func registerButton(_ sender: Any) {
        let password: String
        let email: String
        let username: String
        var validInputs = false
        
        // One or more characters followed by an "@",
        // then one or more characters followed by a ".",
        // and finishing with one or more characters
        let emailPattern = #"^\S+@\S+\.\S+$"#
        
        //No special characters
        //Only letters
        //Length should be 18 characters max and 7 characters minimum
        let usernamePattern = #"\A\w{7,18}\z"#
        
        // At least 8 characters
        let passwordPattern = #"(?=.{8,})"#

        
        password = passwordTextField.text!
        email = emailTextField.text!
        username = userTextField.text!
        
        
        let emailResult = email.range(
            of: emailPattern,
            options: .regularExpression
        )
        let validEmail = (emailResult != nil)
        
        let usernameResult = username.range(
            of: usernamePattern,
            options: .regularExpression
        )
        let validUsername = (usernameResult != nil)
        
        let passwordResult = password.range(
            of: passwordPattern,
            options: .regularExpression
        )
        let validPassword = (passwordResult != nil)
        
        
        if !validEmail || !validUsername || !validPassword  {
            if !validEmail {
                showAlert(title: "O email n??o ?? v??lido.", message: "Verifique o seu email antes de submeter o registo.")
            }
            if !validUsername {
                showAlert(title: "O username n??o ?? v??lido.", message: "?? necess??rio no m??nimo 7 caracteres.")
            }
            if !validPassword {
                showAlert(title: "A password n??o ?? v??lida.", message: "?? necess??rio no m??nimo 8 caracteres.")
            }
        }else {
            validInputs = true
        }
        
    
        
        if validInputs == true {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if (error?._code == nil) {
                    var ref: DocumentReference? = nil
                    var user = Auth.auth().currentUser
                    ref = self.db.collection("users").addDocument(data: [
                        "idUser": user?.uid,
                        "userName": username,
                        "email": email,
                        "cacheTime": 5
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                     
                    let refreshAlert = UIAlertController(title: "Conta criada com sucesso", message: "Ir?? ser reencaminhado para o login.", preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        print("entraa")
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let LoginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        LoginViewController.modalPresentationStyle = .fullScreen
                        self.present(LoginViewController, animated: true, completion: nil)
                    }))
                    self.present(refreshAlert, animated: true, completion: nil)
        
                }else {
                    switch AuthErrorCode(rawValue: error!._code) {
                    case .emailAlreadyInUse:
                        self.showAlert(title: "Este email j?? se encontra em uso.", message: "Verifique se inseriu o email correto.")
                    default:
                        self.showAlert(title: "Erro ao efetuar registo.", message: "Por favor tente mais tarde.")
                    }

                }
            }
            
        }
        
    }


}


