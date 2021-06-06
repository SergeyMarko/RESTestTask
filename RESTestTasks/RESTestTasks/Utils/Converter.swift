import Foundation

enum ConversetionError: Error {
    case failedToConvert(message: String = L10n.error.message.failedToConvert)
}

struct Converter {
    
    func convertToInt(for double: Double?) throws -> Int {
        guard let double = double else { throw ConversetionError.failedToConvert() }
        return Int(double)
    }
}
