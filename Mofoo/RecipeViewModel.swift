//
//  RecipeViewModel.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-18.
//

//RecipeViewModel provides functionality for adding and retrieving recipes from Firestore, ensuring synchronization between the local app state and the database. It encapsulates the logic for managing recipe data, making it easier to maintain and interact with recipe-related functionality in the application.

import SwiftUI
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    var id: String 
    var title: String
    var instructions: String
    var ingredients: [Ingredient]
}

struct Ingredient: Identifiable, Equatable, Codable {
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
        let recipeRef = db.collection("recipes").document(newRecipe.id)
        
        // Add ingredients as a subcollection to the recipe document
        for ingredient in ingredients {
            let ingredientData: [String: Any] = [
                "title": ingredient.title,
                "amount": ingredient.amount,
                "unit": ingredient.unit
            ]
            recipeRef.collection("ingredients").document(ingredient.id).setData(ingredientData) { error in
                if let error = error {
                    print("Error adding ingredient: \(error)")
                }
            }
        }
        
        recipeRef.setData(recipeData) { error in
            if let error = error {
                print("Error adding recipe: \(error)")
            } else {
                print("Recipe added")
                self.getRecipes()
            }
        }
    }
    
    func getRecipes() {
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
    func deleteRecipe(recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes.remove(at: index) // Ta bort receptet från den lokala listan av recept
            
            // Ta bort receptet från Firestore-databasen
            db.collection("recipes").document(recipe.id).delete { error in
                if let error = error {
                    print("Error deleting recipe: \(error.localizedDescription)")
                } else {
                    print("Recipe deleted successfully")
                }
            }
        }
    }
}
