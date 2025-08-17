import SwiftUI

struct AppGrid: View {
    let applications: [Application]
    let selectedAppIndex: Int
    let iconSize: Double
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let gridSpacing: CGFloat
    let columnsCount: Int
    let gridFixedHeight: CGFloat
    let onAppSelected: (Application) -> Void
    let onAppTapped: (Application) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.fixed(cellWidth), spacing: gridSpacing, alignment: .top),
                    count: columnsCount
                ),
                alignment: .center,
                spacing: gridSpacing
            ) {
                ForEach(Array(applications.enumerated()), id: \.element.id) { index, app in
                    AppIconView(application: app, iconSize: iconSize)
                        .frame(width: cellWidth, height: cellHeight, alignment: .top)
                        .background(
                            Group {
                                if index == selectedAppIndex {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white.opacity(0.10))
                                }
                            }
                        )
                        .overlay(
                            Group {
                                if index == selectedAppIndex {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                }
                            }
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                        .onTapGesture { 
                            onAppTapped(app)
                        }
                        .onAppear {
                            if index == selectedAppIndex {
                                onAppSelected(app)
                            }
                        }
                }
            }
            .padding(.horizontal)
            .frame(height: gridFixedHeight, alignment: .top)
        }
        .scrollDisabled(true)
    }
}
