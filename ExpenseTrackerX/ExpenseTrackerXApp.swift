//
//  ExpenseTrackerXApp.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 15/10/2023.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerXApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Expense.self,Category.self])
    }
}
