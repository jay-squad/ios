//
//  UploadViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos.PHImageManager
import Validator
import GradientLoadingBar
import Crashlytics
import NotificationBannerSwift
import MapKit

let kFormComponentTableViewCellId = "FormComponentTableViewCellId"
let kUploadImageTableViewCellId = "UploadImageTableViewCellId"
let kUploadBasicInfoTableViewCellId = "UploadBasicInfoTableViewCellId"
let kAdditionalInfoTableViewCellId = "AdditionalInfoTableViewCellId"
let kUploadEarningsTableViewCellId = "UploadEarningsTableViewCellId"
let kUploadRestaurantTableViewCellId = "UploadRestaurantTableViewCellId"
let kUploadRestaurantIfNewTableViewCellId = "UploadRestaurantIfNewTableViewCellId"

enum UploadFormError: Error {
    case required
    case price
}

protocol UploadViewControllerDelegate: class {
    func onSuccessfulUpload(_ sender: UploadViewController)
    
    // willHandlePhotoPickerWithDelegate must be true for this to execute
    func onChangePhotoRequested(_ sender: UploadViewController)
}

enum UploadFormStringComponent: Int {
    case restaurantName
    case dishSection
    case dishName
    
    case restaurantDescription
    case restaurantCuisineType
    case restaurantWebsite
    case restaurantPhoneNumber
    case dishDescription
}

class UploadViewController: UIViewController {

    var willHandlePhotoPickerWithDelegate: Bool = false
    
    let kNumberOfRowsBase = 5
    var tableView = UITableView()
    
