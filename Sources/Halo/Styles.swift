#if canImport(UIKit)
import UIKit

public extension Style {
    static func backgroundColor(_ color: UIColor) -> Style {
        return Style {
            $0.backgroundColor = color
        }
    }
    
    static func cornerRadius(_ radius: CGFloat) -> Style {
        return Style {
            $0.layer.cornerRadius = radius
            $0.layer.masksToBounds = true
        }
    }
}

public extension Style {
    static var autolayout: Style {
        return Style {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    static var autoresizing: Style {
        return Style {
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    static func width(_ constant: CGFloat) -> Style {
        return Style {
            $0.widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
    
    static func height(_ constant: CGFloat) -> Style {
        return Style {
            $0.heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
    
    static func square(_ constant: CGFloat) -> Style {
        return .concat(.width(constant), .height(constant))
    }
}

#endif
