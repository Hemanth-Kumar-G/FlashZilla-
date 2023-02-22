//
//  Card.swift
//  Flashzilla
//
//  Created by HEMANTH on 19/02/23.
//

import Foundation

struct Card:Codable{
    let prompt:String
    let answer :String
    

    static let example = Card(prompt: "Who is the Father of the country ?", answer: "Mahatma Gandhi")
}
