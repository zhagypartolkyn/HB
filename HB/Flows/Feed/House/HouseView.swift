

import SwiftUI
import SwiftUIX
import SDWebImageSwiftUI

struct HouseView: View {
    @ObservedObject var viewModel: HouseViewModel
    @ObservedObject var fullHistoryViewModel: FullHistoryViewModel
    @ObservedObject var wishDetailViewModel: WishDetailViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HomeTabBar(isFirstActive: $viewModel.isCity, firstTitle: $viewModel.cityText, secondTitle: "Моменты")
                ZStack {
                    // Wishes list
                    VStack {
                        if viewModel.isNoWishes {
                            EmptyErrorView(title: "В этом городе\nпока нет желаний")
                        } else {
                            cityWishList(geometry)
                        }
                    }
                    .zIndex(viewModel.isCity ? 1 : 0)
                    .background(Color(UIColor.appColor(.backgroundSecondary)))
                    
                    // Moments list
                    VStack {
                        if fullHistoryViewModel.isNoHistories {
                            EmptyErrorView(title: "В этом городе\nпока нет моментов")
                        } else {
                            MomentsList(geometry: geometry, fullHistoryViewModel: fullHistoryViewModel)
                        }
                    }
                    .zIndex(viewModel.isCity ? 0 : 1)
                    .background(Color(UIColor.appColor(.backgroundSecondary)))
                }
            }
        }
    }
    
    // MARK: Widgets
    private func cityWishList(_ geometry: GeometryProxy) -> some View {
        let height = geometry.size.width * 0.7
        let width = geometry.size.width - 16 * 4
        
        return CocoaList(viewModel.wishVMs) { wishVM in
            WishCard(wishVM: wishVM, imageHeight: height, textWidth: width, viewModel: viewModel)
                .onAppear {
                    self.loadMoreWish(wishVM)
                }
                .onTapGesture {
                    viewModel.navigateWish?(wishVM, nil)
                }
        }
        .contentInsets(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
        .listSeparatorStyle(.none)
        .onRefresh {
            viewModel.isRefreshing = true
            viewModel.resetFetchWish()
            viewModel.fetchWishes()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.isRefreshing = false
            }
        }
        .isRefreshing(viewModel.isRefreshing)
    }
    
    // MARK: Methods
    private func loadMoreWish(_ wishVM: WishViewModel) {
        guard wishVM == viewModel.wishVMs.last else { return }
        viewModel.fetchWishes()
    }
    
}

struct HouseView_Previews: PreviewProvider {
    static var previews: some View {
        HouseView(
            viewModel: HouseViewModel(),
            fullHistoryViewModel: FullHistoryViewModel(query: Queries.User.recommend(limit: 5)),
            wishDetailViewModel: WishDetailViewModel())
    }
}
