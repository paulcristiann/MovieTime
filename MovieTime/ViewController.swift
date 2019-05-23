//
//  ViewController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 16/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var userInputField: UITextField!
    
    @IBOutlet weak var passwordInputField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var loaded = false
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(loaded == false && ((UserDefaults.standard.object(forKey: "userData") as? [String]) != nil))
        {
            showLoadingAlert()
        }
    }
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 10
        
        if let userData = UserDefaults.standard.object(forKey: "userData") as? [String] {
            
            //bypass this screen and login again
            let endpoint = Endpoints.login
            let username = userData[2]
            let password = userData[3]
            Alamofire.request(endpoint, method: .post, parameters: ["email": username, "password": password ],encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result {
                case .success:
                    self.tryLogin(response: response)
                    break
                case .failure(let error):
                    let alert = UIAlertController(title: "Authentification error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    print(error)
                }
            }
            
        }
        passwordInputField.isSecureTextEntry = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        guard !userInputField.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Authentification error", message: "Username can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        guard !passwordInputField.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Authentification error", message: "Password can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        let endpoint = Endpoints.login
        
        Alamofire.request(endpoint, method: .post, parameters: ["email": userInputField.text!, "password": passwordInputField.text!],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {

            case .success:
                self.tryLogin(response: response)
                break
            case .failure(let error):
                self.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Authentification error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            
            }
        }
        
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "registerView") as! RegisterViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    private func tryLogin(response: DataResponse<Any>)
    {
        let parsedJson = response.result.value as! NSDictionary
        
        let authStatus = parsedJson["status"] as! String
        
        print(authStatus)
        
        if(authStatus == "success")
        {
            let userData = parsedJson["data"] as! NSDictionary
            let session_token = userData["sessionToken"] as! String
            let user_id = userData["_id"] as! String
            let user_name = userData["name"] as! String
            print(session_token)
            print(user_id)
            
            //Store data in USER DEFAULTS but check first
            let userDefaults = UserDefaults.standard
            if var userData = UserDefaults.standard.object(forKey: "userData") as? [String]
            {
                userData[0] = user_id
                userData[1] = session_token
                userDefaults.set(userData, forKey: "userData")
            }
            else{
                let userDataArray = [user_id, session_token, userInputField.text!, passwordInputField.text!, user_name]
                userDefaults.set(userDataArray, forKey: "userData")
            }
            
            userInputField.text = ""
            passwordInputField.text = ""
            
            if(loaded == false)
            {
                dismiss(animated: true, completion: nil)
                loaded = true
            }else{
                dismiss(animated: true, completion: nil)
            }
            
            if let tabViewController = storyboard!.instantiateViewController(withIdentifier: "homeScreen") as? UITabBarController {
                present(tabViewController, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Authentification error", message: "Wrong credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func showLoadingAlert()
    {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
}
