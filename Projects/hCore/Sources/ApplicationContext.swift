import Foundation

public struct ApplicationContext {
    public static var shared = ApplicationContext()
    @ReadWriteState public var hasFinishedBootstrapping = false
}
