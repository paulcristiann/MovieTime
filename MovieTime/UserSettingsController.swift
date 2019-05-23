//
//  UserSettingsController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 17/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class UserSettingsController: UIViewController
{
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(tap)
        
		let userDefaults = UserDefaults.standard
		let userData = userDefaults.object(forKey: "userData") as! [String]
		let userName = userData[4]
        let email = userData[2]
		nameTextField.text = userName
        emailTextField.text = email
		nameTextField.isUserInteractionEnabled = false
	   
    }
    
    @objc func doubleTapped()
    {
        print("Incepe nebunia")
        
        let url = Bundle.main.url(forResource: "FLORIN SALAM - ZANA ZANELOR", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
            
        } catch let error as NSError {
            print(error.description)
        }
    }
    
	@IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var emailTextField: UILabel!
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        //delete user defaults
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "userData")
        
        //redirect to login screen
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
}
