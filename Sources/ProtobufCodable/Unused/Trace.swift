import Foundation

private let performTrace = true

func trace(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: String? = nil) {
    guard performTrace else {
        return
    }
    let f = URL(fileURLWithPath: "\(file)").lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    if let s = message {
        print("\(f)(\(line)):\(function) \(s)")
    } else {
        print("\(f)(\(line)):\(function)")
    }
}
