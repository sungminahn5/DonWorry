//
//  IncomeView.swift
//  DonWorry
//
//  Created by Sungmin Ahn on 7/25/24.
//

import SwiftUI

struct IncomeView: View {
    var body: some View {
        VStack {
            List {
                // Example list of income entries (replace with actual data)
                Text("Income Entry 1")
                Text("Income Entry 2")
                Text("Income Entry 3")
            }
            .listStyle(InsetGroupedListStyle())
            
            // Button to add a new income entry
            NavigationLink(destination: AddIncomeView()) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Income Entry")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}
#Preview {
    IncomeView()
}
