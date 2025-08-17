import SwiftUI
import AppKit

struct AppIconView: View {
    let application: Application
    let iconSize: Double
    
    private var textSize: Double { max(11, iconSize * 0.16) }
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: iconSize, height: iconSize)
                    .overlay(
                        Text(String(application.name.prefix(1)))
                            .font(.system(size: textSize + 8, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            Text(application.name)
                .font(.system(size: textSize))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: iconSize + 16, height: max(11, iconSize * 0.16) * 2.2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
