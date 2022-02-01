//
//  ARSubscriptionApp.swift
//  ARSubscription
//
//  Created by Smin Rana on 2/1/22.
//

import SwiftUI

@main
struct ARSubscriptionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(AppStoreManager())
        }
    }
}
