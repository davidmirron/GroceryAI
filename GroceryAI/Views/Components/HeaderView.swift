import SwiftUI

struct HeaderView: View {
    let title: String
    var showBackButton: Bool = false
    var trailingView: AnyView? = nil
    var onBackTapped: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Text(title)
                .font(AppTheme.titleStyle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                if showBackButton {
                    Button {
                        onBackTapped?()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                
                Spacer()
                
                if let trailingView = trailingView {
                    trailingView
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal)
        .background(
            AppTheme.primaryGradient
                .edgesIgnoringSafeArea(.top)
        )
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Shopping List",
                showBackButton: true,
                trailingView: AnyView(
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                    }
                )
            )
            Spacer()
        }
    }
} 