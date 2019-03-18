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
    let kProfileContestTableViewCellId = "ProfileContestTableViewCellId"

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
            self.enableRefreshControlIfAuthed()
            
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
                    
                    if let profileModel = self.profileModel, profileModel.shouldShowConfetti {
                        profileModel.shouldShowConfetti = false
                        
                        let confettiView = SAConfettiView(frame: self.view.bounds)
                        confettiView.intensity = 0.75
                        confettiView.isUserInteractionEnabled = false
                        self.view.addSubview(confettiView)
                        confettiView.alpha = 0
                        confettiView.startConfetti()
                        UIView.animate(withDuration: 1, animations: {
                            confettiView.alpha = 1
                        }, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            confettiView.stopConfetti()
                            UIView.animate(withDuration: 5, animations: {
                                confettiView.alpha = 0
                            }, completion: { _ in
                                confettiView.removeFromSuperview()
                            })
                        }
                    }
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
        enableRefreshControlIfAuthed()
    }
    
    private func enableRefreshControlIfAuthed() {
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            tableView.refreshControl = refreshControl
        } else {
            tableView.refreshControl = nil
        }
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
        let logout = UIAlertAction(title: "Logout", style: .destructive) { _ in
            FBSDKLoginManager().logOut()
        }
        let attributions = UIAlertAction(title: "Attributions", style: .default) { _ in
            let vc = AttributionsViewController()
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        }
        let announcements = UIAlertAction(title: "Annoucements", style: .default) { _ in
            AnnouncementsViewController.push(self)
        }
        actionController.addAction(cancel)
        actionController.addAction(announcements)
        actionController.addAction(attributions)
        actionController.addAction(logout)

        self.present(actionController, animated: true, completion: nil)
    }

    private func setupNibs() {
        tableView.register(ProfileSummaryTableViewCell.self,
                           forCellReuseIdentifier: kProfileSummaryTableViewCellId)
        tableView.register(ProfileSubmissionTableViewCell.self,
                           forCellReuseIdentifier: kProfileSubmissionTableViewCellId)
        tableView.register(ProfileNeedsAuthTableViewCell.self,
                           forCellReuseIdentifier: kProfileNeedsAuthTableViewCellId)
        tableView.register(FoodieEmptyStateTableViewCell.self,
                           forCellReuseIdentifier: kFoodieEmptyStateTableViewCellId)
        tableView.register(ProfileContestTableViewCell.self,
                           forCellReuseIdentifier: kProfileContestTableViewCellId)
    }

    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view, with: .zero)
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if FBSDKAccessToken.currentAccessTokenIsActive() {
                switch indexPath.row {
                case 0:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSummaryTableViewCellId,
                                                                for: indexPath) as? ProfileSummaryTableViewCell {
                        if let profileModel = profileModel {
                            cell.configureCell(profileModel: profileModel)
                        }
                        return cell
                    }
                case 1:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileContestTableViewCellId,
                                                                for: indexPath) as? ProfileContestTableViewCell {
                        if let profileModel = profileModel {
                            cell.configureCell(profile: profileModel)
                        }
                        return cell
                    }
                default:
                    break
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileNeedsAuthTableViewCellId,
                                                            for: indexPath) as? ProfileNeedsAuthTableViewCell {
                    cell.configureCell(navigationBar: self.navigationController?.navigationBar, tabBar: self.tabBarController?.tabBar)
                    cell.delegate = self
                    return cell
                }
            }
        default:
            guard let viewModel = viewModel else { return UITableViewCell() }
            
            if viewModel.isEmpty {
                if let cell = tableView.dequeueReusableCell(
                    withIdentifier: kFoodieEmptyStateTableViewCellId,
                    for: indexPath)
                    as? FoodieEmptyStateTableViewCell {
                    cell.configureCell(text: "No submissions yet - submit a dish today!\nAll of your submissions will appear here.",
                                       imageString: "curry")
                    cell.isUserInteractionEnabled = false
                    return cell
                }
            }

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
        
        return 1 + (viewModel.isEmpty ? 1 : viewModel.sectionedSubmissions.count)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 1 }

        switch section {
        case 0:
            var contestRow = 0
            if let profile = profileModel, profile.amazonCode != nil {
                contestRow = 1
            }
            return 1 + contestRow
        default:
            if viewModel.isEmpty { return 1 }
            return viewModel.sectionedSubmissions[section-1].count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModel = viewModel else { return nil }
        
        switch section {
        case 0:
            return nil
        default:
            if viewModel.isEmpty { return nil }
            if viewModel.sectionedSubmissions.count > section-1 && viewModel.sectionedSubmissions[section-1].count > 0 {
                return DateFormatter.friendlyStringForDate(date: viewModel.dateOf(viewModel.sectionedSubmissions[section-1][0]))
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case 0:
            return 0
        default:
            if viewModel.isEmpty { return 0 }
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let retrievedSubmission = getSubmissionFor(indexPath: indexPath)
        guard let submission = retrievedSubmission else { return; }
        
        if let restaurant = submission.restaurant {
            if let dishId = submission.dish?.dishId {
                Answers.logContentView(withName: "Profile-DishTap", contentType: "dish", contentId: "\(dishId)", customAttributes: nil)
            }
            DishDetailViewController.push(self.navigationController, submission.dish, restaurant)
        } else {
            if let restaurantId = submission.getRestaurantId() {
                if let dishId = submission.dish?.dishId {
                    Answers.logContentView(withName: "Profile-DishTap", contentType: "dish", contentId: "\(dishId)", customAttributes: nil)
                }
                NetworkManager.shared.getRestaurant(restaurantId: restaurantId) { (json, _, _) in
                    if let restaurantJSON = json {
                        DishDetailViewController.push(self.navigationController, submission.dish, Restaurant(json: restaurantJSON))
                    }
                }
            }
        }
    }
    
    private func getSubmissionFor(indexPath: IndexPath) -> Submission? {
        guard let viewModel = viewModel else { return nil }
        let sectionIndex = indexPath.section-1
        guard sectionIndex >= 0 && sectionIndex < viewModel.sectionedSubmissions.count else { return nil }
        guard indexPath.row < viewModel.sectionedSubmissions[sectionIndex].count else { return nil }
        return viewModel.sectionedSubmissions[sectionIndex][indexPath.row]
    }
}

extension ProfileViewController: ProfileSubmissionTableViewCellDelegate {
    func onResubmitButtonTapped(submission: Submission?) {
        if let submission = submission {
            if let dishId = submission.dish?.dishId {
                Answers.logContentView(withName: "Profile-DishResubmit", contentType: "submission", contentId: "\(dishId)", customAttributes: nil)
            }
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

extension ProfileViewController: ProfileNeedsAuthTableViewCellDelegate {
    func showMoreMenuActionSheet() {
        // TODO: put this action sheet stuff in a method
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let attributions = UIAlertAction(title: "Attributions", style: .default) { _ in
            let vc = AttributionsViewController()
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        }
        let announcements = UIAlertAction(title: "Annoucements", style: .default) { _ in
            AnnouncementsViewController.push(self)
        }
        actionController.addAction(cancel)
        actionController.addAction(announcements)
        actionController.addAction(attributions)
        
        self.present(actionController, animated: true, completion: nil)
    }
}
