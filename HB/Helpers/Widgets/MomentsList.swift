 

import SwiftUI
import SwiftUIX

struct MomentsList: View {
    let geometry: GeometryProxy
    let fullHistoryViewModel: FullHistoryViewModel
    
    var body: some View {
        let height = (geometry.size.width / 2) * 1.6
        let width = geometry.size.width / 2
        
        var numberOfRow = fullHistoryViewModel.historyVMs.count / 2
        let isOdd = fullHistoryViewModel.historyVMs.count % 2 == 1
        let isShowLastOneHistory = !fullHistoryViewModel.canLoadMore && isOdd
        if isShowLastOneHistory {
            numberOfRow += 1
        }
        
        
        
        return Text("This Section under construction")
            .listSeparatorStyle(.none)
//        .onRefresh {
//            fullHistoryViewModel.isRefreshing = true
//            fullHistoryViewModel.resetAndFetch()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                fullHistoryViewModel.isRefreshing = false
//            }
//        }
//        .isRefreshing(fullHistoryViewModel.isRefreshing)
    }
    
    // MARK: Methods
    private func loadMoreMoments(_ index: Int) {
        guard index == fullHistoryViewModel.historyVMs.count - 1 else { return }
        fullHistoryViewModel.fetchHistories()
    }
    
    private func onTap(_ index: Int) {
        fullHistoryViewModel.navigateHistory?(IndexPath(row: index, section: 0))
    }
    
}

//struct MomentsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MomentsListView(geometry: GeometryProxy(), fullHistoryViewModel: FullHistoryViewModel())
//    }
//}
