//
//  SearchViewController.swift
//  MovieTime
//
//  Created by Georgiana Untaru on 18/05/2019.
//  Copyright (c) 2019 Paul-Cristian Vasile. All rights reserved.
//


import UIKit

import Alamofire

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	var movies: [Movie] = []
    
    var loaded = false
	
	var moviePostersDictionary: [String:UIImage] = [:]
	
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
		
        if(loaded == false)
        {
            showLoadingAlert()
            
        }else{
            
            loaded = false
            showLoadingAlert()
            
        }
        
        movies = []
        moviePostersDictionary = [:]
        
		self.searchMovies(completion: {
			
			self.tableView.reloadData()
			
            if(self.movies.count > 0)
            {
                for i in 0...self.movies.count-1
                {
                    self.getPosterURLs(movie_id: self.movies[i]._id, completion: { img in
                        print(self.movies[i]._id)
                        self.tableView.reloadData()
                    })
                }
            }else
            {
                self.dismiss(animated: true, completion: nil)
            }
			
		})
		
		return true
	}

	
	
	//TableView Delegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return movies.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let displayedMovie = movies[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
		
		if (moviePostersDictionary.count == movies.count)
		{
			cell.picture.image = moviePostersDictionary[movies[indexPath.row]._id]
            if(loaded == false)
            {
                dismiss(animated: true, completion: nil)
                loaded = true
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
        detailsVC.movie = movies[indexPath.row]
        detailsVC.poster = moviePostersDictionary[movies[indexPath.row]._id]!
        self.present(detailsVC, animated: true, completion: nil)
        
    }
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
        searchTextField.borderStyle = .none
		
	}
	
	func searchMovies(completion: @escaping ()->Void) {
		
		//get top movies data
		let endpoint = Endpoints.search
		let title = searchTextField.text
		
        Alamofire.request(endpoint, method: .post, parameters: ["term":title as Any],encoding: JSONEncoding.default, headers: nil).responseJSON {
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
                        self.movies.append(movie)
                    }
                    completion()
                    break
                    
                }
                completion()
                
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
				if (urlObj?.absoluteString == "N/A")
				{
					let poster = UIImage(named: "imagine_film")
					self.moviePostersDictionary[movie_id] = poster
				}
				else {
                    do{
                        
                        let data = try Data(contentsOf: urlObj!)
                        let poster = UIImage(data: data)
                        self.moviePostersDictionary[movie_id] = poster
                        
                    }catch{
                        print("Link is broken")
                        self.moviePostersDictionary[movie_id] = UIImage(named: "imagine_film")
                    }
					
				}
				
				self.tableView.reloadData()
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
