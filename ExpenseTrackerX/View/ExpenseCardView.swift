//
//  ExpenseCardView.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 16/10/2023.
//

import SwiftUI

struct ExpenseCardView: View {
    @Bindable var expense: Expense
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(expense.title)
                Text(expense.subtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .lineLimit(1)
            Spacer(minLength: 5)
            Text(expense.currencyString)
                .font(.title3.bold())
        }
    }
}

//#Preview {
//    ExpenseCardView()
//}
