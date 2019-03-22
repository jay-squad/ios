//
//  RestaurantDetailViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import DKImagePickerController
import Photos.PHImageManager
import FBSDKCoreKit
import NotificationBannerSwift
import Crashlytics

let kRestaurantDetailTableViewCellId = "RestaurantDetailTableViewCellId"
let kRestaurantDetailDisplayOptionsTableViewCellId = "RestaurantDetailDisplayOptionsTableViewCellId"
let kRestaurantDetailMenu3ColumnGridTableViewCellId = "RestaurantDetailMenu3ColumnGridTableViewCellId"
let kRestaurantDetailMenu1ColumnGridTableViewCellId = "RestaurantDetailMenu1ColumnGridTableViewCellId"
let kRestaurantDetailMenuExpandedTableViewCellId = "RestaurantDetailMenuExpandedTableViewCellId"
let kRestaurantDetailMenuListTableViewCellId = "RestaurantDetailMenuListTableViewCellId"
let kRestaurantDetailSearchBarTableViewCellId = "RestaurantDetailSearchBarTableViewCellId"

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let kNumSectionsBeforeMenu = 3
    let kSectionHeaderHeight: CGFloat = 65
    let kRowAnimationType: UITableView.RowAnimation = .middle
    var gridTapGestureRecognizer: UITapGestureRecognizer?
    var gridLongPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var restaurant: Restaurant?
    private var menu: Menu?
    private var menuView: MenuViewModel?
    private var estimatedHeightDict: [RestaurantDetailDisplayOption: [IndexPath: CGFloat]] = [.grid: [:],
                                                                                              .list: [:],
                                                                                              .expanded: [:]]
    private var currentExpandedGridCellIndex: IndexPath?
    var locationManager = CLLocationManager()
    
    // peeking
    let kPeekAnimationDuration: TimeInterval = 0.15
    let kPeekLongPressMinimumDuration: TimeInterval = 0.1
    var peekView: RestaurantDetailMenuExpandedView!
    var blurView: UIVisualEffectView!
    
    private func setupNibs() {
        tableView.register(UINib(nibName: "RestaurantDetailTableViewCell", bundle: nil),
                           forCellReuseIdentifier: kRestaurantDetailTableViewCellId)
        tableView.register(RestaurantDetailDisplayOptionsTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailDisplayOptionsTableViewCellId)
        tableView.register(RestaurantDetailMenu3ColumnGridTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailMenu3ColumnGridTableViewCellId)
        tableView.register(RestaurantDetailMenu1ColumnGridTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailMenu1ColumnGridTableViewCellId)
        tableView.register(RestaurantDetailMenuListTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailMenuListTableViewCellId)
        tableView.register(RestaurantDetailMenuExpandedTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailMenuExpandedTableViewCellId)
        tableView.register(RestaurantDetailSearchBarTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailSearchBarTableViewCellId)
        tableView.register(FoodieEmptyStateTableViewCell.self,
                           forCellReuseIdentifier: kFoodieEmptyStateTableViewCellId)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        gridTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleGridTap(_:)))
        gridTapGestureRecognizer?.delegate = self
        self.tableView.addGestureRecognizer(gridTapGestureRecognizer!)
        
        gridLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleGridLongPress(_:)))
        gridLongPressGestureRecognizer?.delegate = self
        gridLongPressGestureRecognizer?.minimumPressDuration = kPeekLongPressMinimumDuration
        self.tableView.addGestureRecognizer(gridLongPressGestureRecognizer!)
        
    }

    private func setupDataSource() {
        guard let restaurant = restaurant else { return }
        
        NetworkManager.shared.getRestaurantMenu(restaurantId: restaurant.id) { (json, error, _) in
            if let menuJSONs = json {
                self.menu = Menu(json: menuJSONs)
                self.menuView = MenuViewModel(type: .grid)
                self.menuView?.setDataSource(menu: self.menu!)
                self.tableView.reloadData()
            } else if let error = error {
                print("----------- ERROR ---------------")
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupTableView()
        setupDataSource()
        setupLocationServices()
        setupNavigation()
        shiftViewWhenKeyboardAppears()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupLocationServices() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload a Dish",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onUploadButtonTapped))
    }
    
    @objc private func onUploadButtonTapped() {
        guard FBSDKAccessToken.currentAccessTokenIsActive() else {
            let banner = NotificationBanner(title: nil, subtitle: "You must be logged in to upload content", style: .info)
            banner.haptic = .none
            banner.subtitleLabel?.textAlignment = .center
            banner.show()
            if let tabBarVCs = tabBarController?.viewControllers {
                tabBarController?.selectedViewController = tabBarVCs[tabBarVCs.count-1]
            }
            return
        }
        guard let restaurant = restaurant else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Answers.logContentView(withName: "RestaurantDetail-SubmissionInitiate", contentType: "submission", contentId: nil, customAttributes: nil)
        if let uploadVC = storyboard.instantiateViewController(
            withIdentifier: CommonIdentifiers.UploadViewControllerId)
            as? UploadViewController {
        
            let pickerController = DKImagePickerController()
            pickerController.setDefaultControllerProperties()
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                for asset in assets {
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    asset.fetchOriginalImage(options: options, completeBlock: { image, _ in
                        if let img = image {
                            uploadVC.restaurant = restaurant
                            uploadVC.restaurant?.menu = self.menu
                            uploadVC.uploadImage = img
                            uploadVC.delegate = self
                            self.navigationController?.pushViewController(uploadVC, animated: true)
                        }
                    })
                }
            }
            self.present(pickerController, animated: true) {}
        }
    }

    @objc private func handleGridTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if let dish = getDish(gestureRecognizer), let restaurant = restaurant {
            let vc = DishDetailViewController(dish: dish, restaurant: restaurant)
            Answers.logContentView(withName: "RestaurantDetail-DishDetail", contentType: "dish", contentId: "\(dish.dishId)", customAttributes: nil)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func handleGridLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began, let dish = getDish(gestureRecognizer) {
            Answers.logContentView(withName: "RestaurantDetail-DishPeek", contentType: "dish", contentId: "\(dish.dishId)", customAttributes: nil)
            peekExpandedForm(dish: dish)
        } else if gestureRecognizer.state == .ended {
            unpeekExpandedForm()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func getDish(_ gestureRecognizer: UIGestureRecognizer) -> Dish? {
        if let tableView = gestureRecognizer.view as? UITableView {
            let p = gestureRecognizer.location(in: gestureRecognizer.view)
            if let indexPath = tableView.indexPathForRow(at: p) {
                if let cell = tableView.cellForRow(at: indexPath) as? RestaurantDetailMenu3ColumnGridTableViewCell {
                    let pointInCell = gestureRecognizer.location(in: cell)
                    
                    if let dish0 = cell.dish0, cell.dish0ImageView.frame.contains(pointInCell) {
                        return dish0
                    } else if let dish1 = cell.dish1, cell.dish1ImageView.frame.contains(pointInCell) {
                        return dish1
                    } else if let dish2 = cell.dish2, cell.dish2ImageView.frame.contains(pointInCell) {
                        return dish2
                    }
                }
            }
        }
        return nil
    }
    
    private func peekExpandedForm(dish: Dish) {
        guard peekView == nil else { return }
        
        peekView = RestaurantDetailMenuExpandedView()
        peekView.translatesAutoresizingMaskIntoConstraints = false
        peekView.configureView(dish: dish)
        peekView.layer.cornerRadius = 8.0
        peekView.clipsToBounds = true
        
        if blurView == nil {
            let blurEffect = UIBlurEffect(style: .dark)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let window = UIApplication.shared.keyWindow!
        
        UIView.transition(with: window,
                          duration: kPeekAnimationDuration,
                          options: [.transitionCrossDissolve],
                          animations: {
            window.addSubview(self.blurView)
            window.addSubview(self.peekView)
        }, completion: nil)
        
        window.applyAutoLayoutInsetsForAllMargins(to: self.blurView, with: .zero)
        window.leadingAnchor.constraint(equalTo: peekView.leadingAnchor, constant: -30).isActive = true
        window.trailingAnchor.constraint(equalTo: peekView.trailingAnchor, constant: 30).isActive = true
        window.centerYAnchor.constraint(equalTo: peekView.centerYAnchor).isActive = true
        
        // if we want fixed height
        // peekView.heightAnchor.constraint(equalToConstant: 475).isActive = true
    }
    
    func unpeekExpandedForm() {
        guard peekView != nil else { return }
        peekView.removeFromSuperview()
        blurView.removeFromSuperview()
        peekView = nil
    }
    
    public static func push(_ navigationController: UINavigationController?, _ restaurant: Restaurant?) {
        if let restaurant = restaurant,
            let navigationController = navigationController,
            let detailedRestaurantVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                withIdentifier: CommonIdentifiers.RestaurantDetailViewControllerId) as? RestaurantDetailViewController {
            detailedRestaurantVC.restaurant = restaurant
            navigationController.pushViewController(detailedRestaurantVC, animated: true)
        }
    }
}

extension RestaurantDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restaurant = self.restaurant else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailTableViewCellId,
                for: indexPath)
                as? RestaurantDetailTableViewCell {
                cell.delegate = self
                cell.configureCell(restaurant: restaurant)
                hideKeyboardWhenTapping(view: cell)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailSearchBarTableViewCellId,
                for: indexPath)
                as? RestaurantDetailSearchBarTableViewCell {
                cell.delegate = self
                cell.configureCell()
                
                if let menuView = menuView, menuView.isEmpty {
                    cell.contentView.alpha = 0.25
                    cell.isUserInteractionEnabled = false
                }
                
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailDisplayOptionsTableViewCellId,
                for: indexPath)
                as? RestaurantDetailDisplayOptionsTableViewCell {
                cell.delegate = self
                cell.configureCell(type: menuView?.activeMenuType ?? .grid)
                hideKeyboardWhenTapping(view: cell)
                
                if let menuView = menuView, menuView.isEmpty {
                    cell.contentView.alpha = 0.25
                    cell.isUserInteractionEnabled = false
                }
                
                return cell
            }
        default:
            if let menuView = menuView {
                if menuView.isEmpty {
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kFoodieEmptyStateTableViewCellId,
                        for: indexPath)
                        as? FoodieEmptyStateTableViewCell {
                        cell.configureCell(text: "No dishes here yet.\nSubmit the first one today!",
                                           imageString: "onigiri")
                        return cell
                    }
                }
                switch menuView.orders[menuView.activeMenuType]![indexPath.section-kNumSectionsBeforeMenu][indexPath.row] {
                case .column3:
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kRestaurantDetailMenu3ColumnGridTableViewCellId,
                        for: indexPath)
                        as? RestaurantDetailMenu3ColumnGridTableViewCell {
                        if let menu = menu {
                            var rowMultiplier = indexPath.row
                            if let currentExpandedGridCellIndex = currentExpandedGridCellIndex,
                                indexPath.section == currentExpandedGridCellIndex.section
                                && indexPath.row > currentExpandedGridCellIndex.row {
                                rowMultiplier -= 2
                            }
                            cell.configureCell(dish0: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu,
                                                                   row: rowMultiplier * 3),
                                               dish1: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu,
                                                                   row: rowMultiplier * 3 + 1),
                                               dish2: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu,
                                                                   row: rowMultiplier * 3 + 2))
                        }
                        hideKeyboardWhenTapping(view: cell)
                        return cell
                    }
                case .column1:
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kRestaurantDetailMenu1ColumnGridTableViewCellId,
                        for: indexPath)
                        as? RestaurantDetailMenu1ColumnGridTableViewCell {
                        assert(currentExpandedGridCellIndex != nil)
                        if let menu = menu, let currentExpandedGridCellIndex = currentExpandedGridCellIndex {
                            let offset = indexPath.row - currentExpandedGridCellIndex.row
                            cell.configureCell(dish: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu,
                                                                  row: currentExpandedGridCellIndex.row * 3 + offset))
                        }
                        hideKeyboardWhenTapping(view: cell)
                        return cell
                    }
                case .condensed:
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kRestaurantDetailMenuListTableViewCellId,
                        for: indexPath)
                        as? RestaurantDetailMenuListTableViewCell {
                        if let menu = menu {
                            cell.configureCell(dish: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu, row: indexPath.row))
                        }
                        hideKeyboardWhenTapping(view: cell)
                        return cell
                    }
                case .expanded:
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kRestaurantDetailMenuExpandedTableViewCellId,
                        for: indexPath)
                        as? RestaurantDetailMenuExpandedTableViewCell {
                        if let menu = menu {
                            switch menuView.activeMenuType {
                            case .grid:
                                assert(currentExpandedGridCellIndex != nil)
                                if let currentExpandedGridCellIndex = currentExpandedGridCellIndex {
                                    let offset = indexPath.row - currentExpandedGridCellIndex.row
                                    cell.configureCell(dish: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu,
                                                                          row: currentExpandedGridCellIndex.row * 3
                                                                                + offset))
                                    cell.addShadow()
                                }
                            default:
                                cell.configureCell(dish: menu.getDish(section: indexPath.section-kNumSectionsBeforeMenu, row: indexPath.row))
                            }
                        }
                        hideKeyboardWhenTapping(view: cell)
                        return cell
                    }
                }
            }
        }
        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let model = menuView {
            return kNumSectionsBeforeMenu + (model.isEmpty ? 1 : model.orders[model.activeMenuType]!.count)
        }
        return kNumSectionsBeforeMenu
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2:
            return 1
        default:
            if let model = menuView {
                return model.isEmpty ? 1 : model.orders[model.activeMenuType]![section-kNumSectionsBeforeMenu].count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 0
        default:
            if let model = menuView, model.isEmpty {
                return 0
            }
            if let menu = menu {
                if menu.sections[section-kNumSectionsBeforeMenu].dishes.count == 0 {
                    return 0
                }
                return kSectionHeaderHeight
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0, 1, 2:
            return nil
        default:
            if let model = menuView, model.isEmpty {
                return nil
            }
            return menu?.sections[section-kNumSectionsBeforeMenu].name
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(font: .helveticaNeueBold, size: 18)
            header.textLabel?.textColor = UIColor.cc74MediumGrey
            header.backgroundView?.backgroundColor = UIColor.white
            
            if view.subviews.last as? UIButton != nil {
                return
            }
            let kButtonSize: CGFloat = 45
            let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: (kSectionHeaderHeight - kButtonSize)/2, width: kButtonSize, height: kButtonSize))
