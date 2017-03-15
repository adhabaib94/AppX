//JSQMessagesCollectionViewCell

import JSQMessagesViewController
import Foundation
import UIKit

class BubbleCell: JSQMessagesCollectionViewCell {
    var myLabel: UILabel!
    var myButton: UIButton!
    
    let screenSize = UIScreen.main.bounds
  
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
