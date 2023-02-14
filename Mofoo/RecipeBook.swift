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
                    
                    NavigationLink(destination: Detail(data: rs)) {
                        Text(rs.recipe)
                    }
                }
            }
            .navigationTitle("Sök Recept")
                .searchable(text: $search)
        }
        
        
        
        
        
        
    }
}



struct Detail : View {
    
    var data : Posts
    
    var body: some View{
        
        VStack{
            Text(data.recipe)
                .font(.title)
                .fontWeight(.bold)
                .padding(10)
            Text("Ingredienser")
                .padding(10)
                .fontWeight(.bold)
            HStack{
                ForEach(data.ingredience ?? [], id: \.self) { ingredient in
                    Text(ingredient + ",") 
                }
                    
            }
            
            Text("Instruktioner")
                .padding(10)
                .fontWeight(.bold)
            Text(data.instructions)
                .padding(10)
            Button("Lägg till"){
                           
                       }
            
        }
    
           
        
    }
    
}
