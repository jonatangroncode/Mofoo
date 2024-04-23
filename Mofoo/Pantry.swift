//
//  Pantry.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-14.
//

import SwiftUI
import Firebase


//The Pantry view allows users to manage their pantry by adding, deleting, and viewing products.
//Pantry provides a user interface for managing pantry products and leverages Firestore for data storage and synchronization. It also offers integration with RecipeTipsView for exploring recipe tips based on the pantry's contents.

struct Pantry: View {
    @State private var products: [Product] = []
    @ObservedObject var firestoreService = FirestoreService()
    @State private var recipeTips: [Recipe] = []

    struct Product: Identifiable, Codable, Equatable {
        var id = UUID()
        var name: String
        var amount: Double
        var unit: String

        static func ==(lhs: Product, rhs: Product) -> Bool {
            return lhs.id == rhs.id
        }
    }

    let units = ["Gram", "Kilo", "Mililiter", "Centiliter", "Deciliter", "Liter", "Msk" , "Tsk", "Antal"]

    @State private var userInputProduct = Product(name: "", amount: 0, unit: "")

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Produkt")
                        .fontWeight(.bold)
                    Spacer()
                }
                TextField("Skriv dina produkter",
                          text: $userInputProduct.name)
                TextField("Mängd", value: $userInputProduct.amount, formatter: NumberFormatter())
                Picker(selection: $userInputProduct.unit, label: Text("Enhet")) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                .onAppear {
                    userInputProduct.unit = "Gram"  // sets the picker to gram at start
                }

                List(firestoreService.products) { product in
                    HStack {
                        Text("\(String(format: "%.2f", product.amount)) \(product.unit) \(product.name)")
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .onTapGesture {
                                firestoreService.deleteProduct(product: product)
                            }
                    }
                }
                .onAppear {
                    firestoreService.startListening()
                }

                Spacer()
                HStack{
                    Button(action: {
                        firestoreService.addProduct(product: userInputProduct)
                        userInputProduct = Product(name: "", amount: 0, unit: "Gram")
                    }) {
                        Text("Lägg till")
                    }
                    
                    NavigationLink(destination: RecipeTipsView(recipeTips: $recipeTips)) {
                        Text("View Recipe Tips")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
        }.navigationTitle("Pantry")
    }
}





class FirestoreService: ObservableObject {
    let db = Firestore.firestore()
    @Published var products = [Pantry.Product]()
    private var listenerRegistration: ListenerRegistration?
    
    func addProduct(product: Pantry.Product) {
        do {
            let productData = try JSONEncoder().encode(product)
            guard let productDictionary = try JSONSerialization.jsonObject(with: productData, options: []) as? [String: Any] else {
                print("Error encoding product data.")
                return
            }
            let _ = try db.collection("products").addDocument(data: productDictionary)
        } catch {
            print("Error adding product: \(error.localizedDescription)")
        }
    }
    
    func deleteProduct(product: Pantry.Product) {
        db.collection("products").document(product.id.uuidString).delete() { error in
            if let error = error {
                print("Error deleting product: \(error.localizedDescription)")
            } else {
                if let index = self.products.firstIndex(of: product) {
                    self.products.remove(at: index)
                }
            }
        }
    }
    
    func startListening() {
        listenerRegistration = db.collection("products").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.products = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Pantry.Product.self)
            }
        }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    func fetchRecipes(completion: @escaping ([Recipe]) -> Void) {
        db.collection("recipes").getDocuments() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching recipes: \(error!)")
                return
            }
            let recipes = documents.compactMap { document in
                try? document.data(as: Recipe.self)
            }
            completion(recipes)
        }
    }
    
    func firestoreService_addProduct(product: Pantry.Product) {
        do {
            let _ = try db.collection("products").addDocument(from: product)
            fetchRecipes() { recipes in
                let pantryProducts = self.products
                let matchingRecipes = recipes.filter { recipe in
                    return recipeMatchesPantry(recipe: recipe, pantryProducts: pantryProducts)
                }
                let batch = self.db.batch()
                for recipe in matchingRecipes {
                    let recipeRef = self.db.collection("recipeTips").document(recipe.id)
                    let recipeData = ["title": recipe.title, "instructions": recipe.instructions]
                    batch.setData(recipeData, forDocument: recipeRef, merge: true)
                }
                batch.commit() { err in
                    if let err = err {
                        print("Error writing batch: \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
        } catch {
            print("Error adding product: \(error)")
        }
    }

}
