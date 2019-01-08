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
    
    var restaurant: Restaurant?
    private var menu: Menu?
    private var menuView: MenuViewModel?
    private var estimatedHeightDict: [RestaurantDetailDisplayOption: [IndexPath: CGFloat]] = [.grid: [:],
                                                                                              .list: [:],
                                                                                              .expanded: [:]]
    private var currentExpandedGridCellIndex: IndexPath?
    
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
    }

    private func setupDataSource() {
        guard let restaurant = restaurant else { return }
        
        NetworkManager.shared.getRestaurantMenu(restaurantId: restaurant.id) { (json, error, code) in
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
                    asset.fetchOriginalImage(true, completeBlock: { image, _ in
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
        if gestureRecognizer.state == .ended {
            if let tableView = gestureRecognizer.view as? UITableView {
                let p = gestureRecognizer.location(in: gestureRecognizer.view)
                if let indexPath = tableView.indexPathForRow(at: p) {
                    if let cell = tableView.cellForRow(at: indexPath) as? RestaurantDetailMenu3ColumnGridTableViewCell {
                        let pointInCell = gestureRecognizer.location(in: cell)
                        var rowOffset: Int = 0
                        self.tableView.beginUpdates()
                        if let currentExpandedGridCellIndex = currentExpandedGridCellIndex {
                            menuView?.orders[.grid]![currentExpandedGridCellIndex.section-2][
                                currentExpandedGridCellIndex.row] = .column3
                            menuView?.orders[.grid]![currentExpandedGridCellIndex.section-2]
                                                    .remove(at: currentExpandedGridCellIndex.row + 1)
                            menuView?.orders[.grid]![currentExpandedGridCellIndex.section-2]
                                                    .remove(at: currentExpandedGridCellIndex.row + 1)
                            self.currentExpandedGridCellIndex = nil
                            if indexPath.section == currentExpandedGridCellIndex.section
                                && indexPath.row > currentExpandedGridCellIndex.row {
                                rowOffset -= 2
                            } else if indexPath.section != currentExpandedGridCellIndex.section {
                                tableView.reloadSections(IndexSet(integer: currentExpandedGridCellIndex.section),
                                                         with: kRowAnimationType)
                            }
                        }
                        
                        if cell.dish0 != nil, cell.dish0ImageView.frame.contains(pointInCell) {
                            menuView?.orders[.grid]![indexPath.section-2][indexPath.row + rowOffset] = .expanded
                            menuView?.orders[.grid]![indexPath.section-2].insert(.column1,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            menuView?.orders[.grid]![indexPath.section-2].insert(.column1,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            currentExpandedGridCellIndex = IndexPath(row: indexPath.row + rowOffset,
                                                                     section: indexPath.section)
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: kRowAnimationType)
                        } else if cell.dish1 != nil, cell.dish1ImageView.frame.contains(pointInCell) {
                            menuView?.orders[.grid]![indexPath.section-2][indexPath.row + rowOffset] = .column1
                            menuView?.orders[.grid]![indexPath.section-2].insert(.column1,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            menuView?.orders[.grid]![indexPath.section-2].insert(.expanded,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            currentExpandedGridCellIndex = IndexPath(row: indexPath.row + rowOffset,
                                                                     section: indexPath.section)
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: kRowAnimationType)
                        } else if cell.dish2 != nil, cell.dish2ImageView.frame.contains(pointInCell) {
                            menuView?.orders[.grid]![indexPath.section-2][indexPath.row + rowOffset] = .column1
                            menuView?.orders[.grid]![indexPath.section-2].insert(.expanded,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            menuView?.orders[.grid]![indexPath.section-2].insert(.column1,
                                                                                 at: indexPath.row + 1 + rowOffset)
                            currentExpandedGridCellIndex = IndexPath(row: indexPath.row + rowOffset,
                                                                     section: indexPath.section)
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: kRowAnimationType)
                        }
                        self.tableView.endUpdates()
                    } else if let cell = tableView.cellForRow(at: indexPath)
                        as? RestaurantDetailMenu1ColumnGridTableViewCell, cell.dish != nil {
                        let lowerBound = max(0, indexPath.row - 2)
                        let upperBound = min(menuView!.orders[.grid]![indexPath.section-2].count - 1, indexPath.row + 2)
                        var reloadRows: [IndexPath] = [indexPath]
                        for i in lowerBound...upperBound
                            where menuView?.orders[.grid]![indexPath.section-2][i] == .expanded {
                                menuView?.orders[.grid]![indexPath.section-2][i] = .column1
                                reloadRows.append(IndexPath(row: i, section: indexPath.section))
                        }
                        menuView?.orders[.grid]![indexPath.section-2][indexPath.row] = .expanded
                        tableView.beginUpdates()
                        tableView.reloadRows(at: reloadRows, with: kRowAnimationType)
                        tableView.endUpdates()
                    }
                }
            }
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
        if let model = menuView {
            switch model.activeMenuType {
            case .grid:
                // grid taps are handled by gridTapGestureRecognizer
                break
            case .list:
                switch indexPath.section {
                case 0, 1:
                    break
                default:
                    if menuView?.orders[.list]![indexPath.section-2][indexPath.row] == .condensed {
                        menuView?.orders[.list]![indexPath.section-2][indexPath.row] = .expanded
                    } else {
                        menuView?.orders[.list]![indexPath.section-2][indexPath.row] = .condensed
                    }
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: kRowAnimationType)
                    tableView.endUpdates()
                }
            case .expanded:
                break
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
