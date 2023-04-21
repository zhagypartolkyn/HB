 

import UIKit
import SkeletonView

enum GenericTableType {
    case room
}

class GenericTableView<T, Cell: UITableViewCell, SkeletonCell: UITableViewCell>:
    UITableView, UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    
    var items: [T] = []
    var configure: (Cell, T) -> Void
    var selectHandler: (T) -> Void
    var skeletonCell: SkeletonCell.Type
    var refresher: UIRefreshControl?
    var loadMore: () -> Void
    
    var type: GenericTableType?
    var edit: ((T) -> Void)?
    
    init(items: [T],
         configure: @escaping (Cell, T) -> Void,
         selectHandler: @escaping (T) -> Void,
         skeletonCell: SkeletonCell.Type,
         refresher: UIRefreshControl? = nil,
         loadMore: @escaping () -> Void,
         type: GenericTableType? = nil,
         edit: ((T) -> Void)? = nil) {
        
        self.items = items
        self.configure = configure
        self.selectHandler = selectHandler
        self.skeletonCell = skeletonCell
        self.loadMore = loadMore
        self.type = type
        self.edit = edit
        super.init(frame: .zero, style: .plain)
        
        register(Cell.self, forCellReuseIdentifier: Cell.cellIdentifier())
        register(skeletonCell.self, forCellReuseIdentifier: skeletonCell.cellIdentifier())
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isSkeletonable = true
        
        switch type {
        case .room: allowsMultipleSelectionDuringEditing = true
        case .none: allowsMultipleSelectionDuringEditing = false
        }
        
        if let refresher = refresher {
            refreshControl = refresher
        }
        
        backgroundColor = UIColor.appColor(.backgroundSecondary)
        rowHeight = UITableView.automaticDimension
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Public Methods
    func update(items: [T]) {
        self.items = items
        self.reloadData()
    }
    
    func showSkeleton(_ status: Bool) {
        if status {
            showSkeleton()
        } else {
            hideSkeleton()
        }
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.cellIdentifier()) as! Cell
        let item = items[indexPath.row]
        configure(cell, item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        selectHandler(item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroollViewHeight = scrollView.frame.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < scroollViewHeight {
            loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch type{
        case .room: return true
        case .none: return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        (edit ?? editIfNil)(item)
    }
    
    // MARK: - Skeleton
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        skeletonCell.cellIdentifier()
    }
    
    private func editIfNil(_: T) {
        
    }
}
