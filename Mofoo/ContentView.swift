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
        NavigationView {
               VStack {
                   List {
                       ForEach(post, id: \.id) { post in
                           Text(post.recipe)
                       }
                       .onDelete(perform: deletePost)
                   }
                   .navigationBarTitle("Recept")
                   .navigationBarItems(trailing: NavigationLink(destination: RecipeBook()) {
                       Image(systemName: "plus.circle")
                       
                       
                       
                       
                   })
          
                       HStack {
                           NavigationLink(destination: AddRecipe()) {
                               Text("Redigera")
                           }
                           .padding()
                           NavigationLink(destination: AddRecipe()) {
                               Text("Lägg till")

                           
                       }
                   }
               }
           }
           .background(Color.green)
           .onAppear() {
               self.listenToFirestore()
           }
       }
    
    func deletePost(indexSet: IndexSet) {
           for index in indexSet {
               let item = post[index]
               db.collection("post").document(item.id).delete()
               post.remove(at: index)
           }
       }
    
    func saveToFirestore(recipe: String, ingredience: [String], instructions: String) {
        let post = Posts(id: UUID().uuidString, recipe: recipe, ingredience: ingredience, instructions: instructions)
        
        do{
          _ = try db.collection("post").addDocument(from: post)
        }catch {
            print ("Error saving to db")
        }
        
        
//        db.collection("post").addDocument(data: ["recipe" : post.recipe,
//                                                 "ingredience" : post.ingredience,
//                                                 "instructions" : post.instructions,
//                                                 "date" : post.date])
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
