//
//  AuthentificationResponseModel.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 17/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation

struct AuthentificationResponseModel: Codable
{
    var status: String?
    var error: String?
    var data: UserData?    
}
