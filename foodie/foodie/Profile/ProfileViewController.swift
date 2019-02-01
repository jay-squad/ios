//
//  ProfileViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-08.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    let tableView = UITableView()
    let kProfileSummaryTableViewCellId = "ProfileSummaryTableViewCellId"
    let kProfileDishSubmissionTableViewCellId = "ProfileDishSubmissionTableViewCellId"
    let kProfileNeedsAuthTableViewCellId = "ProfileNeedsAuthTableViewCellId"

    var viewModel: ProfileDishSubmissionsViewModel?
    var rightNavBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfileIfNeeded()
        setupTableView()
        setupNavigation()
        setupNibs()
        buildComponents()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil, queue: OperationQueue.main) { _ in
            if FBSDKAccessToken.current() != nil {
                NetworkManager.shared.setAuthedState()
            } else {
                NetworkManager.shared.setUnAuthedState()
            }
            self.loadProfileIfNeeded()
            self.setupNavigation()
            self.tableView.reloadData()
        }
    }

    private func loadProfileIfNeeded() {
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            viewModel = ProfileDishSubmissionsViewModel(json: [], mock: true)
        } else {
            viewModel = nil
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }

    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()

        navigationItem.title = "Profile"
        
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            rightNavBtn = UIBarButtonItem(image: UIImage(named: "btn_more"), style: .plain, target: self, action: #selector(onMoreButtonTapped(_:)))
            navigationItem.rightBarButtonItem = rightNavBtn
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func onMoreButtonTapped(_ sender: UIBarButtonItem?) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let change = UIAlertAction(title: "Logout", style: .destructive) { _ in
            FBSDKLoginManager().logOut()
        }
        actionController.addAction(cancel)
        actionController.addAction(change)
        
        self.present(actionController, animated: true, completion: nil)
    }

    private func setupNibs() {
        tableView.register(ProfileSummaryTableViewCell.self,
                           forCellReuseIdentifier: kProfileSummaryTableViewCellId)
        tableView.register(ProfileDishSubmissionTableViewCell.self,
                           forCellReuseIdentifier: kProfileDishSubmissionTableViewCellId)
        tableView.register(ProfileNeedsAuthTableViewCell.self,
                           forCellReuseIdentifier: kProfileNeedsAuthTableViewCellId)
    }

    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if FBSDKAccessToken.currentAccessTokenIsActive() {
                if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSummaryTableViewCellId,
                                                            for: indexPath) as? ProfileSummaryTableViewCell {
                    //            cell.configureCell
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileNeedsAuthTableViewCellId,
                                                            for: indexPath) as? ProfileNeedsAuthTableViewCell {
                    //            cell.configureCell
                    return cell
                }
            }
        default:
            guard let viewModel = viewModel else { return UITableViewCell() }

            if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileDishSubmissionTableViewCellId,
                                                        for: indexPath) as? ProfileDishSubmissionTableViewCell {
                cell.configureCell(profileDish: viewModel.sectionedDishes[indexPath.section-1][indexPath.row])
                return cell
            }
        }

        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = viewModel else { return 1 }

        return 1 + viewModel.sectionedDishes.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 1 }

        switch section {
        case 0:
            return 1
        default:
            return viewModel.sectionedDishes[section-1].count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModel = viewModel else { return nil }
        
        switch section {
        case 0:
            return nil
        default:
            return DateFormatter.friendlyStringForDate(date: viewModel.sectionedDishes[section-1][0].date)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 64
        }
    }
}
