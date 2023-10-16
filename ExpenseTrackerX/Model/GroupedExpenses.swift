//
//  GroupedExpense.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 16/10/2023.
//

import Foundation
struct GroupedExpenses: Identifiable {
    var id:UUID = .init()
    var date: Date
    var expenses: [Expense]
}
