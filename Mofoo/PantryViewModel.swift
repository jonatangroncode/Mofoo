//
//  PantryViewModel.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-22.
//

import SwiftUI
import Combine
import FirebaseFirestore

class PantryViewModel: ObservableObject {
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var products: [Product] = []
    @Published var showAlert = false
    @Published var userInputProduct = Product(name: "", amount: 0, unit: "") // Lägg till userInputProduct här

    struct Product: Identifiable, Codable, Equatable {
        var id = UUID()
        var name: String
        var amount: Double
        var unit: String

        static func ==(lhs: Product, rhs: Product) -> Bool {
            return lhs.id == rhs.id
        }
    }

    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        listener = db.collection("products").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Empty snapshot")
                return
            }
            
            self.products = snapshot.documents.compactMap { queryDocumentSnapshot in
                do {
                    let product = try queryDocumentSnapshot.data(as: Product.self)
                    return product
                } catch {
                    print("Error decoding product: \(error)")
                    return nil
                }
            }
        }
    }

    func removeSnapshotListener() {
        listener?.remove()
    }

    func deleteProduct(at offsets: IndexSet) {
        for index in offsets {
            let product = products[index]
            
            db.collection("products").whereField("name", isEqualTo: product.name).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Document not found")
                    return
                }
                
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            // If deletion from Firestore is successful, remove the product from the products array
                            DispatchQueue.main.async {
                                if let indexToRemove = self.products.firstIndex(where: { $0.name == product.name }) {
                                    self.products.remove(at: indexToRemove)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func removeProduct(_ product: Product, completion: @escaping (Bool) -> Void) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else {
            completion(false)
            return
        }

        let productRef = db.collection("products").document(product.id.uuidString)
        
        productRef.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                // Remove the product from the products array
                DispatchQueue.main.async {
                    self.products.remove(at: index)
                    completion(true)
                }
            }
        }
    }

    func addProduct() {
        let newProduct = userInputProduct
        
        if products.contains(where: { $0.name == newProduct.name }) {
            showAlert = true
            return
        }
        
        do {
            let _ = try db.collection("products").addDocument(from: newProduct)
            // Clear input fields after adding the product
            userInputProduct = Product(name: "", amount: 0, unit: "")
        } catch {
            print("Error adding product: \(error)")
        }
    }
}
