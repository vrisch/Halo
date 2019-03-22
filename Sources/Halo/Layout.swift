#if canImport(UIKit)
import UIKit

public enum Direction {
    case horizontal(width: CGFloat)
    case vertical(height: CGFloat)
    
    public var bounds: CGSize {
        switch self {
        case let .horizontal(width):
            return CGSize(width: width, height: .greatestFiniteMagnitude)
        case let .vertical(height):
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
    }
}

public enum Sizing {
    case intrinsic(UIView)
    case fits(Direction, UIView)
    case autolayout(Direction, UIView)
    case fix(CGSize, UIView)
    case space(CGSize)
    
    public var size: CGSize {
        switch self {
        case let .intrinsic(view):
            return view.intrinsicContentSize
        case let .fits(direction, view):
            return view.sizeThatFits(direction.bounds)
        case let .autolayout(direction, view):
            return view.systemLayoutSizeFitting(direction.bounds)
        case let .fix(size, _):
            return size
        case let .space(size):
            return size
        }
    }
    public var view: UIView? {
        switch self {
        case let .intrinsic(view):
            return view
        case let .fits(_, view):
            return view
        case let .autolayout(_, view):
            return view
        case let .fix(_, view):
            return view
        case .space:
            return nil
        }
    }
}

public indirect enum Layout {
    case element(with: Sizing, next: Layout)
    case choice(first: Layout, second: Layout)
    case `break`(next: Layout)
    case empty
}

public extension Layout {
    static var wrap: Layout {
        return .break(next: .empty)
    }
    static func intrinsic(_ view: UIView) -> Layout {
        return .element(with: .intrinsic(view), next: .empty)
    }
    static func autolayout(_ direction: Direction, _ view: UIView) -> Layout {
        return .element(with: .autolayout(direction, view), next: .empty)
    }
    static func fits(_ direction: Direction, _ view: UIView) -> Layout {
        return .element(with: .fits(direction, view), next: .empty)
    }
    static func fix(_ size: CGSize, _ view: UIView) -> Layout {
        return .element(with: .fix(size, view), next: .empty)
    }
    static func space(_ size: CGSize) -> Layout {
        return .element(with: .space(size), next: .empty)
    }
}

public extension Layout {
    func append(_ layout: Layout) -> Layout {
        switch self {
        case let .element(sizing, next):
            return .element(with: sizing, next: next.append(layout))
        case let .choice(first, second):
            return .choice(first: first.append(layout), second: second.append(layout))
        case let .break(next):
            return .break(next: next.append(layout))
        case .empty:
            return layout
        }
    }
    
    static func flow(_ layouts: Layout...) -> Layout {
        guard var result = layouts.last else { return .empty }
        layouts.dropLast().reversed().forEach { result = $0.append(result) }
        return result
    }
    
    static func stack(_ layouts: Layout...) -> Layout {
        guard var result = layouts.first else { return .empty }
        layouts.dropFirst().forEach { result = result.append(.wrap).append($0) }
        return result
    }
}

public extension Layout {
    enum Result {
        case overflows
        case fits(views: [UIView], frame: CGRect)
        
        public var views: [UIView] {
            switch self {
            case .overflows: return []
            case let .fits(views, _): return views
            }
        }
        public var frame: CGRect {
            switch self {
            case .overflows: return .zero
            case let .fits(_, frame): return frame
            }
        }
    }
    
    func compute(origin: CGPoint, direction: Direction) -> Result {
        let original = Computation(origin: origin, direction: direction, frame: .zero, views: [])
        return compute(original: original, current: original)
    }
}

private extension Layout {
    private struct Computation {
        let origin: CGPoint
        let direction: Direction
        let frame: CGRect
        let views: [UIView]
        
        enum Advancement {
            case overflows
            case next(Computation)
        }
        
        func advance(view: UIView?, frame newFrame: CGRect) -> Advancement {
            var newViews = views
            view.flatMap {
                $0.frame = newFrame
                newViews.append($0)
            }
            switch direction {
            case let .horizontal(current):
                let nextOrigin = CGPoint(x: origin.x + newFrame.size.width, y: origin.y)
                let remainder = current - newFrame.size.width
                guard remainder >= 0 else { return .overflows }
                let nextDirection = Direction.horizontal(width: remainder)
                return .next(Computation(origin: nextOrigin, direction: nextDirection, frame: frame.union(newFrame), views: newViews))
            case let .vertical(current):
                let nextOrigin = CGPoint(x: origin.x, y: origin.y + newFrame.size.height)
                let remainder = current - newFrame.size.height
                guard remainder > 0 else { return .overflows }
                let nextDirection = Direction.vertical(height: remainder)
                return .next(Computation(origin: nextOrigin, direction: nextDirection, frame: frame.union(newFrame), views: newViews))
            }
        }
        
        static func wrap(original: Computation, current: Computation) -> Computation {
            switch original.direction {
            case .horizontal:
                let nextOrigin = CGPoint(x: original.origin.x, y: original.origin.y + current.frame.height)
                return Computation(origin: nextOrigin, direction: original.direction, frame: current.frame, views: current.views)
            case .vertical:
                let nextOrigin = CGPoint(x: original.origin.x + current.frame.width, y: original.origin.y)
                return Computation(origin: nextOrigin, direction: original.direction, frame: current.frame, views: current.views)
            }
        }
    }
    
    private func compute(original: Computation, current: Computation) -> Result {
        switch self {
        case let .element(s, next):
            let frame = CGRect(origin: current.origin, size: s.size)
            guard case let .next(nextComputation) = current.advance(view: s.view, frame: frame) else { return .overflows }
            return next.compute(original: original, current: nextComputation)
        case let .choice(first, second):
            let result = first.compute(original: original, current: current)
            if case .overflows = result {
                return second.compute(original: original, current: current)
            }
            return result
        case let .break(next):
            let current = Computation.wrap(original: original, current: current)
            return next.compute(original: original, current: current)
        case .empty:
            return .fits(views: current.views, frame: current.frame)
        }
    }
}

#endif
