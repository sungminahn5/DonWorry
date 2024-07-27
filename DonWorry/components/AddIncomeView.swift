//
//  AddIncomeView.swift
//  DonWorry
//
//  Created by Sungmin Ahn on 7/25/24.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Text("Add Income Entry Form")
            .navigationBarTitle("Add Income")
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
            })
    }
}

#Preview {
    AddIncomeView()
}
