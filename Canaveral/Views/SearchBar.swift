import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
                .font(.title2)
            
            TextField("Search applications...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.title2)
                .foregroundColor(.white.opacity(0.5))
                .onChange(of: searchText) { _ in
                    // Reset to first page when searching
                }
                .onSubmit {
                    onSubmit()
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.2))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
