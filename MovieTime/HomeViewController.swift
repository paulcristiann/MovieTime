//
//  HomeViewController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 16/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var topMovies: [Movie] = []
    var recommendedMovies: [Movie] = []
    
    var loaded = false
    
    var moviePostersDictionary: [String:UIImage] = [:]
    var recommendedPostersDictionary: [String:UIImage] = [:]
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionView2: UICollectionView!
    
    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var movieTimeLabel: UILabel!
    
    //Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.collectionView)
        {
            return topMovies.count
        }
        
        return recommendedMovies.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        if(collectionView == self.collectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.clipsToBounds = true
            
            if(moviePostersDictionary.count == topMovies.count)
            {
                cell.movieImage.image = moviePostersDictionary[topMovies[indexPath.row]._id]
            }
            cell.movieName.text = topMovies[indexPath.row].title
            
            return cell
        }
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! CollectionViewCell
            
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.clipsToBounds = true
            
            if(recommendedPostersDictionary.count == recommendedMovies.count)
            {
                cell.movieImage.image = recommendedPostersDictionary[recommendedMovies[indexPath.row]._id]
                if(loaded == false)
                {
                    dismiss(animated: true, completion: nil)
                    loaded = true
                }
            }
            cell.movieName.text = recommendedMovies[indexPath.row].title
            
            return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //open movie page
        
        if(collectionView == self.collectionView)
        {
            
            let detailsVC = storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetails
            detailsVC.movie = topMovies[indexPath.row]
            detailsVC.poster = moviePostersDictionary[topMovies[indexPath.row]._id]!
            self.present(detailsVC, animated: true, completion: nil)
            
        }else
        {
            let detailsVC = storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetails
            detailsVC.movie = recommendedMovies[indexPath.row]
            detailsVC.poster = recommendedPostersDictionary[recommendedMovies[indexPath.row]._id]!
            self.present(detailsVC, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(loaded == false)
        {
            showLoadingAlert()
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(refreshTapped))
        movieTimeLabel.isUserInteractionEnabled = true
        movieTimeLabel.addGestureRecognizer(tapGestureRecognizer1)
        
        self.loadTopMovies(completion: {
            
            self.collectionView.reloadData()
            
            for i in 0...self.topMovies.count-1
            {
                self.getPosterURLs(movie_id: self.topMovies[i]._id, completion: { img in
                    print(self.topMovies[i]._id)
                    self.collectionView.reloadData()
                })
            }
            
        })
        
        self.loadRecommendedMovies(completion: {
        
            self.collectionView2.reloadData()
            
            if(self.recommendedMovies.count > 0)
            {
                for i in 0...self.recommendedMovies.count-1
                {
                    self.getPosterRecURLs(movie_id: self.recommendedMovies[i]._id, completion: { img in
                        print(self.recommendedMovies[i]._id)
                        self.collectionView2.reloadData()
                    })
                }
            }
        
        })
        
        let userDefaults = UserDefaults.standard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView2.showsHorizontalScrollIndicator = false
        collectionView2.showsVerticalScrollIndicator = false
        
        let userData = userDefaults.object(forKey: "userData") as! [String]
        let userName = userData[4]
        
        helloLabel.text = "Welcome, " + userName
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //open the user page
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "userView") as! UserSettingsController
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadTopMovies(completion: @escaping ()->Void) {
       
        //get top movies data
        let endpoint = Endpoints.top
        
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
                    self.topMovies.append(movie)
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
    
    func loadRecommendedMovies(completion: @escaping ()->Void) {
        
        //get top movies data
        let endpoint = Endpoints.recommandations
        
        let user_data = UserDefaults.standard.object(forKey: "userData") as! [String]
        
        Alamofire.request(endpoint, method: .post, parameters: ["id":user_data[0]],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                let moviesData = jsonResponse["data"] as! NSArray
                let numberOfElements = moviesData.count
                
                if(numberOfElements > 0)
                {
                    for i in 0...numberOfElements-1
                    {
                        let jsonMovieData = try! JSONSerialization.data(withJSONObject: moviesData[i], options: .prettyPrinted)
                        let movie = try! JSONDecoder().decode(Movie.self, from: jsonMovieData)
                        self.recommendedMovies.append(movie)
                    }
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
                    self.moviePostersDictionary[movie_id] = poster
                    
                }catch{
                    print("Link is broken")
                    self.moviePostersDictionary[movie_id] = UIImage(named: "imagine_film")
                }
                self.collectionView.reloadData()
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
    
    func getPosterRecURLs(movie_id: String, completion: @escaping (UIImage)->Void)
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
                    self.recommendedPostersDictionary[movie_id] = poster
                    
                }catch{
                    print("Link is broken")
                    self.recommendedPostersDictionary[movie_id] = UIImage(named: "imagine_film")
                }
                self.collectionView2.reloadData()
                break
                
            case .failure(let error):
                
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                completion(UIImage())
                print(error)
            }
        }
        
    }
    
    @objc func refreshTapped()
    {
        loaded = false
        topMovies = []
        recommendedMovies = []
        
        moviePostersDictionary = [:]
        recommendedPostersDictionary = [:]
        
        showLoadingAlert()
        
        print("Refresh interface")
        self.loadTopMovies(completion: {
            
            self.collectionView.reloadData()
            
            for i in 0...self.topMovies.count-1
            {
                self.getPosterURLs(movie_id: self.topMovies[i]._id, completion: { img in
                    print(self.topMovies[i]._id)
                    self.collectionView.reloadData()
                })
            }
            
        })
        
        self.loadRecommendedMovies(completion: {
            
            self.collectionView2.reloadData()
            
            if(self.recommendedMovies.count > 0)
            {
                for i in 0...self.recommendedMovies.count-1
                {
                    self.getPosterRecURLs(movie_id: self.recommendedMovies[i]._id, completion: { img in
                        print(self.recommendedMovies[i]._id)
                        self.collectionView2.reloadData()
                    })
                }
            }
            
        })
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
