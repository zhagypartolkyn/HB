
import SwiftUI

struct FollowView: View {
    @ObservedObject var viewModel: FollowViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTabBar(isFirstActive: $viewModel.isFirstActive, firstTitle: .constant(LocalizedText.profile.follow.FOLLOWINGS), secondTitle: LocalizedText.profile.follow.FOLLOWERS)
            ZStack {
                firstList
                    .zIndex(viewModel.isFirstActive ? 1 : 0)
                secondList
                    .zIndex(viewModel.isFirstActive ? 0 : 1)
            }
        }
    }
    
    // MARK: Widgets
    private var firstList: some View {
        List(0..<viewModel.followingUsers.count, id: \.self) { index in
            FollowCard(userVM: viewModel.followingUsers[index])
                .onAppear {
                    loadMoreFollowings(index)
                }
                .onTapGesture {
                    viewModel.navigateProfile?(viewModel.followingUsers[index].uid)
                }
        }
    }
    
    private var secondList: some View {
        List(0..<viewModel.followerUsers.count, id: \.self) { index in
            FollowCard(userVM: viewModel.followerUsers[index])
                .onAppear {
                    loadMoreFollowers(index)
                }
                .onTapGesture {
                    viewModel.navigateProfile?(viewModel.followerUsers[index].uid)
                }
        }
    }
    
    // Methods
    private func loadMoreFollowings(_ index: Int) {
        guard index == viewModel.followingUsers.count - 1 else { return }
        viewModel.fetchFollowings()
    }
    
    private func loadMoreFollowers(_ index: Int) {
        guard index == viewModel.followerUsers.count - 1 else { return }
        viewModel.fetchFollowers()
    }
    
}

struct FollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowView(viewModel: FollowViewModel(userVM: UserViewModel(value: userExample), isFirstActive: true))
    }
}
 
