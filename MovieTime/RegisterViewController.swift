//
//  RegisterViewController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 16/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        registerButton.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        
        guard !userField.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Registration error", message: "Username can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        guard !emailField.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Registration error", message: "Email can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        guard !passwordField.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Registration error", message: "Password can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        let endpoint = Endpoints.register
        
        Alamofire.request(endpoint, method: .post, parameters: ["email": emailField.text!, "password": passwordField.text!, "name": userField.text!],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                self.tryLogin(response: response)
                break
            case .failure(let error):
                let alert = UIAlertController(title: "Registration error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
        
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
                let userDataArray = [user_id, session_token, emailField.text!, passwordField.text!, userField.text!]
                userDefaults.set(userDataArray, forKey: "userData")
            }
            
            //present movie recommendations
            let pc = self.storyboard?.instantiateViewController(withIdentifier: "preferencesView") as! PreferencesController
            self.present(pc, animated: true, completion: nil)
            
        }
        else
        {
            let alert = UIAlertController(title: "Registration error", message: "The server rejected given credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}
