//
//  CommentsController.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 19/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit

class CommentsController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var movie: Movie = Movie()
    var comments: [Comment] = []
    var firstOpened = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        
        cell.authorLabel.text =  "Written by " + comments[indexPath.row].user.name
        cell.textBox.text = comments[indexPath.row].comment
        
        if(comments[indexPath.row].cls == 0)
        {
            cell.feedbackImage.image = UIImage(named: "dislike-1.png")
        }else{
            cell.feedbackImage.image = UIImage(named: "like-1.png")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        commentsTable.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBOutlet weak var commentsTable: UITableView!
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(firstOpened)
        {
            dismiss(animated: true, completion: nil)
        }else{
            firstOpened = true
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        
        let addCommentVC = storyboard?.instantiateViewController(withIdentifier: "addComments") as! AddCommentController
        addCommentVC.movie = movie
        self.present(addCommentVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
