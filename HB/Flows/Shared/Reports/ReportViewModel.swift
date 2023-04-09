 

import Foundation
import FirebaseFirestore

class ReportViewModel {
    var navigateBack: (() -> Void)?
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    
    
    
    public func addReport(reportObject: ReportObject, reportContent: ReportContent) {
        let ref = Ref.Fire.reports.document()
        
        let report = Report(id: ref.documentID,
                                    report: reportContent,
                                    object: reportObject,
                                    status: ReportStatus(active: true),
                                    date: ReportDate(closed: nil, publish: Timestamp(date: Date())))
        
        DB.create(model: report, ref: ref) { (result) in
            switch result {
            case .success(_):
                self.showHUD?(.success, "Успешно отправлено")
            case .failure(let error):
                self.showHUD?(.error, error.localizedDescription)
            }
        }
    }
}
