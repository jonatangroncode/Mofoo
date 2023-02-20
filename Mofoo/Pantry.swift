//
//  Pantry.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-14.
//

import SwiftUI

struct Pantry: View {
    
    struct Product: Identifiable {
        let id = UUID()
        var name: String
        var amount: Int
        var unit: Int
    }
    
    let units = ["Gram", "Kilo", "Mililiter", "Centiliter", "Deciliter", "Liter", "Msk" , "Tsk", "Antal"]
    
    @State private var userInputProduct = Product (name: "", amount: 0, unit: 0)
    @State private var products = [Product]()
    
    var body: some View {
        VStack{
           
            HStack{
                Text("Produkt")
                    .fontWeight(.bold)
                Spacer()
            }
            TextField("Skriv dina produkter",
                      text: $userInputProduct.name)
            TextField("Antal", value: $userInputProduct.amount, formatter: NumberFormatter())
            Picker(selection: $userInputProduct.unit, label: Text("Enhet")) {
                ForEach(0..<units.count) {
                    Text(units[$0])
                }
            }
            List(products, id: \.id) { product in
                Text("\(product.name) \(product.amount) \(units[product.unit])")
                           
            }

            Spacer()
            Button(action: {
                products.append(userInputProduct)
                userInputProduct = Product(name: "", amount: 0, unit: 0)
            }) {
                Text("Lägg till")
            }
        }
    }
}
