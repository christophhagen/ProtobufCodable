import Foundation

extension Optional {
    
    func unwrap(orThrow error: Error) throws -> Wrapped {
        guard let self else {
            throw error
        }
        return self
    }
}
