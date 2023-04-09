 

import SwiftUI
import SDWebImageSwiftUI

struct ActivitiesView: View {
    @ObservedObject var viewModel: ActivitiesViewModel
    
    var body: some View {
        VStack {
            List(0..<viewModel.activityVMs.count, id: \.self) { index in
                ActivityCard(activity: viewModel.activityVMs[index])
                    .onAppear {
                        loadMore(encounteredIndex: index)
                    }
                    .onTapGesture {
                        onTap(activity: viewModel.activityVMs[index])
                    }
            }
        }
    }
    
    // Methods
    private func loadMore(encounteredIndex: Int) {
        guard encounteredIndex == viewModel.activityVMs.count - 1 else { return }
        viewModel.fetchNotifications()
    }
    
    private func onTap(activity: ActivityViewModel) {
        if activity.type == NotificationType.follow {
            viewModel.navigateProfile?(activity.author.uid)
        } else {
            viewModel.navigateRequests?(activity.wishId)
        }
    }
    
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(viewModel: ActivitiesViewModel())
    }
}
