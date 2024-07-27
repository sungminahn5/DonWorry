import SwiftUI

struct SpendingView: View {
    @State private var entries: [SpendingEntry] = []
    
    var body: some View {
        NavigationView {
            List(entries) { entry in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Amount: \(entry.amount, specifier: "%.2f")")
                            .font(.headline)
                        Text("Store: \(entry.storeName)")
                        Text("Category: \(entry.category)")
                    }
                    
                    Spacer()
                    
                    // Receipt icon
                    if entry.receiptPhoto != nil {
                        Image(systemName: "receipt")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitle("Spending Entries")
            .navigationBarItems(trailing: NavigationLink(destination: AddSpendingView()) {
                Image(systemName: "plus")
            })
            .onAppear {
                loadEntries()
            }
        }
    }
    
    private func loadEntries() {
        entries = FileManagerHelper.shared.loadEntries()
    }
}

struct SpendingView_Previews: PreviewProvider {
    static var previews: some View {
        SpendingView()
    }
}
