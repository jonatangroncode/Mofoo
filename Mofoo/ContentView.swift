//
//  ContentView.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//

import SwiftUI
import Firebase

// this is the main page where you get a random recipe from the recipe collection, you can navegate to the other pages from here

struct ContentView: View {
    let db = Firestore.firestore()
    
    @State private var search = ""
    @ObservedObject private var viewModel = RecipeViewModel()
    @State private var randomRecipeTitle: String? = nil // Variable to hold the title of the random recipe
    @State private var isRecipeDetailActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                VStack {
                    Spacer()
                  
                    // future improvement change to navigationDestination but works for now
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
                        if !self.viewModel.recipes.isEmpty {
                            let randomIndex = Int.random(in: 0..<self.viewModel.recipes.count)
                            self.randomRecipeTitle = self.viewModel.recipes[randomIndex].title
                        }
                    }) {
                        Text("Få random recept tips för idag")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(EdgeInsets(top: 80, leading: 16, bottom: 8, trailing: 16))
                    

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
            }
           
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
