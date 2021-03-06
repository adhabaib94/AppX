//
//  LeftMenuViewController.swift
//  AKSideMenuSimple
//
//  Created by Diogo Autilio on 6/7/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import UIKit

public class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let tableView: UITableView = UITableView.init(frame: CGRect(x: 0, y: (self.view.frame.size.height - 54 * 5) / 2.0, width: self.view.frame.size.width, height: 54 * 5), style: UITableViewStyle.plain)
        tableView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleWidth]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isOpaque = false
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.bounces = false

        self.tableView = tableView
        self.view.addSubview(self.tableView!)
    }

    // MARK: - <UITableViewDelegate>

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            case 0:

                self.sideMenuViewController!.hideMenuViewController()

            case 2:
                self.sideMenuViewController!.hideMenuViewController()
                DispatchQueue.main.async {
                    // POST NOTIFICATION FOR COMPLETION
                    NotificationCenter.default.post(name: Notification.Name("chatViewController"), object: nil)
                }
        case 4:
            
            self.sideMenuViewController!.hideMenuViewController()
            self.perform( #selector(LeftMenuViewController.logOut), with: nil, afterDelay: 1.0)
         
           
          

        default:
            break
        }
    }

    
    func logOut(){
        self.sideMenuViewController?.backgroundImageView?.alpha = 0
          NotificationCenter.default.post(name: Notification.Name("logOut"), object: nil)
    }
    
    // MARK: - <UITableViewDataSource>
  
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return 5
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "Cell"

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.font = UIFont.init(name: "Raleway-Regular", size: 21)
            cell!.textLabel?.textColor = UIColor.white
            cell!.textLabel?.highlightedTextColor = UIColor.lightGray
            cell!.selectedBackgroundView = UIView.init()
        }

        var titles: [String] = ["Home", "Appointments", "Inbox", "Updates", "Log Out"]
        var images: [String] = ["IconHome", "IconCalendar", "inbox_icon", "update_icon", "logout_icon"]
        cell!.textLabel?.text = titles[indexPath.row]
        cell!.imageView?.image = UIImage.init(named: images[indexPath.row])

        return cell!
    }
}
