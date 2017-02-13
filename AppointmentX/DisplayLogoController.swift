//
//  DisplayLogoController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
//
//  ViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/30/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import SwiftGifOrigin



class DisplayLogoController: UIViewController, CAAnimationDelegate{
    @IBOutlet weak var imageView: UIImageView!


    var logo = UIImage.gif(name: "logo")
    
    
    override func viewDidLoad() {

        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.perform(#selector(self.setup), with: nil, afterDelay: 0.5 )
    }
    
    
    func setup(){
        
        DispatchQueue.main.async {

            self.imageView.alpha = 0
            self.imageView.loadGif(name: "logo")
            self.imageView.animationImages = self.logo?.images
            
            var values = [CGImage]()
            for image in self.logo!.images! {
                values.append(image.cgImage!)
            }
            
            self.imageView.alpha = 0
            
            // Create animation and set SwiftGif values and duration
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.calculationMode = kCAAnimationCubic
            animation.duration = self.logo!.duration
            animation.values = values
            // Set the repeat count
            animation.repeatCount = 1
            // Other stuff
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            // Set the delegate
            animation.delegate = self
            self.imageView.layer.add(animation, forKey: "animation")
            
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.animationRepeatCount = 1
            self.imageView.animationDuration = 3
  
            self.imageView.startAnimating()
            
            self.imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 1, animations: {
                self.imageView.alpha = 1
                 self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (Bool) in
                
                
            })
            
            
        }

    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("Animation finished")
            self.imageView.image = self.logo?.images?[(self.logo?.images?.count)! - 1]
            self.perform(#selector(self.fadeOut), with: nil, afterDelay: 1)
            
        }
    }
    
    
    func fadeOut()  {
        
        self.spin(options: UIViewAnimationOptions.curveEaseIn, speed: 0.4)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.imageView.alpha = 0
            
        }) { (Bool) in
            self.performSegue(withIdentifier: "create-account", sender: nil)
            
        }

        
    }

    func spin(options: UIViewAnimationOptions, speed: Double){
        
        UIView.animate(withDuration: speed, delay: 0, options: options, animations: {
            
            let r = atan2f(Float(self.imageView.transform.b), Float(self.imageView.transform.a))
            
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Float(r + 10)))
            
        }) { (Bool) in
                self.spin(options: UIViewAnimationOptions.curveLinear, speed: speed)
            
            
        }
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    

    
}

