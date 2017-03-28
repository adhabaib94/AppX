//
//  ChatViewDetailController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/28/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit

class ChatViewDetailController: ViewControllerPannable , UIScrollViewDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var baclButton: UIButton!
    var image:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.imageView.image = image
        self.scrollView.delegate = self
    
        
        
        // Do any additional setup after loading the view.
    }
    
    // Setup Status bar to Light Skin
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
