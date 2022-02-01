//
//  ContentView.swift
//  ARSubscription
//
//  Created by Smin Rana on 2/1/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var appStoreViewModel: AppStoreManager
    
    var body: some View {
        NavigationView {
            if self.appStoreViewModel.products.count > 0 {
                VStack {
                    Section {
                        Text("Auto Renewable")
                            .font(.headline)
                    }
                    
                    Form {
                            Text("Sign Up for \(self.appStoreViewModel.products[0].localizedTitle) - \(self.appStoreViewModel.products[0].price ?? 0.0)/yearly")
                                .font(.headline)
                            Text("Get all levels")
                                
                            Section {
                                Button(action: self.purchaseProduct, label: {
                                    Text("Subscribe")
                                })
                                Button(action: self.restorePurchase, label: {
                                    Text("Already Subscribed?")
                                })
                            }
                    }
                }
                .onReceive(appStoreViewModel.$transactionState, perform: { st in
                    if let state = st {
                        if state == .purchased {
                            print(">>>>> purchase or restored completed >>>>>")
                            // Update your view here
                        }
                    }
                })
                
            } else {
                Text("Loading...")
                    .font(.headline)
            }
        }
        .navigationViewStyle(.automatic)
        .onAppear(perform: self.loadProducts)
    }
    
    func loadProducts() {
        self.appStoreViewModel.getProdcut(indetifiers: ["com.sminrana.ar.product1"])
    }
    
    func purchaseProduct() {
        self.appStoreViewModel.purchaseProduct(product: self.appStoreViewModel.products[0])
    }
    
    func restorePurchase() {
        self.appStoreViewModel.restorePurchase()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
