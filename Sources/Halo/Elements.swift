#if canImport(UIKit)
import UIKit

public extension Element {   
    static func stackView(tag: Tag = .none, style: Style = .none, axis: NSLayoutConstraint.Axis = .vertical, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 8, elements: [Element] = []) -> Element {
        return Element {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.setContentHuggingPriority(.required, for: .horizontal)
            stackView.setContentHuggingPriority(.required, for: .vertical)
            stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
            stackView.setContentCompressionResistancePriority(.required, for: .vertical)
            stackView.axis = axis
            stackView.distribution = distribution
            stackView.spacing = spacing
            stackView.add(elements: elements)
            return style.apply(tag: tag, view: stackView)
        }
    }
}

public extension UIStackView {
    
    convenience init(superview: UIView, axis: NSLayoutConstraint.Axis = .vertical, insets: UIEdgeInsets = .zero) {
        self.init(frame: .zero)
        
        self.spacing = 8 //UIStackView.spacingUseSystem
        self.axis = axis
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right)
            ])
    }
    
    func add(element: Element) {
        addArrangedSubview(element.create())
    }
    
    func add(elements: [Element]) {
        elements.forEach { add(element: $0) }
    }
    
    func insert(element: Element, at tag: Tag) {
        let pair = arrangedSubviews.enumerated().first { $0.1.tag == tag.rawValue }
        if let (stackIndex, _) = pair {
            insertArrangedSubview(element.create(), at: stackIndex)
        }
    }
    
    func replaceElement(at tag: Tag, with element: Element) {
        guard let view = get(UIView.self, tag: tag) else { return }
        insert(element: element, at: tag)
        removeArrangedSubview(view)
    }
    
    func remove(tag: Tag) {
        guard let view = get(UIView.self, tag: tag) else { return }
        removeArrangedSubview(view)
    }
    
    func removeAll() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func get<T>(_ type: T.Type, tag: Tag) -> T? where T : UIView {
        return viewWithTag(tag.rawValue) as? T
    }
    
    func show(tag: Tag) {
        guard let view = get(UIView.self, tag: tag), view.isHidden == true else { return }
        view.isHidden = false
    }
    
    func hide(tag: Tag) {
        guard let view = get(UIView.self, tag: tag), view.isHidden == false else { return }
        view.isHidden = true
    }
    
    func show(tags: [Tag]) {
        tags.forEach { show(tag: $0) }
    }
    
    func hide(tags: [Tag]) {
        tags.forEach { hide(tag: $0) }
    }
}

public extension Element {
    
    enum Position {
        case fill
        case centerX
        case centerY
        case fixedHeight(CGFloat)
        case fixedWidth(CGFloat)
        case custom((UIView, UIView, UIEdgeInsets) -> [NSLayoutConstraint])
        case append([Position])
        
        public func constrain(subview: UIView, superview: UIView, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
            switch self {
            case .fill:
                return [
                    subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                    subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
                    subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
                    subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right)
                ]
            case .centerX:
                return [
                    subview.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                    subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                    subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
                ]
            case .centerY:
                return [
                    subview.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                    subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
                    subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right)
                ]
            case let .fixedHeight(height):
                return [subview.heightAnchor.constraint(equalToConstant: height)]
            case let .fixedWidth(width):
                return [subview.widthAnchor.constraint(equalToConstant: width)]
            case let .custom(constrain):
                return constrain(subview, superview, insets)
            case let .append(positions):
                var constraints: [NSLayoutConstraint] = []
                positions.forEach { constraints += $0.constrain(subview: subview, superview: superview, insets: insets) }
                return constraints
            }
        }
    }
    
    static func custom<T: UIView>(_ type: T.Type, tag: Tag, style: Style, insets: UIEdgeInsets, position: Position, elements: [Element] = []) -> Element {
        return Element {
            let view = T()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .vertical)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .vertical)
            
            elements.forEach { element in
                let subview = element.create()
                view.addSubview(subview)
                
                NSLayoutConstraint.activate(position.constrain(subview: subview, superview: view, insets: insets))
            }
            return style.apply(tag: tag, view: view)
        }
    }
}

public extension Element {
    
    static func label(tag: Tag = .none, style: Style = .none, text: String) -> Element {
        return Element {
            let label = UILabel()
            label.text = text
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.numberOfLines = 0
            return style.apply(tag: tag, view: label)
        }
    }
    
