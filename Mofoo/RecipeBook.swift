//
//  RecipeBook.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-11.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecipeBook: View {
    @State var search = ""
    @ObservedObject var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(self.viewModel.recipes.filter{(self.search.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(self.search))}, id: \.id) { recipe in
                    NavigationLink(destination: RecipeDetail(recipe: recipe)) {
                        Text(recipe.title)
                    }
                }
            }
            .navigationTitle("Sök Recept")
            .searchable(text: $search)
            .onAppear {
                self.viewModel.getRecipes()
            }
        }
    }
}

struct RecipeDetail: View {
    var recipe: Recipe

    var body: some View{
        VStack {
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(10)
            Text("Ingredienser")
                .padding(10)
                .fontWeight(.bold)
            HStack {
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    Text("\(ingredient.title) \(ingredient.amount) \(ingredient.unit)")
                }
            }
            Text("Instruktioner")
                .padding(10)
                .fontWeight(.bold)
            Text(recipe.instructions)
                .padding(10)
            Button("Lägg till") {
                // Add your action here
            }
        }
    }
}
