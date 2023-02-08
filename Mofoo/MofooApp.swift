//
//  MofooApp.swift
//  Mofoo
//
//  Created by Jonatan Grön on 2023-02-07.
//

import SwiftUI
import Firebase

@main



struct MofooApp: App {
    
    init(){
        FirebaseApp.configure()
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
            
       
            
        }
    }
}
