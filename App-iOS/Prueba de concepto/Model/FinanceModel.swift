//
//  FinanceModel.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation


struct TransactionA: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: Date
}

struct AlertItem: Identifiable, Hashable {
    var id = UUID()
    var message: String
}

struct MenuItem {
    let title: String
    let imageName: String
}

struct Account {
    let title: String
    let imageName: String
    let link: String
}

struct TagsItem {
    let title: String
    let imageName: String
}

struct WebSheetItem: Identifiable {
    let id = UUID()
    let urlString: String
}

struct Budget:Hashable {
    var name: String
    var date: String
    var percentage: String
}

struct IncomeIn:  Codable {
    let amount: Int
    let source: String
    let user: String

}

struct Transaction: Decodable, Identifiable {
    var id : String?
    

    
    struct Income: Decodable, Identifiable {
        var id : String?
        
        let _id: String?
        let amount: Int
        let date: Date
        let source: String
        let user: String

    }
    
    struct Expense: Decodable , Identifiable{
        var id : String?
        let _id: String?
        let amount: Int
        let date: Date
        let category: String
        let description: String
        let user: String
        let isRecurring: Bool
        let recurrenceType: String?
        let recurrenceEndDate: String?
    }

    let _id: String
    let income: Income?
    let expense: Expense?
    let user: String
}

struct TransactionsResponse: Decodable {
    let transactions: [Transaction]
    enum CodingKeys: String, CodingKey {
            case transactions
        }
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.transactions = try container.decode([Transaction].self, forKey: .transactions)
       }
}

struct Category: Codable {
    var name: String
    var user: String
}

struct CategoryWithId: Codable {
    var id: String
    var name: String
    var user: String
}
