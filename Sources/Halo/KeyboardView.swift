#if os(iOS)
    import UIKit
    
    public extension Element {
        
        static func keyboardView(tag: Tag = .none, style: Style = .none) -> Element {
            return Element {
                let keyboardView = KeyboardView()
                return style.apply(tag: tag, view: keyboardView)
            }
        }
    }
    
    public final class KeyboardView: UIView {
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            translatesAutoresizingMaskIntoConstraints = false
            
            NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        public override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.height = height
            return size
        }
        
        @objc private func keyboardWillChange(_ notification: NSNotification) {
            let endValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            if let endRect = endValue?.cgRectValue, let window = window {
                let visibleRect = window.convert(endRect, from: nil).intersection(window.frame)
                height = visibleRect.height
                invalidateIntrinsicContentSize()
            }
        }
        
        private var height: CGFloat = 0
    }
#endif
