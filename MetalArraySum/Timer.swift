import Foundation

class Timer {
    var _start: UInt64 = 0, _end: UInt64 = 0
    func start() {
        _start = mach_absolute_time()
    }
    func end() {
        _end = mach_absolute_time()
    }
    func getDouble() -> Double {
        return Double(_end - _start) / Double(NSEC_PER_SEC)
    }
    func getString() -> String {
        return String(format: "%.9f", self.getDouble())
    }
}
