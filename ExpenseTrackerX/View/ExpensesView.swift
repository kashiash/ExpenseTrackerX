//
//  ExpensesView.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 15/10/2023.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {

    @Binding var currentTab: String
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ],animation:.snappy) private var allExpenses: [Expense]

    @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var originalGroupedExpenses: [GroupedExpenses] = []
    @State private var addExpense: Bool = false
    @State private var searchText: String = ""
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                ForEach($groupedExpenses) { $group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            /// Card View
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    /// Delete Button
                                    Button {
                                        /// Deleting Data
                                        context.delete(expense)
                                        withAnimation {
                                            group.expenses.removeAll(where: { $0.id == expense.id })
                                            /// Removing Group, if no expenses present
                                            if group.expenses.isEmpty {
                                                groupedExpenses.removeAll(where: { $0.id == group.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText,placement: .navigationBarDrawer, prompt: Text("Search"))
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView("No Expenses", systemImage: "tray.fill")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .onChange(of: searchText, initial: true ) { oldValue, newValue in
            if !newValue.isEmpty {
                filterExpenses(newValue)
            } else {
                groupedExpenses = originalGroupedExpenses
            }
        }
        .onChange(of: allExpenses,initial: true) { oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" {
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addExpense){
            AddExpenseView()
                .interactiveDismissDisabled()
        }
    }

    func filterExpenses(_ text: String ) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = originalGroupedExpenses.compactMap { group -> GroupedExpenses? in
                let expenses = group.expenses.filter({$0.title.lowercased().contains(query)})
                if expenses.isEmpty {
                    return nil
                }
                return .init(date: group.date, expenses:expenses)

            }
            await  MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }

    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached (priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponents = Calendar.current.dateComponents([.day,.month,.year], from: expense.date)
                return dateComponents
            }
            ///Sorting dictionary in descending ortder
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()

                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }

            /// Adding to grouped array
            /// UI must be updated on Main Thread
            ///
            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)

                })
                originalGroupedExpenses = groupedExpenses
            }
        }
    }
}

#Preview {
    ContentView()
}
