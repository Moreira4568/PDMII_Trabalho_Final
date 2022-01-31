//
//  RootViewController.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 29/01/2022.
//
import UIKit
import Firebase
import Foundation

class RootViewController: UIViewController {

    static let identifier = "RootViewController"
    
    func isUserLoggedIn() -> Bool {
      return Auth.auth().currentUser != nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        


    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isUserLoggedIn() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let TabViewController = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
            TabViewController.modalPresentationStyle = .fullScreen
            self.present(TabViewController, animated: true, completion: nil)

        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let LoginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            LoginViewController.modalPresentationStyle = .fullScreen
            self.present(LoginViewController, animated: true, completion: nil)
        }
     }
}
    
