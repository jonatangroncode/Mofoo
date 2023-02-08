//
//  ContentView.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//

import SwiftUI
import Firebase

struct ContentView: View {
    let db = Firestore.firestore()
    
    @State var post = [Posts]()
    
    var body: some View {
        List(post){ entry in
            Text(entry.recipe)
        }
        .onAppear() {
            self.listenToFirestore()
//            self.saveToFirestore(recipe: "pannkakor", ingredience: ["mjölk", "mjöl"], instructions: "blanda och stek")
        }
    }
    
    func saveToFirestore(recipe: String, ingredience: [String], instructions: String) {
        let post = Posts(id: UUID().uuidString, recipe: recipe, ingredience: ingredience, instructions: instructions)
            
        db.collection("post").addDocument(data: ["recipe" : post.recipe,
                                                 "ingredience" : post.ingredience,
                                                 "instructions" : post.instructions,
                                                 "date" : post.date])
    }
    
    func listenToFirestore(){
        db.collection("post").addSnapshotListener{ snapshot, err in
            guard let snapshot = snapshot else{return}
                
                if let err = err {
                    print("Error getting document \(err)")
                } else {
                    for document in snapshot.documents {
                        let id = document.documentID
                        let recipe = document["recipe"] as! String
                        let ingredients = document["ingredients"] as? [String] ?? []
                        let instructions = document["instructions"] as! String
                        
                    
                        
                        let post = Posts(id: id, recipe: recipe, ingredience: ingredients, instructions: instructions)
                        self.post.append(post)
                    }
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
