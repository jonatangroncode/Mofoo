//
//  RecipeBook.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-11.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

//Page where all recipes are showed, you can search for recipes and clickon the recipes to navigate to the detailpage of a specific recipe of the recipe

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



