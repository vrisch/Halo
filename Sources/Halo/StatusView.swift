#if os(iOS)
    import UIKit
    
    public extension Element {
        
        static func statusView(tag: Tag = .none, style: Style = .none) -> Element {
            return Element {
                let statusView = StatusView()
                return style.apply(tag: tag, view: statusView)
            }
        }
    }
    
    public final class StatusView: UIView {
        
        public required init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            backgroundColor = .white
            
            let height = heightAnchor.constraint(equalToConstant: 20)
            height.priority = UILayoutPriority(rawValue: 999)
            height.isActive = true
        }
        
        public required convenience init?(coder aDecoder: NSCoder) {
            fatalError()
        }
    }
#endif
