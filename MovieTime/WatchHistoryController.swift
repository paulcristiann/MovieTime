//
//  WatchHistoryController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 22/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class WatchHistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var moviesTable: UITableView!
    
    var userID = ""
    var watchedMovies: [Movie] = []
    var moviePostersDictionary: [String:UIImage] = [:]
    var loaded = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let displayedMovie = watchedMovies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        if (moviePostersDictionary.count == watchedMovies.count)
        {
            cell.picture.image = moviePostersDictionary[watchedMovies[indexPath.row]._id]
            if(loaded == false)
            {
                loaded = true
                dismiss(animated: true, completion: nil)
            }
        }
        
        cell.titleLabel.text = displayedMovie.title
        if(displayedMovie.genres != "")
        {
            cell.genresLabel.text = displayedMovie.genres
        }else{
            cell.genresLabel.text = "No genre"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetails
        detailsVC.movie = watchedMovies[indexPath.row]
        detailsVC.poster = moviePostersDictionary[watchedMovies[indexPath.row]._id]!
        self.present(detailsVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(loaded == false)
        {
            showLoadingAlert()
        }
        else{
            
            loaded = false
            showLoadingAlert()
            fetchData()
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Get userID from User Defaults
        let user_data = UserDefaults.standard.object(forKey: "userData") as! [String]
        userID = user_data[0]
        
        //Get watched movies
        self.loadWatchedMovies(completion: {
            
            self.moviesTable.reloadData()
            
            if(self.watchedMovies.count > 0)
            {
                for i in 0...self.watchedMovies.count-1
                {
                    self.getPosterURLs(movie_id: self.watchedMovies[i]._id, completion: { img in
                        self.moviesTable.reloadData()
                    })
                }
            }
            
        })
        
    }
    
    func loadWatchedMovies(completion: @escaping ()->Void) {
        
        //get watched movies data
        let endpoint = Endpoints.history
        
        Alamofire.request(endpoint, method: .post, parameters: ["id":userID], encoding: JSONEncoding.default, headers: nil).responseJSON {
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
                        self.watchedMovies.append(movie)
                    }
                }else
                {
                    self.dismiss(animated: true, completion: nil)
                }
                completion()
                break
                
            case .failure(let error):
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
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
                let data = try! Data(contentsOf: urlObj!)
                let poster = UIImage(data: data)
                self.moviePostersDictionary[movie_id] = poster
                self.moviesTable.reloadData()
                break
                
            case .failure(let error):
                let alert = UIAlertController(title: "Server error", message: "Unknown error occured, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.moviePostersDictionary[movie_id] = UIImage()
                completion(UIImage())
                print(error)
            }
        }
        
    }
    
    func fetchData()
    {
        watchedMovies = []
        moviePostersDictionary = [:]
        
        self.loadWatchedMovies(completion: {
            
            self.moviesTable.reloadData()
            
            if(self.watchedMovies.count > 0)
            {
                for i in 0...self.watchedMovies.count-1
                {
                    self.getPosterURLs(movie_id: self.watchedMovies[i]._id, completion: { img in
                        self.moviesTable.reloadData()
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