    static func textField(tag: Tag = .none, style: Style = .none, placeholder: String? = nil, text: String? = nil) -> Element {
        return Element {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.setContentHuggingPriority(.required, for: .horizontal)
            textField.setContentHuggingPriority(.required, for: .vertical)
            textField.setContentCompressionResistancePriority(.required, for: .horizontal)
            textField.setContentCompressionResistancePriority(.required, for: .vertical)
            textField.placeholder = placeholder
            textField.text = text
            return style.apply(tag: tag, view: textField)
        }
    }
    
    static func textView(tag: Tag = .none, style: Style = .none, text: String? = nil) -> Element {
        return Element {
            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.setContentHuggingPriority(.required, for: .horizontal)
            textView.setContentHuggingPriority(.required, for: .vertical)
            textView.setContentCompressionResistancePriority(.required, for: .horizontal)
            textView.setContentCompressionResistancePriority(.required, for: .vertical)
            textView.text = text
            textView.isScrollEnabled = false
            return style.apply(tag: tag, view: textView)
        }
    }
}

public extension Element {
    
    static func button(tag: Tag = .none, style: Style = .none, title: String, image: UIImage? = nil) -> Element {
        return Element {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .vertical)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .vertical)
            button.setTitle(title, for: .normal)
            if let image = image {
                button.setImage(image, for: .normal)
            }
            return style.apply(tag: tag, view: button)
        }
    }
    
    static func segmentedControl(tag: Tag = .none, style: Style = .none, titles: [String] = []) -> Element {
        return Element {
            let segmentedControl = UISegmentedControl()
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            titles.enumerated().forEach {
                let (offset, title) = $0
                segmentedControl.insertSegment(withTitle: title, at: offset, animated: false)
            }
            return style.apply(tag: tag, view: segmentedControl)
        }
    }
    
    #if os(iOS)
    static func slider(tag: Tag = .none, style: Style = .none) -> Element {
        return Element {
            let slider = UISlider()
            slider.translatesAutoresizingMaskIntoConstraints = false
            return style.apply(tag: tag, view: slider)
        }
    }
    
    static func `switch`(tag: Tag = .none, style: Style = .none) -> Element {
        return Element {
            let `switch` = UISwitch()
            `switch`.translatesAutoresizingMaskIntoConstraints = false
            return style.apply(tag: tag, view: `switch`)
        }
    }
    #endif
}

public extension Element {
    
    static func viewController(tag: Tag = .none, style: Style = .none, viewController: UIViewController, parent: UIViewController) -> Element {
        return Element {
            parent.addChild(viewController)
            viewController.didMove(toParent: parent)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.clipsToBounds = true
            return style.apply(tag: tag, view: viewController.view)
        }
    }
}

public extension Element {
    
    static func collectionViewCell<T: UICollectionViewCell>(_ type: T.Type, tag: Tag = .none, style: Style = .none) -> Element {
        return Element {
            let collectionViewCell = T()
            collectionViewCell.translatesAutoresizingMaskIntoConstraints = false
            return style.apply(tag: tag, view: collectionViewCell)
        }
    }
}

public extension Element {
    
    static func imageView(tag: Tag = .none, style: Style = .none, image: UIImage? = nil) -> Element {
        return Element {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return style.apply(tag: tag, view: imageView)
        }
    }
    
    static func activityIndicatorView(tag: Tag = .none, style: Style = .none) -> Element {
        return Element {
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
            return style.apply(tag: tag, view: activityIndicatorView)
        }
    }
}

public extension Element {
    
    static func view(tag: Tag = .none, style: Style = .none, insets: UIEdgeInsets = .zero, position: Position = .fill, element: Element) -> Element {
        return .custom(UIView.self, tag: tag, style: style, insets: insets, position: position, elements: [element])
    }
    
    static func view(tag: Tag = .none, style: Style = .none, insets: UIEdgeInsets = .zero, position: Position = .fill, elements: [Element] = []) -> Element {
        return .custom(UIView.self, tag: tag, style: style, insets: insets, position: position, elements: elements)
    }
    
    static func control(tag: Tag = .none, style: Style = .none, insets: UIEdgeInsets = .zero, position: Position = .fill, elements: [Element] = []) -> Element {
        return .custom(UIControl.self, tag: tag, style: style, insets: insets, position: position, elements: elements)
    }
}

#endif
