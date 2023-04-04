import Foundation
import WeakRef

public protocol INC_TickTimerObserver: AnyObject {
    func tickTimerFired()
}

open class INC_TickTimer {
    private static var observers = NSPointerArray.weakObjects()
    private static var timer: Timer?

    public class func addObserver(_ observer: INC_TickTimerObserver) {
        observers.compact()

        for index in 0..<observers.count {
            if observer === observers.object(at: index) {
                return
            }
        }

        observers.addObject(observer)

        if timer == nil {
            timer = Timer.init(timeInterval: 1, target: self, selector: #selector(tickAction), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }
    }

    public class func removeObserver(_ observer: INC_TickTimerObserver) {
        observers.compact()
        for index in 0..<observers.count {
            if observer === observers.object(at: index) {
                observers.removeObject(at: index)
                break
            }
        }
        if observers.count == 0, let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    @objc class func tickAction() {
        observers.compact()
        let count = observers.count
        for index in 0..<count {
            if index < observers.count, let observer = observers.object(at: index) as? INC_TickTimerObserver {
                observer.tickTimerFired()
            }
        }
    }
}
