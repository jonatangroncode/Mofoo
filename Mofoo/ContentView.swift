//
//  ContentView.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//

import SwiftUI

struct ContentView: View {
    
    var post = [Posts]()
    
    init() {
        post.append(Posts(recipe: "pannkakor"))
        post.append(Posts(recipe: "pyttipanna"))
        post.append(Posts(recipe: "kroppkakor"))

    }
    
    var body: some View {
        List(post){ entry in
            Text(entry.recipe)
            
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