//            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.setImage(UIImage(named: "btn_more"), for: .normal)
            button.addTarget(self, action: #selector(self.onHeaderButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    @objc private func onHeaderButtonTapped(_ sender: UIButton) {
        if let header = sender.superview as? UITableViewHeaderFooterView, let section = header.textLabel?.text {
            UpdateRequestViewController.presentActionSheet(.section, sender: self, id: section)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section >= kNumSectionsBeforeMenu else { return }
        if let model = menuView {
            if model.isEmpty { return }
            switch model.activeMenuType {
            case .grid:
                // grid taps are handled by gridTapGestureRecognizer
                break
            default:
                DishDetailViewController.push(navigationController,
                                              menu?.getDish(section: indexPath.section-kNumSectionsBeforeMenu, row: indexPath.row),
                                              restaurant)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let type = menuView?.activeMenuType, let height = estimatedHeightDict[type]![indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let type = menuView?.activeMenuType {
            estimatedHeightDict[type]![indexPath] = cell.frame.size.height
        }
    }
}

extension RestaurantDetailViewController: RestaurantDetailDisplayOptionsTableViewCellDelegate {
    func onDisplayOptionChanged(type: RestaurantDetailDisplayOption) {
        switch type {
        case .grid:
            menuView?.activeMenuType = .grid
        case .list:
            menuView?.activeMenuType = .list
        case.expanded:
            menuView?.activeMenuType = .expanded
        }
        tableView.reloadData()
    }
}

extension RestaurantDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard menuView?.activeMenuType == .grid else { return false }
        if let tableView = gestureRecognizer.view as? UITableView {
            let p = gestureRecognizer.location(in: gestureRecognizer.view)
            if tableView.indexPathForRow(at: p) != nil {
                return true
            }
        }
        return false
    }
}

extension RestaurantDetailViewController: UploadViewControllerDelegate {
    func onChangePhotoRequested(_ sender: UploadViewController) {}
    
    func onSuccessfulUpload(_ sender: UploadViewController) {
        sender.navigationController?.popViewController(animated: true)
        setupDataSource()
    }
}

extension RestaurantDetailViewController: RestaurantDetailTableViewCellDelegate {
    func onMoreButtonTapped() {
        if let restaurant = restaurant {
            UpdateRequestViewController.presentActionSheet(.restaurant, sender: self, id: "\(restaurant.id)")
        }
    }
}

extension RestaurantDetailViewController: RestaurantDetailSearchBarTableViewCellDelegate {
    func viewControllerForSearchBar() -> UISearchBarDelegate {
        return self
    }
}

extension RestaurantDetailViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        Answers.logContentView(withName: "RestaurantDetail-DishSearch", contentType: "dish", contentId: nil, customAttributes: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        menu?.searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        menu?.searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let menu = menu, let menuView = menuView else { return; }

        tableView.beginUpdates()
        
        let numberOfSections = tableView.numberOfSections - kNumSectionsBeforeMenu
        var numberOfRowsInSectionPrev: [Int] = []
        for i in kNumSectionsBeforeMenu..<numberOfSections + kNumSectionsBeforeMenu {
            numberOfRowsInSectionPrev.append(tableView.numberOfRows(inSection: i))
        }
        
        if searchText == "" {
            menu.searchActive = false
        } else {
            menu.searchActive = true
        }
        
        menu.filter(query: searchText)
        menuView.setDataSource(menu: menu)
        
        for i in kNumSectionsBeforeMenu..<numberOfSections+kNumSectionsBeforeMenu {
            let zeroedIndex = i-kNumSectionsBeforeMenu
            let rowsDiff = tableView(tableView, numberOfRowsInSection: i) - (zeroedIndex < numberOfRowsInSectionPrev.count ? numberOfRowsInSectionPrev[zeroedIndex] : 0)

            var indexPaths: [IndexPath] = []
            for j in 0..<abs(rowsDiff) {
                indexPaths.append(IndexPath(row: j, section: i))
            }
            
            if rowsDiff > 0 {
                tableView.insertRows(at: indexPaths, with: .none)
            } else if rowsDiff < 0 {
                tableView.deleteRows(at: indexPaths, with: .none)
            }
        }
        
        tableView.endUpdates()
        
        // necessary for preventing header view positioning bug
        tableView.reloadSections(IndexSet(kNumSectionsBeforeMenu..<numberOfSections+kNumSectionsBeforeMenu), with: .none)
    }
    
}
