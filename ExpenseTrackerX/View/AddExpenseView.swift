//
//  AddExpenseView.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 16/10/2023.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var date: Date = .init()
    @State private var amount: CGFloat = 0
    @State private var category: Category?
    @Query(animation: .snappy) private var allCategories: [Category]
    var body: some View {
        NavigationStack {
            List {
                Section("Title"){
                    TextField("Magic keyboard", text: $title)
                }

                Section("Description"){
                    TextField("Bought keyboard at the Apple Store", text: $subtitle)
                }

                Section("Amount Spent"){
                    HStack(spacing: 4){
                        Text("$")
                            .fontWeight(.semibold)
                        TextField("0.0",value: $amount,formatter: formatter)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Date"){
                    DatePicker("",selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                if !allCategories.isEmpty {
                    HStack {
                        Text("Category")
                        Spacer()
                        Picker("",selection: $category){
                            ForEach(allCategories) {
                                Text($0.categoryName)
                                    .tag($0)
                            }

                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem (placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem (placement: .topBarTrailing) {
                    Button("Add", action: addExpense)
                        .disabled(formHasNotValidData)

                }

            }
        }
    }

    var formHasNotValidData: Bool {
        return title.isEmpty || subtitle.isEmpty || amount == .zero
    }

    func addExpense() {
        let expense = Expense(title: title, subtitle: subtitle, amount: amount, date: date, category: category)
        context.insert(expense)
        dismiss()
    }

    var formatter: NumberFormatter {
        let  formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    AddExpenseView()
}
