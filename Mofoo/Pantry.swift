import SwiftUI


//this is the page where you can save and delete products with units and amounts, delete by draging a product to the left

struct Pantry: View {
    @ObservedObject var viewModel = PantryViewModel()

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
                    TextField("Skriv dina produkter", text: $viewModel.userInputProduct.name)
                }
                HStack {
                    Text("Mängd")
                        .fontWeight(.bold)
                    Spacer()
                }
                HStack {
                    TextField("Mängd", value: $viewModel.userInputProduct.amount, formatter: NumberFormatter())
                    Picker(selection: $viewModel.userInputProduct.unit, label: Text("Enhet")) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .onAppear {
                        viewModel.userInputProduct.unit = "Gram"  // sets the picker to gram at start
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        viewModel.addProduct()
                    }) {
                        Text("Lägg till")
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("Produkten finns redan"), message: Text("Produkten du försöker lägga till finns redan i skafferiet."), dismissButton: .default(Text("OK")))
                }

                .padding(.bottom) // Add some spacing between the button and the list
                List {
                    ForEach(viewModel.products) { product in
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
                                viewModel.removeProduct(product) { success in
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
                    }.onDelete(perform: viewModel.deleteProduct)
                }


                .padding(.top) // Add some spacing between the list and the rest of the content
            }
            .padding() // Add padding to the entire content
            .navigationTitle("Skafferi")
            .onDisappear {
                viewModel.removeSnapshotListener()
            }
        }
        .onAppear {
            // Fetch products from Firestore
            viewModel.fetchProducts()
        }
    }
}
