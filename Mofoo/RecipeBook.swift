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



// where you get navigated to when you want to know the specifics of a recipe

struct RecipeDetail: View {
    var recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    let db = Firestore.firestore()
    
    var body: some View{
        VStack {
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(10)
            Text("Ingredienser")
                .padding(10)
                .fontWeight(.bold)
            List(recipe.ingredients, id: \.id) { ingredient in
                Text("\(ingredient.title) \(ingredient.amount) \(ingredient.unit)")
            }
            Text("Instruktioner")
                .padding(10)
                .fontWeight(.bold)
            Text(recipe.instructions)
                .padding(10)
        }
        .padding()
        .navigationBarItems(trailing:
            Button(action: {
                showingAlert = true
            }) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .imageScale(.large)
                    .padding()
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Delete Recipe"),
                    message: Text("Are you sure you want to delete this recipe?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteRecipe()
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        )
    }
    
    func deleteRecipe() {
        db.collection("recipes").document(recipe.id).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
