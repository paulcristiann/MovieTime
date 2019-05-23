//
//  MovieDetails.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 19/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Alamofire
import SafariServices

class MovieDetails: UIViewController, SFSafariViewControllerDelegate
{
    
    @IBOutlet weak var movieTitle: UILabel!
    
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var ratingStars: CosmosView!
    
    @IBOutlet weak var commentsVerdict: UILabel!
    
    @IBOutlet weak var viewComments: UIButton!
    
    var movie: Movie = Movie()
    var poster: UIImage = UIImage()
    var Comments: [Comment] = []
    var CommentsLoaded = false
    var RatingLoaded = false
    
    override func viewDidLoad() {
        
        viewComments.layer.cornerRadius = 10
        
        //get user id
        let userDefaults = UserDefaults.standard
        let userData = userDefaults.object(forKey: "userData") as! [String]
        let userID = userData[0]
        var fetchedValue = 0
        
        let endpoint = Endpoints.getRating
        //get rating from DB
        Alamofire.request(endpoint, method: .post, parameters: ["user": userID, "movie":  self.movie._id],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                self.RatingLoaded = true
                if(self.CommentsLoaded && self.RatingLoaded)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                let jsonResponse = response.result.value as! NSDictionary
                let status = jsonResponse["status"] as! String
                if(status != "error")
                {
                    let data = jsonResponse["data"] as! NSDictionary
                    fetchedValue = data["rate"] as! Int
                    print(fetchedValue)
                    self.ratingStars.rating = Double(fetchedValue)
                }
                break
            case .failure(let error):
                let alert = UIAlertController(title: "Server error", message: "The rating could not be fetched. Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.RatingLoaded = true
                print(error)
                print(response)
            }
        }
        
        super.viewDidLoad()
        
        movieTitle.text = movie.title
        genreLabel.text = movie.genres
        movieImage.image = poster
        
        ratingStars.didFinishTouchingCosmos =
            {
                rating in
                
                let endpoint = Endpoints.rate
                
                //get user id
                let userDefaults = UserDefaults.standard
                let userData = userDefaults.object(forKey: "userData") as! [String]
                let userID = userData[0]
                
                //send rating to PSLR
                Alamofire.request(endpoint, method: .post, parameters: ["user": userID, "movie":  self.movie._id, "rate": rating],encoding: JSONEncoding.default, headers: nil).responseString {
                    response in
                    switch response.result {
                    case .success:
                        print("Rating sent!")
                        break
                    case .failure(let error):
                        let alert = UIAlertController(title: "Server error", message: "The rating was not sent. Please try again later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        print(error)
                        print(response)
                    }
                }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        showLoadingAlert()
        
        //fetch comments
        Comments = []
        let endpoint2 = Endpoints.getComments
        Alamofire.request(endpoint2, method: .post, parameters: ["movie":movie._id],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                
                self.CommentsLoaded = true
                if(self.CommentsLoaded && self.RatingLoaded)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                let jsonResponse = response.result.value as! NSDictionary
                let commentsData = jsonResponse["data"] as! NSArray
                let numberOfElements = commentsData.count
                
                print(numberOfElements)
                
                if(numberOfElements > 0)
                {
                    for i in 0...numberOfElements-1
                    {
                        let jsonCommentsData = try! JSONSerialization.data(withJSONObject: commentsData[i], options: .prettyPrinted)
                        let comment = try! JSONDecoder().decode(Comment.self, from: jsonCommentsData)
                        self.Comments.append(comment)
                        
                        if(i == numberOfElements-1)
                        {
                            var positiveCommentsCount = 0
                            var negativeCommentsCount = 0
                            
                            let totalCommentsCount = self.Comments.count
                            for j in 0...totalCommentsCount-1
                            {
                                if(self.Comments[j].cls == 0){
                                    negativeCommentsCount = negativeCommentsCount+1
                                }else{
                                    positiveCommentsCount = positiveCommentsCount+1
                                }
                            }
                            
                            print(positiveCommentsCount)
                            print(negativeCommentsCount)
                            
                            if(positiveCommentsCount > totalCommentsCount/2)
                            {
                                self.commentsVerdict.text = "Mostly positive"
                                self.commentsVerdict.textColor = UIColor.green
                                
                            }else{
                                if(negativeCommentsCount > totalCommentsCount/2)
                                {
                                    self.commentsVerdict.text = "Mostly negative"
                                    self.commentsVerdict.textColor = UIColor.red
                                }else
                                {
                                    self.commentsVerdict.textColor = UIColor.black
                                    self.commentsVerdict.text = "Neutral"
                                }
                            }
                        }
                    }
                }
                
            case .failure(let error):
                
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    @IBAction func viewCommentsPressed(_ sender: Any) {
        
        //open comments view
        let commentsVC = storyboard?.instantiateViewController(withIdentifier: "commentsView") as! CommentsController
        commentsVC.movie = movie
        commentsVC.comments = Comments
        self.present(commentsVC, animated: true, completion: nil)
        
    }
    
    @IBAction func imdbPressed(_ sender: Any) {
        
        //Safari view Controller
        let safariVC = SFSafariViewController(url: NSURL(string: "https://www.imdb.com/title/tt" + movie.imdbId)! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
