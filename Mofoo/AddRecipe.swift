//
//  AddRecipe.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-13.
//

import SwiftUI
import FirebaseFirestore


//AddRecipe provides a user-friendly interface for adding new recipes, allowing users to input recipe details step by step. It covers essential aspects such as recipe title, ingredients with amounts and units, instructions, and a way to add the recipe to the app's data model through the viewModel

struct AddRecipe: View {
    @State private var recipeTitle = ""
    @State private var recipeInstructions = ""
    @State private var ingredientTitle = ""
    @State private var ingredientAmount = ""
    @State private var ingredientUnit = "Gram"
    @State private var ingredients = [Ingredient]()
    @ObservedObject var viewModel = RecipeViewModel()
    var units = ["Gram",  "Mililiter", "Deciliter","Liter", "Antal"]
    @State private var selectedUnit = "Gram"

    var body: some View {
        VStack {
     
            HStack {
                Text("Recept:")
                    .fontWeight(.bold)
                Spacer()
            }
            TextField("Skriv ditt recept", text: $recipeTitle)

            HStack {
                Text("Ingridienser:")
                    .fontWeight(.bold)
                Spacer()
            }
            VStack {
                TextField("Skriv dina ingredienser", text: $ingredientTitle)

                VStack {
                    Picker("Välj ett mått", selection: $selectedUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Text(selectedUnit)
                }
                TextField("Skriv mängden", text: $ingredientAmount)
            }
            Button("Add Ingredient") {
                let ingredient = Ingredient(id: UUID().uuidString, title: ingredientTitle, amount: Double(ingredientAmount) ?? 0, unit: selectedUnit)
                ingredients.append(ingredient)
                ingredientTitle = ""
                ingredientAmount = ""
                selectedUnit = units[0] // Reset the picker to the first unit
            }

            List(ingredients) { ingredient in
                HStack {
                    Text("\(ingredient.title) - \(ingredient.amount) \(ingredient.unit)")
                    Spacer()
                    Button("Delete") {
                        if let index = ingredients.firstIndex(of: ingredient) {
                            ingredients.remove(at: index)
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .frame(height: 250)

            HStack {
                Text("Instruktioner:")
                    .fontWeight(.bold)
                Spacer()
            }
            VStack {
                if recipeInstructions.isEmpty {
                    Text("Skriv dina instruktioner här")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                  
                }
                TextEditor(text: $recipeInstructions)
                    .frame(minHeight: 100)
            }
            
            Button("Lägg till Recept") {
                let recipe = Recipe(id: UUID().uuidString, title: recipeTitle, instructions: recipeInstructions, ingredients: ingredients)
                viewModel.addRecipe(title: recipe.title, instructions: recipe.instructions, ingredients: recipe.ingredients)
                
                // Rensa texterna
                recipeTitle = ""
                recipeInstructions = ""
                ingredientTitle = ""
                ingredientAmount = ""
                ingredients = []
            }
        }.navigationTitle("Add recipe")

    }
}
