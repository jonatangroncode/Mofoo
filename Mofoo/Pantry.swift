//
//  Pantry.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-14.
//

import SwiftUI

struct Pantry: View {
    
    @State var userInputProduct: String = ""
    
    var body: some View {
        VStack{
            List{
                
            }
            HStack{
                Text("Produkt")
                    .fontWeight(.bold)
                Spacer()
            }
            TextField("Skriv dina produkt",
                text: $userInputProduct)
        }
        
    }
}

struct Pantry_Previews: PreviewProvider {
    static var previews: some View {
        Pantry()
    }
}
