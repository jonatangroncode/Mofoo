//
//  Posts.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//

import Foundation

let foodpost = Posts(recipe: "hej")

struct Posts : Identifiable{
    let id = UUID()
    var recipe : String
    var date : Date = Date()
}
