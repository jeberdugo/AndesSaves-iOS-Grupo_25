//
//  FinanceModel.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation
import Firebase

struct ExpenseByCategory: Identifiable {
    var id = UUID()
    var category: String
    var amount: Float
}

struct Total: Identifiable {
    var id = UUID()
    var type: String
    var amount: Float
}

struct Transaction: Hashable {
var amount: Float
var category: String
var date: Timestamp
var imageUri: String
var name: String
var source: String
var transactionId: String
var type: String
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
    var documentID: String?
    var name: String
    var date: Date
    var total: Float
    var contributions: Float
    var type: Float
}


struct Income: Decodable, Identifiable {
    var id : String?
    let amount: Int
    let date: Date
    let source: String
    let user: String
}


struct Category: Codable {
    var name: String
    var user: String
}

struct CategoryWithId: Codable {
    var name: String
    var categoryId: String
}

enum TagActionType: String, Codable {
    case add
    case delete
}

struct TagAction: Codable {
    let type: TagActionType
    var name: String
    var categoryId: String
}

struct UserData: Codable {
    var balance: Float
    var email: String
    var name: String
    var phone: String
    var userId: String
}

enum ImageDeletionError: Error {
    case imageNotFound
    case deletionFailed
}

enum ImageSavingError: Error {
    case directoryCreationFailed
    case imageDataConversionFailed
}

enum ImageLoadingError: Error {
    case imageNotFound
    case imageDataConversionFailed
}

struct Prediction: Hashable {
    var predicted_expense: Float
    var month: Int
    var year: Int
}

struct News: Identifiable {
    let id = UUID()
    let headline: String
    let author: String
    let date: String
    let content: String
    let image: String
}

struct NewWithId: Codable {
    var newId: String
    var headline: String
    var author: String
    var date: String
    var content: String
    var image: String
}
