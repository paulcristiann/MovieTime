//
//  Comment.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 19/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit

struct Comment: Codable
{
    var user: User = User()
    var movie: String = ""
    var comment: String = ""
    var cls: Int = 0
}
