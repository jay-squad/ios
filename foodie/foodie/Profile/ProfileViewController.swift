//
//  ProfileViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-08.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let tableView = UITableView()
    let kProfileSummaryTableViewCellId = "ProfileSummaryTableViewCellId"
    let kProfileDishSubmissionTableViewCellId = "ProfileDishSubmissionTableViewCellId"

    var viewModel: ProfileDishSubmissionsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfile()
        setupTableView()
        setupNavigation()
        setupNibs()
        buildComponents()
    }

    private func loadProfile() {
        viewModel = ProfileDishSubmissionsViewModel(json: [], mock: true)
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

//        let rightNavBtn = UIBarButtonItem(title: "stuff",
//                                          style: .plain,
//                                          target: self,
//                                          action: #selector(onSubmitButtonTapped(_:)))
//        navigationItem.rightBarButtonItem = rightNavBtn
    }

    private func setupNibs() {
        tableView.register(ProfileSummaryTableViewCell.self,
                           forCellReuseIdentifier: kProfileSummaryTableViewCellId)
        tableView.register(ProfileDishSubmissionTableViewCell.self,
                           forCellReuseIdentifier: kProfileDishSubmissionTableViewCellId)
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSummaryTableViewCellId,
                                                        for: indexPath) as? ProfileSummaryTableViewCell {
                //            cell.configureCell
                return cell
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
