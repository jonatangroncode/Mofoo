import SwiftUI
import Firebase
import FirebaseFirestore

struct Pantry: View {
    let db = Firestore.firestore()
    @State private var userInputProduct = Product(name: "", amount: 0, unit: "")
    @ObservedObject var listener = Listener()
    @State private var showAlert = false


    struct Product: Identifiable, Codable, Equatable {
        var id = UUID()
        var name: String
        var amount: Double
        var unit: String
    }

    let units = ["Gram", "Kilo", "Mililiter", "Centiliter", "Deciliter", "Liter", "Msk", "Tsk", "Antal"]

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Produkt")
                        .fontWeight(.bold)
                    Spacer()
                }
                HStack {
                    TextField("Skriv dina produkter", text: $userInputProduct.name)
                }
                HStack {
                    Text("Mängd")
                        .fontWeight(.bold)
                    Spacer()
                }
                HStack {
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
                }
                Spacer()
                HStack {
                    Button(action: {
                        addProduct()
                    }) {
                        Text("Lägg till")
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Produkten finns redan"), message: Text("Produkten du försöker lägga till finns redan i skafferiet."), dismissButton: .default(Text("OK")))
                }

                .padding(.bottom) // Add some spacing between the button and the list
                List {
                    ForEach(listener.products) { product in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(product.name)
                                    .font(.headline)
                                Spacer()
                            }
                            Text("\(product.amount) \(product.unit)")
                                .foregroundColor(.secondary)
                        }
                        .contextMenu {
                            Button(action: {
                                self.removeProduct(product) { success in
                                    if success {
                                        // Handle successful deletion, if needed
                                    } else {
                                        // Handle deletion failure, if needed
                                    }
                                }
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }.onDelete(perform: deleteProduct)
                }


                .padding(.top) // Add some spacing between the list and the rest of the content
            }
            .padding() // Add padding to the entire content
            .navigationTitle("Skafferi")
            .onDisappear {
                self.listener.removeSnapshotListener()
            }
        }
        .onAppear {
            // Fetch products from Firestore
            listener.fetchProducts()
        }
    }

    class Listener: ObservableObject {
        private var db = Firestore.firestore()
         var listener: ListenerRegistration?
        @Published var products: [Product] = []


        func fetchProducts() {
            self.listener = db.collection("products").addSnapshotListener { snapshot, error in
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
            self.listener?.remove()
        }
    }

    func deleteProduct(at offsets: IndexSet) {
        for index in offsets {
            let product = listener.products[index]
            
            db.collection("products").whereField("name", isEqualTo: product.name).getDocuments { snapshot, error in
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
                                if let indexToRemove = self.listener.products.firstIndex(where: { $0.name == product.name }) {
                                    self.listener.products.remove(at: indexToRemove)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func removeProduct(_ product: Product, completion: @escaping (Bool) -> Void) {
        guard let index = listener.products.firstIndex(where: { $0.name == product.name }) else {
            completion(false)
            return
        }

        let productRef = db.collection("products").document()
        
        productRef.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                // Remove the product from the products array
                DispatchQueue.main.async {
                    self.listener.products.remove(at: index)
                    completion(true)
                }
            }
        }
    }

    func addProduct() {
        let newProduct = userInputProduct
        // Kolla om produkten redan finns
        if listener.products.contains(where: { $0.name == newProduct.name }) {
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
