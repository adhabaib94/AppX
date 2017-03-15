

class TMNavigationBar: UINavigationBar {
    
    
    // Custom Client Data
    var current_client = Client()
    
    ///The height you want your navigation bar to be of
    static let navigationBarHeight: CGFloat = 70
    
    ///The difference between new height and default height
    static let heightIncrease:CGFloat = navigationBarHeight - 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        let shift = TMNavigationBar.heightIncrease/2
        
        ///Transform all view to shift upward for [shift] point
        self.transform =
            CGAffineTransform(translationX: 0, y: -shift)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shift = TMNavigationBar.heightIncrease/2
        
        ///Move the background down for [shift] point
        if #available(iOS 10.0, *) {
            
            let classNamesToReposition = ["_UIBarBackground"]
            
            for view: UIView in self.subviews {
                
                if classNamesToReposition.contains(NSStringFromClass(view.classForCoder)) {
                    let bounds: CGRect = self.bounds
                    var frame: CGRect = view.frame
                    frame.origin.y = bounds.origin.y + shift - 20.0
                    frame.size.height = bounds.size.height + 20.0
                    view.frame = frame
                }
            }
            
            
        }
        else{
            let classNamesToReposition = ["_UINavigationBarBackground"]
            
            for view: UIView in self.subviews {
                
                if classNamesToReposition.contains(NSStringFromClass(view.classForCoder)) {
                    let bounds: CGRect = self.bounds
                    var frame: CGRect = view.frame
                    frame.origin.y = bounds.origin.y + shift - 20.0
                    frame.size.height = bounds.size.height + 20.0
                    view.frame = frame
                }
            }
            
            
            
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let amendedSize:CGSize = super.sizeThatFits(size)
        let newSize:CGSize = CGSize(width: amendedSize.width, height: TMNavigationBar.navigationBarHeight)
        return newSize;
    }
}
