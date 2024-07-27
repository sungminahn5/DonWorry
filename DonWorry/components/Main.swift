import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0 // 0 for Spending, 1 for Income
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Spending tab
            NavigationView {
                SpendingView()
                    .navigationBarTitle("Spending")
            }
            .tabItem {
                Image(systemName: "arrow.down.to.line.alt")
                Text("Spending")
            }
            .tag(0)
            
            // Income tab
            NavigationView {
                IncomeView()
                    .navigationBarTitle("Income")
            }
            .tabItem {
                Image(systemName: "arrow.up.to.line.alt")
                Text("Income")
            }
            .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
