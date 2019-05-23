//
//  AddCommentController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 19/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import NaturalLanguage
import Alamofire

class AddCommentController: UIViewController
{
    
    var movie: Movie = Movie()
    
    @IBOutlet weak var textBox: UITextView!
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBAction func addCommentPressed(_ sender: Any) {
        
        guard !textBox.text!.isEmpty
            else {
                let alert = UIAlertController(title: "Posting error", message: "Comment can not be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
        }
        
        //send comment
        let comment = textBox.text
        
        let sentimentPredictor = try! NLModel(mlModel: CommentsClassifier().model)
        let prediction = sentimentPredictor.predictedLabel(for: comment!)
        
        //get user id
        let userDefaults = UserDefaults.standard
        let userData = userDefaults.object(forKey: "userData") as! [String]
        let userID = userData[0]
        var classification = 0
        
        if(prediction == "Negativ")
        {
            classification = 0
        }else
        {
            classification = 1
        }
        
        let endpoint2 = Endpoints.addComment
        Alamofire.request(endpoint2, method: .post, parameters: ["user": userID, "movie": movie._id, "comment": comment as Any, "cls": classification],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response.result.value as Any)
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textBox.layer.borderWidth = 1.0
        textBox.layer.borderColor = UIColor.lightGray.cgColor
        textBox.layer.cornerRadius = 10
        textBox.text = ""
        addCommentButton.layer.cornerRadius = 10
        
    }
}
