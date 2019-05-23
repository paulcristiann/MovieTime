//
//  PreferencesController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 18/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import Koloda
import UIKit
import Alamofire

class PreferencesController: UIViewController, KolodaViewDelegate, KolodaViewDataSource
{
    
    var defaultMovies: [Movie] = []
    var defaultMoviesPostersDictionary: [String:UIImage] = [:]
    var favouriteMovies: [Movie] = []
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let card = UIView()
        
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 8.0
        card.clipsToBounds = true
        
        let movieImage = UIImageView(frame: CGRect.zero)
        if(defaultMovies.count == defaultMoviesPostersDictionary.count)
        {
            movieImage.image = defaultMoviesPostersDictionary[defaultMovies[index]._id]
        }
        
        let movieLabel = UILabel()
        movieLabel.text = defaultMovies[index].title
        movieLabel.textColor = UIColor.black
        movieLabel.font = movieLabel.font.withSize(20)
        movieLabel.textAlignment = .center
        
        card.addSubview(movieImage)
        card.addSubview(movieLabel)
        
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieImage.leadingAnchor.constraint(equalTo: card.leadingAnchor).isActive = true
        movieImage.trailingAnchor.constraint(equalTo: card.trailingAnchor).isActive = true
        movieImage.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -25).isActive = true
        movieImage.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
        
        movieLabel.translatesAutoresizingMaskIntoConstraints = false
        movieLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor).isActive = true
        movieLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor).isActive = true
        movieLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: 0).isActive = true
        
        
        
        return card
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return defaultMovies.count
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //get the movie
        let curentMovie = defaultMovies[index]
        
        if(direction == SwipeResultDirection.left)
        {
            favouriteMovies.append(curentMovie)
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        //Send prefered data to server and go home
        
        if(favouriteMovies.count < 3)
        {
            let alert = UIAlertController(title: "Warning", message: "Please select a minimum of 3 movies", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.favouriteMovies = []
            koloda.resetCurrentCardIndex()
        }
        
        else{
            
            let endpoint = Endpoints.userDefaults
            
            let userDefaults = UserDefaults.standard
            let userData = userDefaults.object(forKey: "userData") as! [String]
            let userid = userData[0]
            var preferencesIDs: String = ""
            
            for i in 0...favouriteMovies.count-1
            {
                preferencesIDs.append(favouriteMovies[i]._id)
                preferencesIDs.append(",")
            }
            
            preferencesIDs.removeLast()
            
            print(preferencesIDs)
            
            Alamofire.request(endpoint, method: .post, parameters: ["id": userid, "preferences":  preferencesIDs],encoding: JSONEncoding.default, headers: nil).responseString {
                response in
                switch response.result {
                case .success:
                    if let tabViewController = self.storyboard!.instantiateViewController(withIdentifier: "homeScreen") as? UITabBarController {
                        self.present(tabViewController, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                    let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    print(error)
                    print(preferencesIDs)
                    print(response)
                    self.favouriteMovies = []
                    koloda.resetCurrentCardIndex()
                }
            }
            
        }
        
    }
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var dislikeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.loadDefaultMovies(completion: {
            
            self.kolodaView.reloadData()
            
            for i in 0...self.defaultMovies.count-1
            {
                self.getPosterURLs(movie_id: self.defaultMovies[i]._id, completion: { img in
                    print(self.defaultMovies[i]._id)
                    self.kolodaView.reloadData()
                })
            }
            
        })
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(likeImageTapped(tapGestureRecognizer:)))
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(dislikeImageTapped(tapGestureRecognizer:)))
        dislikeImage.isUserInteractionEnabled = true
        dislikeImage.addGestureRecognizer(tapGestureRecognizer2)
        
    }
    
    @objc func likeImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        kolodaView.swipe(SwipeResultDirection.left)
    }
    
    @objc func dislikeImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        kolodaView.swipe(SwipeResultDirection.right)
    }
    
    func loadDefaultMovies(completion: @escaping ()->Void) {
        
        //get top movies data
        let endpoint = Endpoints.fetchMovies
        
        Alamofire.request(endpoint, method: .post, parameters: [:],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                let moviesData = jsonResponse["data"] as! NSArray
                let numberOfElements = moviesData.count
                
                for i in 0...numberOfElements-1
                {
                    let jsonMovieData = try! JSONSerialization.data(withJSONObject: moviesData[i], options: .prettyPrinted)
                    let movie = try! JSONDecoder().decode(Movie.self, from: jsonMovieData)
                    self.defaultMovies.append(movie)
                }
                completion()
                break
                
            case .failure(let error):
                
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                completion()
                print(error)
            }
        }
    }
    
    func getPosterURLs(movie_id: String, completion: @escaping (UIImage)->Void)
    {
        
        Alamofire.request(Endpoints.fetchImage, method: .post, parameters: ["id":movie_id],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                let urlString = jsonResponse["data"] as! String
                let urlObj = URL(string: urlString)
                do{
                    
                    let data = try Data(contentsOf: urlObj!)
                    let poster = UIImage(data: data)
                    self.defaultMoviesPostersDictionary[movie_id] = poster
                    
                }catch{
                    print("Link is broken")
                    self.defaultMoviesPostersDictionary[movie_id] = UIImage(named: "imagine_film")
                }
                self.kolodaView.reloadData()
                break
                
            case .failure(let error):
                
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                completion(UIImage())
                print(error)
            }
        }
        
    }
}
