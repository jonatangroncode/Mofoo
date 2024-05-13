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
    
    @State private var post = [Posts]()
    @State private var search = ""
    @ObservedObject private var viewModel = RecipeViewModel()
    @State private var randomRecipeTitle: String? = nil // Variable to hold the title of the random recipe
    @State private var isRecipeDetailActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                VStack {
                    Spacer()
                  
                    
                    NavigationLink(destination: RecipeDetail(recipe: self.viewModel.recipes.first(where: { $0.title == self.randomRecipeTitle }) ?? Recipe(id: "", title: "", instructions: "", ingredients: [])), isActive: $isRecipeDetailActive) {
                        VStack {
                            Text(self.randomRecipeTitle ?? "Tryck på knappen för att få ett random recept som du kan gå vidare till")
                                .padding()
                                .cornerRadius(8)
                                .font(.system(size: 24))
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                                .font(Font.system(size: 36))
                                .padding(.top, 8)
                                .padding(.bottom, 16) 
                            
                        }
                    }
                   
                    Button(action: {
                                          // Action when button is tapped
                                          if !self.post.isEmpty {
                                              let randomIndex = Int.random(in: 0..<self.post.count)
                                              self.randomRecipeTitle = self.post[randomIndex].recipe
                                          }
                                      }) {
                                          Text("Få random recept")
                                              .foregroundColor(.white)
                                              .padding()
                                              .background(Color.blue)
                                              .cornerRadius(8)
                                      }
                                      
                                      .padding(.horizontal)
                                      .padding(EdgeInsets(top: 80, leading: 16, bottom: 8, trailing: 16)) // Lägg till padding runt navigeringslänken

                                      

                    Spacer()
                    
                        .navigationBarItems(trailing: NavigationLink(destination: RecipeBook()) {
                            Image(systemName: "magnifyingglass")          
                                .foregroundColor(.white)
                                .padding(9)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .padding(8)
                        })

                    HStack {
                        NavigationLink(destination: AddRecipe()) {
                            Text("Lägg till recept")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        NavigationLink(destination: Pantry()) {
                            Text("Skafferi")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                self.viewModel.getRecipes()
                self.listenToFirestore()
            }
           
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
        
        do {
            _ = try db.collection("post").addDocument(from: post)
        } catch {
            print ("Error saving to db")
        }
    }
    
    func listenToFirestore() {
        db.collection("recipes").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else { return }
                
            if let err = err {
                print("Error getting document \(err)")
            } else {
                for document in snapshot.documents {
                    let id = document.documentID
                    let recipe = document["title"] as! String
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
