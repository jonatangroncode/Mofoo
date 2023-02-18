//
//  RecipeViewModel.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-18.
//

import SwiftUI
import FirebaseFirestore

struct Recipe: Identifiable {
    var id: String 
    var title: String
    var instructions: String
    var ingredients: [Ingredient]
}

struct Ingredient: Identifiable, Equatable {
    var id: String
    var title: String
    var amount: Double
    var unit: String
    
    init(id: String, title: String, amount: Double, unit: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.unit = unit
    }
    
    static func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.id == rhs.id
    }
}

class RecipeViewModel: ObservableObject {
    @Published var recipes = [Recipe]()
    private var db = Firestore.firestore()
    
    func addRecipe(title: String, instructions: String, ingredients: [Ingredient]) {
        let newRecipe = Recipe(id: UUID().uuidString, title: title, instructions: instructions, ingredients: ingredients)
        let recipeData = ["title": title, "instructions": instructions]

        db.collection("recipes").addDocument(data: recipeData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Recipe added")
                self.getRecipes()
            }
        }
    }

    private func getRecipes() {
        db.collection("recipes").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.recipes = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let instructions = data["instructions"] as? String ?? ""
                    let ingredientsRef = document.reference.collection("ingredients")
                    var ingredients = [Ingredient]()
                    ingredientsRef.getDocuments { snapshot, error in
                        if let error = error {
                            print("Error getting ingredients: \(error)")
                        } else {
                            ingredients = snapshot?.documents.compactMap { ingredientDocument in
                                let ingredientData = ingredientDocument.data()
                                let ingredientID = ingredientDocument.documentID
                                let ingredientTitle = ingredientData["title"] as? String ?? ""
                                let ingredientAmount = ingredientData["amount"] as? Double ?? 0.0
                                let ingredientUnit = ingredientData["unit"] as? String ?? ""
                                return Ingredient(id: ingredientID, title: ingredientTitle, amount: ingredientAmount, unit: ingredientUnit)
                            } ?? []
                            if let index = self.recipes.firstIndex(where: { $0.id == id }) {
                                self.recipes[index].ingredients = ingredients
                            }
                        }
                    }
                    return Recipe(id: id, title: title, instructions: instructions, ingredients: ingredients)
                } ?? []
            }
        }
    }
}
