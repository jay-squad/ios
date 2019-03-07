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

let kRestaurantDetailTableViewCellId = "RestaurantDetailTableViewCellId"
let kRestaurantDetailDisplayOptionsTableViewCellId = "RestaurantDetailDisplayOptionsTableViewCellId"
let kRestaurantDetailMenu3ColumnGridTableViewCellId = "RestaurantDetailMenu3ColumnGridTableViewCellId"
let kRestaurantDetailMenu1ColumnGridTableViewCellId = "RestaurantDetailMenu1ColumnGridTableViewCellId"
let kRestaurantDetailMenuExpandedTableViewCellId = "RestaurantDetailMenuExpandedTableViewCellId"
let kRestaurantDetailMenuListTableViewCellId = "RestaurantDetailMenuListTableViewCellId"

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
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
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload a Dish",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onUploadButtonTapped))
    }
    
    @objc private func onUploadButtonTapped() {
        guard let restaurant = restaurant else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
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
                            uploadVC.restaurantId = restaurant.id
                            uploadVC.restaurantMenu = self.menu
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
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func handleGridLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began, let dish = getDish(gestureRecognizer) {
            peekExpandedForm(dish: dish)
        } else if gestureRecognizer.state == .ended {
            unpeekExpandedForm()
        }
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
                cell.configureCell(restaurant: restaurant)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailDisplayOptionsTableViewCellId,
                for: indexPath)
                as? RestaurantDetailDisplayOptionsTableViewCell {
                cell.delegate = self
                cell.configureCell(type: menuView?.activeMenuType ?? .grid)
                return cell
            }
        default:
            if let menuView = menuView {
                switch menuView.orders[menuView.activeMenuType]![indexPath.section-2][indexPath.row] {
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
                            cell.configureCell(dish0: menu.getDish(section: indexPath.section-2,
                                                                   row: rowMultiplier * 3),
                                               dish1: menu.getDish(section: indexPath.section-2,
                                                                   row: rowMultiplier * 3 + 1),
                                               dish2: menu.getDish(section: indexPath.section-2,
                                                                   row: rowMultiplier * 3 + 2))
                        }
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
                            cell.configureCell(dish: menu.getDish(section: indexPath.section-2,
                                                                  row: currentExpandedGridCellIndex.row * 3 + offset))
                        }
                        return cell
                    }
                case .condensed:
                    if let cell = tableView.dequeueReusableCell(
                        withIdentifier: kRestaurantDetailMenuListTableViewCellId,
                        for: indexPath)
                        as? RestaurantDetailMenuListTableViewCell {
                        if let menu = menu {
                            cell.configureCell(dish: menu.getDish(section: indexPath.section-2, row: indexPath.row))
                        }
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
                                    cell.configureCell(dish: menu.getDish(section: indexPath.section-2,
                                                                          row: currentExpandedGridCellIndex.row * 3
                                                                                + offset))
                                    cell.addShadow()
                                }
                            default:
                                cell.configureCell(dish: menu.getDish(section: indexPath.section-2, row: indexPath.row))
                            }
                        }
                        return cell
                    }
                }
            }
        }
        assert(false)
        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let base = 2
        if let model = menuView {
            switch model.activeMenuType {
            case .grid:
                return base + model.orders[.grid]!.count
            case .list:
                return base + model.orders[.list]!.count
            case .expanded:
                return base + model.orders[.expanded]!.count
            }
        }
        return base
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            if let model = menuView {
                switch model.activeMenuType {
                case .grid:
                    return model.orders[.grid]![section-2].count
                case .list:
                    return model.orders[.list]![section-2].count
                case .expanded:
                    return model.orders[.expanded]![section-2].count
                }
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 0
        default:
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0, 1:
            return nil
        default:
            return menu?.sections[section-2].name
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(font: .helveticaNeueMedium, size: 18)
            header.textLabel?.textColor = UIColor.cc74MediumGrey
            header.backgroundView?.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section >= 2 else { return }
        if let model = menuView {
            switch model.activeMenuType {
            case .grid:
                // grid taps are handled by gridTapGestureRecognizer
                break
            default:
                DishDetailViewController.push(navigationController,
                                              menu?.getDish(section: indexPath.section-2, row: indexPath.row),
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
    func onSuccessfulUpload() {
        setupDataSource()
    }
}
