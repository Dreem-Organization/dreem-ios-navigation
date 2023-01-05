import SwiftUI

extension Binding where Value: Any {
    init(get: @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
}
