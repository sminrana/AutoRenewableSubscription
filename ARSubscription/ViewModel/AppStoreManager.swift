//
//  AppStoreManager.swift
//  ARSubscription
//
//  Created by Smin Rana on 2/1/22.
//

import SwiftUI
import StoreKit
import Combine

class AppStoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @Published var products = [SKProduct]()
    
    override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    func getProdcut(indetifiers: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(indetifiers))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response")
                
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.products.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    // Transaction
    
    @Published var transactionState: SKPaymentTransactionState?
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    struct PaymentReceiptResponseModel: Codable {
        var status: Int
        var email: String?
        var password: String?
        var message: String?
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                self.transactionState = .purchasing
            case .purchased:
                print("===============Purchased================")
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                    FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

                    do {
                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                        let receiptString = receiptData.base64EncodedString(options: [])
                        
                        // TODO: Send your receiptString to the server and verify with Apple
                        // receiptString should be sent to server as JSON
                        // {
                        //    "receipt" : receiptString
                        // }
                        
                        self.transactionState = .purchased // only if server sends successful response
                    }
                    catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
                }
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)

                queue.finishTransaction(transaction)
                print("==================RESTORED State=============")
                self.transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                self.transactionState = .failed
            default:
                print(">>>> something else")
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("===============Restored================")
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                
                // TODO: Send your receiptString to the server and verify with Apple
                // receiptString should be sent to server as JSON
                // {
                //    "receipt" : receiptString
                // }
                
                
                self.transactionState = .purchased // only if server sends successful response
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
    func restorePurchase() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

