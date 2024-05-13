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
    @Published var products: [Product] = []
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

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
        startListening()
    }

    func startListening() {
        db.collection("products").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.products = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Product.self)
            }
        }
    }

    func addProduct(product: Product) {
        do {
            let _ = try db.collection("products").addDocument(from: product)
        } catch {
            print("Error adding product: \(error)")
        }
    }

    func deleteProduct(product: Product) {
        db.collection("products").document(product.id.uuidString).delete { error in
            if let error = error {
                print("Error deleting product: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteitem(products: Product) async -> Bool {
        let db = Firestore.firestore()
        let productsID = products.id.uuidString // Directly access uuidString property
        do {
            let _ = try await db.collection("products").document(productsID).delete()
            print("🗑️ Document successfully deleted!")
            return true
        } catch {
            print("ERROR: removing document \(error.localizedDescription)")
            return false
        }
    }
}
