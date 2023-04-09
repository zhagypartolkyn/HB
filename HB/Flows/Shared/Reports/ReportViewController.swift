 

import UIKit
import SwiftUI
import FirebaseFirestore

enum ReportObjectType: String {
    case wish = "wish"
    case history = "history"
    case profile = "profile"
}

enum ReportType: String, CaseIterable {
    case SPAM = "Спам"
    case HARASSMENT = "Оскорбление"
    case ADULT_CONTENT = "Материал для взрослых"
    case CHILD_PORNOGRAPHY = "Детская порнография"
    case DRUG_ADVOCACY = "Пропаганда наркотиков"
    case SELLING_WEAPONS = "Продажа оружия"
    case VIOLENCE = "Насилие"
    case ENCOURAGING_BULLYING = "Призыв к травле"
    case ENCOURAGING_SUICIDE = "Призыв к суициду"
    case ANIMAL_ABUSE = "Жестокое обращение с животными"
    case MISLEADING_INFORMATION = "Введение в заблуждение"
    case FRAUD = "Мошенничество"
    case EXTREMISM = "Экстремизм"
    case HATE_SPEECH = "Враждебные высказывания"
    case OTHER = "Другое"
}

class ReportViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: ReportViewModel
    private let mainViewController = UIHostingController(rootView: ReportView())
    private let reportObject: ReportObject
    
    // MARK: - LifeCycle
    init(viewModel: ReportViewModel, reportObject: ReportObject) {
        self.viewModel = viewModel
        self.reportObject = reportObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        mainViewBinding()
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [weak self] (type, text) in
            self?.showHUD(type: type, text: text)
            self?.viewModel.navigateBack?()
        }
    }
    
    private func mainViewBinding() {
        mainViewController.rootView.sendPressed = { [weak self] (reportType, commentText) in
            guard let self = self, let reportType = reportType else { return }
            
            self.showHUD()
            let reportContent = ReportContent(uid: DB.Helper.uid, type: reportType.rawValue, comment: commentText)
            self.viewModel.addReport(reportObject: self.reportObject, reportContent: reportContent)
        }
        
        mainViewController.rootView.closePressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.navigateBack?()
        }
    }
    
    private func setupUI() {
        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        
        mainViewController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
}
