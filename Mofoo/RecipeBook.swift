//
//  RecipeBook.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-11.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecipeBook: View {
    
    @State var search = ""
    
    @ObservedObject var data = getData()
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(self.data.datas.filter{(self.search.isEmpty ? true : $0.recipe.localizedCaseInsensitiveContains(self.search))}, id: \.id) { rs in
                    Text(rs.recipe)
                    
                }
            }
            .navigationTitle("Sök Recept")
                .searchable(text: $search)
        }
        
    }
}

struct RecipeBook_Previews: PreviewProvider {
    static var previews: some View {
        RecipeBook()
    }
}
