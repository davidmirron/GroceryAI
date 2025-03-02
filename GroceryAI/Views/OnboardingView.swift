import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        TabView {
            onboardingPage(
                title: "Smart Lists",
                description: "Your grocery lists automatically organize by category as you add items.",
                imageName: "list.bullet.clipboard",
                color: AppTheme.primary
            )
            
            onboardingPage(
                title: "Favorites & Quantity",
                description: "Swipe left to delete, swipe right to favorite, and adjust quantities with + and - buttons.",
                imageName: "star",
                color: AppTheme.primary
            )
            
            onboardingPage(
                title: "Recipe Suggestions",
                description: "Discover recipes you can make with what's already on your list.",
                imageName: "fork.knife",
                color: AppTheme.primary
            )
            
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 100))
                    .foregroundColor(AppTheme.primary)
                
                Text("You're all set!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Start adding items to your grocery list and enjoy a smarter shopping experience.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    showOnboarding = false
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 5)
                }
                .padding(.top, 30)
            }
            .padding()
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
    private func onboardingPage(title: String, description: String, imageName: String, color: Color) -> some View {
        VStack(spacing: 30) {
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(color)
                .padding(.top, 20)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
                .foregroundColor(AppTheme.text)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
        .background(AppTheme.background)
    }
} 