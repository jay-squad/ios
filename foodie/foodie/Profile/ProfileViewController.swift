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
import Crashlytics
import GradientLoadingBar

class ProfileViewController: UIViewController {

    let tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    let kProfileSummaryTableViewCellId = "ProfileSummaryTableViewCellId"
    let kProfileSubmissionTableViewCellId = "ProfileSubmissionTableViewCellId"
    let kProfileNeedsAuthTableViewCellId = "ProfileNeedsAuthTableViewCellId"

    var profileModel: Profile?
    var viewModel: ProfileSubmissionsViewModel?
    var rightNavBtn: UIBarButtonItem?
    
    var viewLoadAccessTokenDidChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNibs()
        buildComponents()
        setupNavigation()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil, queue: OperationQueue.main) { _ in
            self.viewLoadAccessTokenDidChange = true
            self.updateAuthState()
            
            #if DEBUG
//            NetworkManager.shared.grantAdminCookie()
            #endif
            
            self.loadProfileIfNeeded {
                GradientLoadingBar.shared.hide()
            }
            self.setupNavigation()
            
            if FBSDKAccessToken.currentAccessTokenIsActive() {
                Answers.logSignUp(withMethod: AnswersKeys.profile_signup_method_facebook, success: true, customAttributes: nil)
            } else {
                Answers.logSignUp(withMethod: AnswersKeys.profile_signup_method_facebook, success: false, customAttributes: nil)
            }
        }
        
        GradientLoadingBar.shared.show()
        NetworkManager.shared.refreshAuthToken { (_) in
            if !self.viewLoadAccessTokenDidChange {
                GradientLoadingBar.shared.hide()
            }
        }
    }

    private func updateAuthState() {
        if FBSDKAccessToken.current() != nil {
            NetworkManager.shared.setAuthedState()
        } else {
            NetworkManager.shared.setUnAuthedState()
        }
    }
    
    private func loadProfileIfNeeded(completion: @escaping(() -> Void)) {
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            NetworkManager.shared.getProfileSelf { (json, _, _) in
                if let json = json {
                    self.profileModel = Profile(json: json)
                    self.viewModel = ProfileSubmissionsViewModel(profile: self.profileModel)
                    self.tableView.reloadData()
                }
                completion()
            }
        } else {
            viewModel = nil
            self.tableView.reloadData()
            completion()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        loadProfileIfNeeded {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()

        navigationItem.title = "Profile"
        
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            rightNavBtn = UIBarButtonItem(image: UIImage(named: "btn_more"), style: .plain, target: self, action: #selector(onMoreButtonTapped(_:)))
            navigationItem.rightBarButtonItem = rightNavBtn
            navigationController?.navigationBar.isHidden = false
        } else {
            navigationController?.navigationBar.isHidden = true
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
        tableView.register(ProfileSubmissionTableViewCell.self,
                           forCellReuseIdentifier: kProfileSubmissionTableViewCellId)
        tableView.register(ProfileNeedsAuthTableViewCell.self,
                           forCellReuseIdentifier: kProfileNeedsAuthTableViewCellId)
    }

    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view.safeAreaLayoutGuide, with: .zero)
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if FBSDKAccessToken.currentAccessTokenIsActive() {
                if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSummaryTableViewCellId,
                                                            for: indexPath) as? ProfileSummaryTableViewCell {
                    if let profileModel = profileModel {
                        cell.configureCell(profileModel: profileModel)
                    }
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileNeedsAuthTableViewCellId,
                                                            for: indexPath) as? ProfileNeedsAuthTableViewCell {
                    cell.configureCell(navigationBar: self.navigationController?.navigationBar, tabBar: self.tabBarController?.tabBar)
                    return cell
                }
            }
        default:
            guard let viewModel = viewModel else { return UITableViewCell() }

            if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSubmissionTableViewCellId,
                                                        for: indexPath) as? ProfileSubmissionTableViewCell {
                cell.delegate = self
                cell.configureCell(submission: getSubmissionFor(indexPath: indexPath))
                return cell
            }
        }

        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = viewModel else { return 1 }

        return 1 + viewModel.sectionedSubmissions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 1 }

        switch section {
        case 0:
            return 1
        default:
            return viewModel.sectionedSubmissions[section-1].count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModel = viewModel else { return nil }
        
        switch section {
        case 0:
            return nil
        default:
            if viewModel.sectionedSubmissions.count > section-1 && viewModel.sectionedSubmissions[section-1].count > 0 {
                return DateFormatter.friendlyStringForDate(date: viewModel.dateOf(viewModel.sectionedSubmissions[section-1][0]))
            }
            return nil
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let retrievedSubmission = getSubmissionFor(indexPath: indexPath)
        guard let submission = retrievedSubmission else { return; }
        
        if let restaurant = submission.restaurant {
            DishDetailViewController.push(self.navigationController, submission.dish, restaurant)
        } else {
            if let restaurantId = submission.getRestaurantId() {
                NetworkManager.shared.getRestaurant(restaurantId: restaurantId) { (json, _, _) in
                    if let restaurantJSON = json {
                        DishDetailViewController.push(self.navigationController, submission.dish, Restaurant(json: restaurantJSON))
                    }
                }
            }
        }
    }
    
    private func getSubmissionFor(indexPath: IndexPath) -> Submission? {
        return viewModel?.sectionedSubmissions[indexPath.section-1][indexPath.row]
    }
}

extension ProfileViewController: ProfileSubmissionTableViewCellDelegate {
    func onResubmitButtonTapped(submission: Submission?) {
        if let submission = submission {
            let vc = UploadViewController()
            if let restaurantId = submission.getRestaurantId() {
                vc.restaurantId = restaurantId
                
                NetworkManager.shared.getRestaurantMenu(restaurantId: restaurantId) { (json, _, _) in
                    if let menuJSONs = json {
                        vc.prepopulate(submission)
                        vc.restaurantMenu = Menu(json: menuJSONs)
                        let nc = UINavigationController(rootViewController: vc)
                        vc.addDismissButton()
                        
                        self.present(nc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