    var restaurant: Restaurant?
    var newRestaurantName: String?
    var uploadImage: UIImage? {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private var formStringComponents: [UploadFormStringComponent: String] = [:]
    private var formLocationComponent: CLLocationCoordinate2D?
    private var formPriceFloat: Float = -1
    
    private var restaurantResult: ValidationResult?
    private var sectionResult: ValidationResult?
    private var dishResult: ValidationResult?
    
    // resubmission
    var prepopulatedSubmission: Submission?
    var isRestaurantResubmission: Bool = false
    var shouldDisableRestaurantNameModification: Bool = false
    var restaurantNameTextFieldIsEditing = false
    
    weak var delegate: UploadViewControllerDelegate?
    
    private var estimatedHeightDict: [IndexPath: CGFloat] = [:]
    
    private func setupNibs() {
        tableView.register(FormComponentTableViewCell.self,
                           forCellReuseIdentifier: kFormComponentTableViewCellId)
        tableView.register(UploadImageTableViewCell.self,
                           forCellReuseIdentifier: kUploadImageTableViewCellId)
        tableView.register(UploadBasicInfoTableViewCell.self,
                           forCellReuseIdentifier: kUploadBasicInfoTableViewCellId)
        tableView.register(AdditionalInfoTableViewCell.self,
                           forCellReuseIdentifier: kAdditionalInfoTableViewCellId)
        tableView.register(UploadEarningsTableViewCell.self,
                           forCellReuseIdentifier: kUploadEarningsTableViewCellId)
        tableView.register(UploadRestaurantTableViewCell.self,
                           forCellReuseIdentifier: kUploadRestaurantTableViewCellId)
        tableView.register(UploadRestaurantIfNewTableViewCell.self,
                           forCellReuseIdentifier: kUploadRestaurantIfNewTableViewCellId)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()
        
        navigationItem.title = "Upload a Dish"
        
        let rightNavBtn = UIBarButtonItem(title: "Submit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSubmitButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightNavBtn        
    }
    
    func addDismissButton() {
        let leftNavBtn = UIBarButtonItem(title: "Dismiss",
                                          style: .plain,
                                          target: self,
                                          action: #selector(onDismissButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftNavBtn
    }
    
    func addBackButton() {
        let leftNavBtn = UIBarButtonItem(title: "Back",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onBackButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftNavBtn
    }
    
    @objc private func onSubmitButtonTapped(_ sender: UIBarButtonItem?) {
        let basicInfoIndexPath = !shouldShowCreateNewRestaurantCell() ? IndexPath(row: 2, section: 0) : IndexPath(row: 3, section: 0)
        let additionalInfoIndexPath = !shouldShowCreateNewRestaurantCell() ? IndexPath(row: 3, section: 0) : IndexPath(row: 4, section: 0)
        
        restaurantResult = (formStringComponents[.restaurantName] ?? "" ).validate(rule: Validator.requiredRule)
        sectionResult = (formStringComponents[.dishSection] ?? "").validate(rule: Validator.requiredRule)
        dishResult = (formStringComponents[.dishName] ?? "").validate(rule: Validator.requiredRule)
        
        if (isRestaurantResubmission || (sectionResult!.isValid && dishResult!.isValid && formPriceFloat >= 0))
            && restaurantResult!.isValid && (!shouldShowCreateNewRestaurantCell() || formLocationComponent != nil) {
            
            GradientLoadingBar.shared.show()
            sender?.isEnabled = false
            
            var description = formStringComponents[.dishDescription]
            let sectionText = formStringComponents[.dishSection]
            //                let answersCustomAttrs = ["restaurant": restaurant?.id ?? -1,
            //                                          "itemName": formStringComponents[.dishName] ?? "",
            //                                          "itemSection": sectionText ?? "",
            //                                          "description": description ?? ""] as [String: Any]
            
            Answers.logContentView(withName: "Upload-SubmissionRequest", contentType: "submission", contentId: nil,
                                   customAttributes: nil)
            
            func insertDishCompletionHandler(_ error: Error?) {
                GradientLoadingBar.shared.hide()
                if error == nil {
                    Answers.logContentView(withName: "Upload-SubmissionSuccess", contentType: "submission", contentId: nil,
                                           customAttributes: nil)
                    self.delegate?.onSuccessfulUpload(self)
                } else {
                    sender?.isEnabled = true
                    let banner = NotificationBanner(title: nil, subtitle: "Something went wrong while submitting the dish", style: .danger)
                    banner.haptic = .none
                    banner.subtitleLabel?.textAlignment = .center
                    banner.show()
                }
            }
            
            func insertDish(id: Int) {
                if uploadImage != nil {
                    NetworkManager.shared.insertMenuItem(restaurantId: id,
                                                         itemName: formStringComponents[.dishName],
                                                         itemImage: uploadImage,
                                                         description: description,
                                                         sectionName: sectionText == kNoSection ? "" : sectionText,
                                                         price: formPriceFloat) { (_, error, _) in
                                                            insertDishCompletionHandler(error)
                    }
                } else {
                    // only on resubmission with same image
                    NetworkManager.shared.insertMenuItem(restaurantId: id,
                                                         itemName: formStringComponents[.dishName],
                                                         itemImageUrl: prepopulatedSubmission?.dishImage?.image,
                                                         description: description,
                                                         sectionName: sectionText == kNoSection ? "" : sectionText,
                                                         price: formPriceFloat) { (_, error, _) in
                                                            insertDishCompletionHandler(error)
                    }
                }
            }
            
            if let formLocationComponent = formLocationComponent {
                NetworkManager.shared.submitRestaurant(name: formStringComponents[.restaurantName] ?? "",
                                                       location: formLocationComponent,
                                                       description: formStringComponents[.restaurantDescription],
                                                       cuisineType: formStringComponents[.restaurantCuisineType],
                                                       phoneNumber: formStringComponents[.restaurantPhoneNumber],
                                                       website: formStringComponents[.restaurantWebsite]) { (json, error, _) in
                                                        if error == nil, let id = json?["id"].int {
                                                            if !self.isRestaurantResubmission {
                                                                insertDish(id: id)
                                                            } else {
                                                                GradientLoadingBar.shared.hide()
                                                                Answers.logContentView(withName: "Upload-SubmissionSuccess", contentType: "submission", contentId: nil,
                                                                                       customAttributes: nil)
                                                                self.delegate?.onSuccessfulUpload(self)
                                                            }
                                                        } else {
                                                            GradientLoadingBar.shared.hide()
                                                            sender?.isEnabled = true
                                                            
                                                            let banner = NotificationBanner(title: nil, subtitle: "Something went wrong while submitting the restaurant", style: .danger)
                                                            banner.haptic = .none
                                                            banner.subtitleLabel?.textAlignment = .center
                                                            banner.show()
                                                        }
                }
            } else if let id = restaurant?.id {
                insertDish(id: id)
            }
        } else {
            if !restaurantResult!.isValid {
                tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                if let cellRestaurantName = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UploadRestaurantTableViewCell {
                    cellRestaurantName.restaurantTextfield.errorStyle()
                }
            } else if shouldShowCreateNewRestaurantCell() && formLocationComponent == nil {
                tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
            } else if !sectionResult!.isValid || !dishResult!.isValid || formPriceFloat < 0 {
                tableView.scrollToRow(at: basicInfoIndexPath, at: .top, animated: true)
                if let cellBasicInfo = tableView.cellForRow(at: basicInfoIndexPath) as? UploadBasicInfoTableViewCell {
                    if !sectionResult!.isValid {
                        cellBasicInfo.dishSectionTextField.errorStyle()
                    }
                    if !dishResult!.isValid {
                        cellBasicInfo.dishTextField.errorStyle()
                    }
                    if formPriceFloat < 0 {
                        cellBasicInfo.priceTextField.errorStyle()
                    }
                }
            }
        }
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onBackButtonTapped(_ sender: UIBarButtonItem?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupTableView()
        buildComponents()
        setupNavigation()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shiftViewWhenKeyboardAppears()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableShiftViewWhenKeyboardAppears()
    }
    
    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view, with: .zero)
    }
    
    func prepopulate(_ submission: Submission) {
        prepopulatedSubmission = submission
        isRestaurantResubmission = submission.dish == nil && submission.dishImage == nil && submission.restaurant != nil
        shouldDisableRestaurantNameModification = !isRestaurantResubmission && !CachedRestaurants.shared.all.contains(where: { return $0.id == submission.restaurant?.id })
    }
    
    @objc override func shiftViewKeyboardWillShow(notification: NSNotification) {
        // TOOD: HACKY
        if !(isRestaurantResubmission && restaurantNameTextFieldIsEditing) {
            super.shiftViewKeyboardWillShow(notification: notification)
        }
        if viewIsShiftedFromKeyboard() {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadImageTableViewCell {
                cell.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadImageTableViewCell {
            cell.isUserInteractionEnabled = true
        }
    }
    
}

extension UploadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offset = shouldShowCreateNewRestaurantCell() ? 1 : 0
        
        if shouldShowCreateNewRestaurantCell(), indexPath.row == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadRestaurantIfNewTableViewCellId, for: indexPath) as? UploadRestaurantIfNewTableViewCell {
                cell.delegate = self
                cell.formComponentDelegate = self
                if isRestaurantResubmission, let prepopulatedSubmission = prepopulatedSubmission, !cell.didAlreadyPrefill {
                    cell.configureCell(prefilledSubmission: prepopulatedSubmission)
                    cell.didAlreadyPrefill = true
                } else {
                    cell.configureCell(restaurantName: newRestaurantName)
                }
                return cell
            }
        }
        
        switch indexPath.row {
        case 0:
            if isRestaurantResubmission { break }
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadImageTableViewCellId,
                                                        for: indexPath) as? UploadImageTableViewCell {
                if uploadImage != nil {
                    cell.configureCell(image: uploadImage)
                } else if let prepopulatedSubmission = prepopulatedSubmission {
                    cell.configureCell(imageUrl: prepopulatedSubmission.dishImage?.image)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadRestaurantTableViewCellId,
                                                        for: indexPath) as? UploadRestaurantTableViewCell {
                cell.formComponentDelegate = self
                cell.delegate = self
                if isRestaurantResubmission, let prepopulatedSubmission = prepopulatedSubmission, !cell.didAlreadyPrefill {
                    cell.configureCell(restaurant: prepopulatedSubmission.restaurant)
                    cell.didAlreadyPrefill = true
                } else {
                    cell.configureCell(restaurant: restaurant)
                }
                if shouldDisableRestaurantNameModification {
                    cell.contentView.alpha = 0.25
                    cell.isUserInteractionEnabled = false
                }
                return cell
            }
        case 2 + offset:
            if isRestaurantResubmission { break }
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadBasicInfoTableViewCellId,
                                                        for: indexPath) as? UploadBasicInfoTableViewCell {
                cell.formComponentDelegate = self
                if let prepopulatedSubmission = prepopulatedSubmission, !cell.didAlreadyPrefill {
                    cell.configureCell(menu: restaurant?.menu, prefilledSubmission: prepopulatedSubmission)
                    cell.didAlreadyPrefill = true
                } else {
                    cell.configureCell(menu: restaurant?.menu)
                }
                return cell
            }
        case 3 + offset:
            if isRestaurantResubmission { break }
            if let cell = tableView.dequeueReusableCell(withIdentifier: kAdditionalInfoTableViewCellId,
                                                        for: indexPath) as? AdditionalInfoTableViewCell {
                let prefilledDescription = prepopulatedSubmission?.dishImage?.description
                cell.formComponentDelegate = self
                cell.configureCell(title: "Description",
                                   subtitle: "Describe the dish and mention if you’ve changed anything about your dish from its original form.",
                                   placeholder: "e.g. thin noodles, salad instead of fries",
                                   prefilledDescription: prefilledDescription)
                return cell
            }
        case 4 + offset:
            if isRestaurantResubmission { break }
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadEarningsTableViewCellId,
                                                        for: indexPath) as? UploadEarningsTableViewCell {
                cell.configureCell(points: 50 + (shouldShowCreateNewRestaurantCell() ? 50 : 0))
                return cell
            }
        default:
            break
        }

        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kNumberOfRowsBase + (shouldShowCreateNewRestaurantCell() ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isRestaurantResubmission else { return }
        switch indexPath.row {
        case 0:
            if willHandlePhotoPickerWithDelegate {
                delegate?.onChangePhotoRequested(self)
            } else {
                let pickerController = DKImagePickerController()
                pickerController.setDefaultControllerProperties()
                pickerController.didSelectAssets = { (assets: [DKAsset]) in
                    for asset in assets {
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        asset.fetchOriginalImage(options: options, completeBlock: { (image, _) in
                            if let img = image {
                                self.uploadImage = img
                            }
                        })
                    }
                }
                self.present(pickerController, animated: true) {}
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightDict[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isRestaurantResubmission {
            if indexPath.row == 0 ||
                indexPath.row == 3 ||
                indexPath.row == 4 ||
                indexPath.row == 5 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeightDict[indexPath] = cell.frame.size.height
    }
    
    private func shouldShowCreateNewRestaurantCell() -> Bool {
        guard !isRestaurantResubmission else { return true }
        return restaurant == nil && newRestaurantName != nil && newRestaurantName != ""
    }
    
}

extension UploadViewController: UploadRestaurantTableViewCellDelegate {
    func restaurantNameTextFieldShouldBeginEditing() {
        restaurantNameTextFieldIsEditing = true
    }
    
    func restaurantExistenceDidChange(restaurant: Restaurant?, orName: String?) {
        let didShowCreateNewRestaurantCellBefore = shouldShowCreateNewRestaurantCell()
        self.restaurant = restaurant
        self.newRestaurantName = orName
        formLocationComponent = nil
        if didShowCreateNewRestaurantCellBefore, !shouldShowCreateNewRestaurantCell() {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        } else if !didShowCreateNewRestaurantCellBefore, shouldShowCreateNewRestaurantCell() {
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        }
        if orName != nil, let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UploadRestaurantIfNewTableViewCell {
            cell.restaurantName = orName
            cell.setMapRegion()
        }
        if let restaurant = restaurant {
            reconfigureBasicInfoCellWithNewMenu(restaurant: restaurant)
        } else {
            reconfigureBasicInfoCellWithNoMenu()
        }
        tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)], with: .none)
        restaurantNameTextFieldIsEditing = false
    }
    
    func newNonExistentNameTyped(name: String?) {
        let didShowCreateNewRestaurantCellBefore = shouldShowCreateNewRestaurantCell()
        self.newRestaurantName = name
        formLocationComponent = nil
        if !didShowCreateNewRestaurantCellBefore, shouldShowCreateNewRestaurantCell() {
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)], with: .none)
        } else if didShowCreateNewRestaurantCellBefore, !shouldShowCreateNewRestaurantCell() {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)], with: .none)
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UploadRestaurantIfNewTableViewCell {
            cell.restaurantName = name
            cell.setMapRegion()
        }
        restaurantNameTextFieldIsEditing = false
    }
    
    func newExistingRestaurantSelected(restaurant: Restaurant) {
        reconfigureBasicInfoCellWithNewMenu(restaurant: restaurant)
        restaurantNameTextFieldIsEditing = false
    }
    
    private func reconfigureBasicInfoCellWithNewMenu(restaurant: Restaurant) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UploadBasicInfoTableViewCell {
            
            if let menu = restaurant.menu {
                cell.configureCell(menu: menu)
            } else {
                NetworkManager.shared.getRestaurantMenu(restaurantId: restaurant.id) { (json, _, _) in
                    if let menuJSONs = json {
                        cell.configureCell(menu: Menu(json: menuJSONs))
                    }
                }
            }
        }
    }
    
    private func reconfigureBasicInfoCellWithNoMenu() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UploadBasicInfoTableViewCell {
            cell.configureCell(menu: nil)
        }
    }
}

extension UploadViewController: UploadRestaurantIfNewTableViewCellDelegate {
    func onMapUnlockGiveTableViewHeight() -> CGFloat {
        tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
        tableView.isScrollEnabled = false
        return tableView.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    }
    
    func onMapLock() {
        tableView.isScrollEnabled = true
    }
}

extension UploadViewController: FormComponentTableViewCellDelegate {
    func onTextFieldUpdated(_ sender: UITextField) {
        if let formComponent = UploadFormStringComponent(rawValue: sender.tag) {
            formStringComponents[formComponent] = sender.text
        }
    }
    
    func onMapUpdated(_ sender: MKMapView) {
        formLocationComponent = sender.centerCoordinate
    }
    
    func onPriceFloatUpdated(_ price: Float) {
        formPriceFloat = price
    }
}
