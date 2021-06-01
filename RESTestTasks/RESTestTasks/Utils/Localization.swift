import Foundation

func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}


enum L10n {
    
    enum error {
        static var title: String {
            localized("error.title")
        }
        
        enum message {
            static var dataErrorLoading: String {
                localized("error.message.load")
            }
            
            static var failedToConvert: String {
                localized("error.message.failedToConvert")
            }
        }
    }
    
    enum alert {
        static var cancel: String {
            localized("alert.cancel")
        }
    }
}
