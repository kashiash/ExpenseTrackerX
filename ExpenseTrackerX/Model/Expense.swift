//
//  Excpense.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 15/10/2023.
//

import Foundation
import SwiftData

@Model
class Expense {
    var title: String
    var subtitle: String
    var amount: Double
    var date: Date

    var category: Category?

    init(title: String, subtitle: String, amount: Double, date: Date, category: Category? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.date = date
        self.category = category
    }
}
