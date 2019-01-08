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

let kUploadFormComponentTableViewCellId = "UploadFormComponentTableViewCellId"
let kUploadImageTableViewCellId = "UploadImageTableViewCellId"
let kUploadBasicInfoTableViewCellId = "UploadBasicInfoTableViewCellId"
let kUploadAdditionalInfoTableViewCellId = "UploadAdditionalInfoTableViewCellId"
let kUploadEarningsTableViewCellId = "UploadEarningsTableViewCellId"

enum UploadFormError: Error {
    case required
    case price
}

protocol UploadViewControllerDelegate: class {
    func onSuccessfulUpload()
}

class UploadViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var restaurantId: Int = -1
    var restaurantMenu: Menu?
    var uploadImage: UIImage? {
        didSet {
            if let tableView = tableView {
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
    
    var restaurantResult: ValidationResult?
    var dishResult: ValidationResult?
    var priceResult: ValidationResult?
    
    weak var delegate: UploadViewControllerDelegate?
    
    private var estimatedHeightDict: [IndexPath: CGFloat] = [:]
    
    private func setupNibs() {
        tableView.register(UploadFormComponentTableViewCell.self,
                           forCellReuseIdentifier: kUploadFormComponentTableViewCellId)
        tableView.register(UploadImageTableViewCell.self,
                           forCellReuseIdentifier: kUploadImageTableViewCellId)
        tableView.register(UploadBasicInfoTableViewCell.self,
                           forCellReuseIdentifier: kUploadBasicInfoTableViewCellId)
        tableView.register(UploadAdditionalInfoTableViewCell.self,
                           forCellReuseIdentifier: kUploadAdditionalInfoTableViewCellId)
        tableView.register(UploadEarningsTableViewCell.self,
                           forCellReuseIdentifier: kUploadEarningsTableViewCellId)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.barTintColor = UIColor.cc253UltraLightGrey
        navigationController?.navigationBar.tintColor = UIColor.cc45DarkGrey
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(font: .helveticaNeueBold, size: 18.0)!,
             NSAttributedString.Key.foregroundColor: UIColor.cc45DarkGrey]
        navigationItem.title = "Upload a Dish"
        
        let rightNavBtn = UIBarButtonItem(title: "Submit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSubmitButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightNavBtn
        
    }
    
    @objc private func onSubmitButtonTapped(_ sender: UIBarButtonItem?) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UploadBasicInfoTableViewCell {
            restaurantResult = (cell.dishSectionTextField.text ?? "").validate(rule: Validator.requiredRule)
            dishResult = (cell.dishTextField.text ?? "").validate(rule: Validator.requiredRule)
            priceResult = (cell.priceTextField.text ?? "").validate(rule: Validator.priceRule)
            
            if restaurantResult!.isValid && dishResult!.isValid && priceResult!.isValid {
                
                var description: String?
                if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0))
                    as? UploadAdditionalInfoTableViewCell,
                    let desc = cell.additionalNotesTextField.text {
                    description = desc
                }
                
                NetworkManager.shared.insertMenuItem(restaurantId: restaurantId,
                                                     itemName: cell.dishTextField.text,
                                                     itemImage: uploadImage,
                                                     description: description,
                                                     sectionName: cell.dishSectionTextField.text,
                                                     price: cell.priceFloat) { (_, error, _) in
                    if error == nil {
                        self.delegate?.onSuccessfulUpload()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                if !restaurantResult!.isValid {
                    cell.dishSectionTextField.errorStyle()
                }
                if !dishResult!.isValid {
                    cell.dishTextField.errorStyle()
                }
                if !priceResult!.isValid {
                    cell.priceTextField.errorStyle()
                }
            }
        }
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupTableView()
        setupNavigation()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadImageTableViewCell {
                    cell.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
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
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadImageTableViewCellId,
                                                        for: indexPath) as? UploadImageTableViewCell {
                cell.configureCell(image: uploadImage)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadBasicInfoTableViewCellId,
                                                        for: indexPath) as? UploadBasicInfoTableViewCell {
                cell.configureCell(menu: restaurantMenu)
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadAdditionalInfoTableViewCellId,
                                                        for: indexPath) as? UploadAdditionalInfoTableViewCell {
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadEarningsTableViewCellId,
                                                        for: indexPath) as? UploadEarningsTableViewCell {
                cell.configureCell(points: 50)
                return cell
            }
        default:
            break
        }
        assert(false)
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeightDict[indexPath] = cell.frame.size.height
    }
    
}
