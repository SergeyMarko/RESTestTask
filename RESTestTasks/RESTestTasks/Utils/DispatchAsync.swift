import Foundation

func dispatchAsyncSafelyToMainQueue(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
