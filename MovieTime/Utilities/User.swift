//
//  User.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 19/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation

struct User: Codable
{
    var preferences: [String] = []
    var _id: String = ""
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var sessionToken: String = ""
    var socialLogin: Bool = false
    var __v: Int = 1
}
