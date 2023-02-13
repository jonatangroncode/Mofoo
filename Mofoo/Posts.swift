//
//  Posts.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//
import Foundation
import SwiftUI
import Firebase


//let foodpost = Posts(id: <#String#>, recipe: "hej", ingredience: ["salt", "Ost"], instructions: "koka 10 min")

class getData : ObservableObject {

    @Published var datas = [Posts]()

init () {
    
    let db = Firestore.firestore()
    
    db.collection("post").getDocuments{(snap, err) in
        
        if err != nil {
            print ((err?.localizedDescription)!)
            return
        }
        
        for i in snap!.documents{
            
            let id = i.documentID
            let recipe = i.get ("recipe") as! String
            let ingredience = i.get ("ingredience") as? [String] ?? []
            let instructions = i.get ("instructions") as! String
            
            self.datas.append(Posts(id: id, recipe: recipe, ingredience: ingredience, instructions: instructions))
            
            }
        
        }
        
    }
    
}

struct Posts : Identifiable, Codable {
    var id : String
    var recipe : String
    var ingredience : [String]?
    var instructions : String
    var date : Timestamp = Timestamp()
}
