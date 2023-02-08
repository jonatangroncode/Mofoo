//
//  Posts.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//
import Foundation


//let foodpost = Posts(id: <#String#>, recipe: "hej", ingredience: ["salt", "Ost"], instructions: "koka 10 min")

struct Posts : Identifiable, Codable {
    var id : String
    var recipe : String
    var ingredience : [String]
    var instructions : String
    var date : Date = Date()
    
}
