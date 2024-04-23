//
//  RecipeTipsView.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-22.
//


//The RecipeTipsView provides a list of recipe tips based on the products available in the user's pantry.

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecipeTipsView: View {
    @Binding var recipeTips: [Recipe]
    @ObservedObject var firestoreService = FirestoreService()
    
    var body: some View {
        List(recipeTips) { recipe in
            Text(recipe.title)
        }
        .onAppear {
            firestoreService.fetchRecipes() { recipes in
                let pantryProducts = firestoreService.products
                recipeTips = recipes.filter { recipe in
                    return recipeMatchesPantry(recipe: recipe, pantryProducts: pantryProducts)
                }
            }
        }
    }
}

func recipeMatchesPantry(recipe: Recipe, pantryProducts: [Pantry.Product]) -> Bool {
    for ingredient in recipe.ingredients {
        let matchingProduct = pantryProducts.first { product in
            return product.name.lowercased() == ingredient.title.lowercased()
        }
        if matchingProduct == nil {
            return false
        }
    }
    return true
}
