#if canImport(UIKit)
import Foundation
import UIKit

public struct Tag: RawRepresentable, Equatable {
    public typealias RawValue = Int

    public static let none = Tag(rawValue: 0)

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct Style {
    public static let none = Style(for: UIView.self) { _ in }

    public init<T: UIView>(for type: T.Type, perform: @escaping (T) -> Void) {
        self.configure = {
            guard let view = $0 as? T else { return }
            perform(view)
        }
    }

    public static func concat(_ styles: Style ...) -> Style {
        return Style(for: UIView.self) { view in
            styles.forEach { $0.configure(view) }
        }
    }

    @discardableResult
    public func apply<T: UIView>(tag: Tag = .none, view: T) -> T {
        view.tag = tag.rawValue
        configure(view)
        return view
    }

    let configure: (UIView) -> Void
}

public struct Element {
    
    public init(create: @escaping () -> UIView) {
        self.createElement = create
    }
    
    public func create<T: UIView>() -> T {
        guard let view = createElement() as? T else { return T() }
        return view
    }

    private let createElement: () -> UIView
}

#endif
