import Flow
import Foundation

public extension CoreSignal where Value == String? {
    func toInt() -> CoreSignal<Kind.DropWrite, Int?> {
        map { amount -> Int? in
            if let amount = amount, let double = Double(amount) {
                return Int(double)
            }

            return nil
        }
    }
}
