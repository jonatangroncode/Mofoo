//
//  AddRecipe.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-13.
//

import SwiftUI
import FirebaseFirestore



struct AddRecipe: View {
    @State private var recipeTitle = ""
    @State private var recipeInstructions = ""
    @State private var ingredientTitle = ""
    @State private var ingredientAmount = ""
    @State private var ingredientUnit = "Gram"
    @State private var ingredients = [Ingredient]()
    @ObservedObject var viewModel = RecipeViewModel()
    var units = ["Gram", "Liter", "ML", "Deciliter"]
    @State private var selectedUnit = "Gram"

    var body: some View {
        VStack {
            Text("Lägg till nytt recept")
                .fontWeight(.bold)
                .font(.title)
                .padding(10)

            HStack {
                Text("Recept")
                    .fontWeight(.bold)
                Spacer()
            }
            TextField("Skriv ditt recept", text: $recipeTitle)

            HStack {
                Text("Ingridienser")
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
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
                Text("Instruktioner")
                    .fontWeight(.bold)
                Spacer()
            }
            TextField("Skriv dina Instruktioner", text: $recipeInstructions)

            Button("Lägg till Recept") {
                let recipe = Recipe(id: UUID().uuidString, title: recipeTitle, instructions: recipeInstructions, ingredients: ingredients)
                viewModel.addRecipe(title: recipe.title, instructions: recipe.instructions, ingredients: recipe.ingredients)
            }
        }
    }
}
