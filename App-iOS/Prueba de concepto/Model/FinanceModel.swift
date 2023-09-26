//
//  FinanceModel.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation


struct Transaction: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: Date
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
