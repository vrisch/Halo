#if canImport(UIKit)
import UIKit

public extension Style {
    public static func backgroundColor(_ color: UIColor) -> Style {
        return Style {
            $0.backgroundColor = color
        }
    }
    
    public static func cornerRadius(_ radius: CGFloat) -> Style {
        return Style {
            $0.layer.cornerRadius = radius
            $0.layer.masksToBounds = true
        }
    }
}

public extension Style {
    public static var autolayout: Style {
        return Style {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    public static var autoresizing: Style {
        return Style {
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    public static func width(_ constant: CGFloat) -> Style {
        return Style {
            $0.widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }

    public static func height(_ constant: CGFloat) -> Style {
        return Style {
            $0.heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }

    public static func square(_ constant: CGFloat) -> Style {
        return .concat(.width(constant), .height(constant))
    }
}

#endif
