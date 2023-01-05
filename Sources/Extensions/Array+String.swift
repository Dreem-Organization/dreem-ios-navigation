import Foundation

extension Array {
    func listString(with : (Element) -> String) -> String {
        var string = ""
        forEach { string = "\(string) \(with($0))," }
        return "\(string.removeLast())."
    }
}
