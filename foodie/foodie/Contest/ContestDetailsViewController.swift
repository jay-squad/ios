//
//  ContestDetailsViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-03-17.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import ActiveLabel

class AnnouncementsViewController: UIViewController {

    let text = """
    For the next X weeks, the 3 top scorers on the app will be rewarded with a prize at the end of every round.
    
    Note: this contest is only available if you are a student at the University of Waterloo and reside in the Region of Waterloo.
    
    You are automatically entered into the contest once you create an account! You can earn points by submitting dishes and getting them approved.
    
    The date & time of the end of the current round can be seen in your profile.
    
    The rewards are:
    1st place: $30 Amazon gift card
    2nd place: $15 Amazon gift card
    3rd place: $5 Amazon gift card
    
    If you’re a winner,
    the rewards will be available in your profile until the end of the following round.
    
    You can view this infomation again in the more section of your profile.
    
    More contest details here.
    """
    
    let tableView = UITableView()
    let label = ActiveLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildComponents()
    }
    
    private func buildComponents() {
        label.translatesAutoresizingMaskIntoConstraints = false
        let detailsType = ActiveType.custom(pattern: "\\sMore contest details here.\\b")
        label.enabledTypes = [detailsType]
        label.text = text
        label.customColor[detailsType] = UIColor.ccOchre
        label.customSelectedColor[detailsType] = UIColor.ccOchre
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(font: .avenirMedium, size: 14)
        
        label.handleCustomTap(for: detailsType) { element in
            if let link = URL(string: "https://beafoodie.com/contestdetails.html") {
                UIApplication.shared.open(link)
            }
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.applyAutoLayoutInsetsForAllMargins(to: tableView, with: .zero)
    }
}

extension AnnouncementsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(label)
        cell.contentView.applyAutoLayoutInsetsForAllMargins(to: label, with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        return cell
    }
}
