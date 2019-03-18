//
//  ContestDetailsViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-03-17.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import ActiveLabel
import SwiftyUserDefaults

extension DefaultsKeys {
    static let savedAnnoucement = DefaultsKey<String>("saved_announcement")
}

class AnnouncementsViewController: UIViewController {
    
    let titleString = "Foodie is holding a contest!"
    let descString = """
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
    let descLabel = ActiveLabel()
    let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildComponents()
        setupNavigation()
        setupTableView()
        
        // TODO: Network call
        
        Defaults[.savedAnnoucement] = descString
    }
    
    private func buildComponents() {
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        let detailsType = ActiveType.custom(pattern: "\\sMore contest details here\\b")
        descLabel.enabledTypes = [detailsType]
        descLabel.text = descString
        descLabel.customColor[detailsType] = UIColor.ccOchre
        descLabel.customSelectedColor[detailsType] = UIColor.ccOchre
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.font = UIFont(font: .avenirMedium, size: 14)
        
        descLabel.handleCustomTap(for: detailsType) { element in
            if let link = URL(string: "https://beafoodie.com/contestdetails.html") {
                UIApplication.shared.open(link)
            }
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = titleString
        titleLabel.font = UIFont(font: .avenirHeavy, size: 18)
        titleLabel.textAlignment = .center
        
        view.addSubview(tableView)
        view.applyAutoLayoutInsetsForAllMargins(to: tableView, with: .zero)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        navigationItem.title = "Announcements"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissVC(_:)))
    }
    
    @objc private func dismissVC(_ sender: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
    
    public static func push(_ presenting: UIViewController) {
        let announcementsVC = AnnouncementsViewController()
        let nc = UINavigationController(rootViewController: announcementsVC)
        presenting.present(nc, animated: true, completion: nil)
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
        cell.selectionStyle = .none
        
        cell.contentView.addSubview(descLabel)
        cell.contentView.addSubview(titleLabel)

        cell.contentView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -25).isActive = true
        cell.contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -10).isActive = true
        cell.contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        cell.contentView.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor, constant: -10).isActive = true
        cell.contentView.trailingAnchor.constraint(equalTo: descLabel.trailingAnchor, constant: 10).isActive = true
        cell.contentView.bottomAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 10).isActive = true

        return cell
    }
}
