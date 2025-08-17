import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    let onPageForward: () -> Void
    let onPageBackward: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Previous page button
            if currentPage > 0 {
                Button(action: onPageBackward) {
                    Image(systemName: "chevron.left")
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.white)
                        .font(.system(size: 22, weight: .bold))
                        .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                }
            }
            
            // Page dots
            ForEach(0..<totalPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            
            // Next page button
            if currentPage < totalPages - 1 {
                Button(action: onPageForward) {
                    Image(systemName: "chevron.right")
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.white)
                        .font(.system(size: 22, weight: .bold))
                        .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
}
