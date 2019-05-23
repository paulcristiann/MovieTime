//
//  SearchCell.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 18/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit

class ResultCell: UITableViewCell{
    
	@IBOutlet weak var picture: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
	override func prepareForReuse() {
		titleLabel.text = ""
	}
}
