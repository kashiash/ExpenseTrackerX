//
//  CategoryView.swift
//  ExpenseTrackerX
//
//  Created by Jacek Kosinski U on 15/10/2023.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query(
       // sort: [ SortDescriptor(\Category.categoryName, order: .reverse)],
        animation:.snappy) private var allCategories: [Category]
    @Environment(\.modelContext) private var context

    @State private var newCategory: Bool = false
    @State private var categoryName: String = ""

    @Environment(\.dismiss) private var dismiss

    @State private var deleteRequest: Bool = false
    @State private var requestedCategory: Category?

    var body: some View {
      NavigationStack {
        List {
            ForEach (allCategories.sorted(by: {
                ($0.expenses?.count ?? 0) > ($1.expenses?.count ?? 0)
            })) { category in
                DisclosureGroup {
                    if let expenses = category.expenses, !expenses.isEmpty {
                        ForEach(expenses){ expense in
                            ExpenseCardView(expense: expense,displayTag: false)
                        }
                    } else {
                        ContentUnavailableView{
                            Label("No Expenses", systemImage: "tray.fill")
                        }
                    }
                } label: {
                    Text(category.categoryName)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        deleteRequest.toggle()
                        requestedCategory = category
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .overlay {
            if allCategories.isEmpty  {
                ContentUnavailableView("No Categories", systemImage: "tray.fill")
            }
        }
        .toolbar {

          ToolbarItem (placement: .topBarTrailing) {
            Button{
                newCategory.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }

          }

        }
        .sheet(isPresented: $newCategory) {
            categoryName = ""
        } content: {
            NavigationStack {
                List {
                    Section("Title") {
                        TextField("General",text: $categoryName)
                    }
                }
                .navigationTitle("CategoryName")
                .navigationBarTitleDisplayMode(.inline)
                /// Ad and Cancel buttons
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            newCategory = false
                        }
                        .tint(.red)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            let category = Category(categoryName: categoryName)
                            context.insert(category)
                            //ClosingView
                            categoryName = ""
                            newCategory = false
                        }
                        .disabled(categoryName.isEmpty)
                    }
                }
            }

            .presentationDetents([.height(180)])
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }

      }
      .alert("If you delete a category, all associated expenses will be deleted too.",isPresented: $deleteRequest) {
          Button(role: .destructive) {
            /// Deleting category
              if let requestedCategory {
                  context.delete(requestedCategory)
                  self.requestedCategory = nil
              }
          } label: {
              Text("Delete")
          }

          Button(role: .cancel) {
              requestedCategory = nil
          } label: {
              Text("Cancel")
          }
      }
    }


}

#Preview {
    CategoriesView()
}
