

import Foundation
import FirebaseFirestore

protocol BatchServicable {
    func newBatch() -> WriteBatch
    func performBatchOperation(operation: (WriteBatch, @escaping () -> Void) -> Void, completionHandler: (() -> Void)?)
    func performBatchOperation(operation: (WriteBatch, @escaping () -> Void) throws -> Void, completionHandler: (() -> Void)?, onError: (_ error: Error) -> Void)
}

class BatchService: BatchServicable {
    
    func newBatch() -> WriteBatch {
        Ref.Fire.root.batch()
    }
        
    func performBatchOperation(operation: (WriteBatch, @escaping () -> Void) -> Void, completionHandler: (() -> Void)?) {
        let batch = newBatch()
        operation(batch, { batch.commit { (error) in
                guard error == nil else {
                    debugPrint(error!)
                    return
                }
                completionHandler?()
            }
        })
    }
    
    func performBatchOperation(operation: (WriteBatch, @escaping () -> Void) throws -> Void, completionHandler: (() -> Void)?, onError: (_ error: Error) -> Void) {
        let batch = newBatch()
        do {
            try operation(batch, { batch.commit { (error) in
                        guard error == nil else {
                            debugPrint(error!)
                            return
                        }
                        completionHandler?()
                    }
                })
        } catch {
            onError(error)
        }
    }
}
