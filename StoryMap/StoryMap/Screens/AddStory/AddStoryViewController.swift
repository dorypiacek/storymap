//
//  AddStoryViewController.swift
//  StoryMap
//
//  Created by Dory on 18/10/2021.
//

import Foundation
import UIKit
import SnapKit

class AddStoryViewController: UIViewController {
    
    // MARK: - Constants
    
    private var viewModel: AddStoryViewModelType
    
    private let titleStackView = UIStackView()
    private let titleTextField = UITextField()
    private let titleTextFieldErrorLabel = UILabel()
    private let locationTextField = UITextField()
    private let recordButton = UIButton(type: .system)
    private let addPhotoButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    
    private var confirmButtonBottomConstraint: NSLayoutConstraint?
    
    private let padding: CGFloat = 20
    private let topOffset: CGFloat = 50
    private let confirmButtonHeight: CGFloat = 44
    
    init(viewModel: AddStoryViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        setupTitleTextField()
        setupLocationTextField()
        setupRecordButton()
        setupAddPhotoButton()
        setupConfirmButton()
        
        updateUI()
    }
    
    private func updateUI() {
        titleTextField.placeholder = viewModel.titlePlaceholder
        titleTextFieldErrorLabel.text = viewModel.titleError
        locationTextField.placeholder = viewModel.locationPlaceholder
        recordButton.setImage(UIImage(named: viewModel.recordIcon), for: .normal)
        addPhotoButton.setTitle(viewModel.addPhotoTitle, for: .normal)
        confirmButton.setTitle(viewModel.confirmTitle, for: .normal)
    }
    
    func updateTitleTextField() {
        titleTextFieldErrorLabel.alpha = viewModel.titleError.isEmpty ? 0 : 1
        titleTextFieldErrorLabel.text = viewModel.titleError
    }
    
    private func setupTitleTextField() {
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 5
        
        titleStackView.addArrangedSubview(titleTextField)
        titleStackView.addArrangedSubview(titleTextFieldErrorLabel)
        
        titleTextFieldErrorLabel.textColor = .red
        titleTextFieldErrorLabel.textAlignment = .left
        titleTextFieldErrorLabel.font = UIFont.systemFont(ofSize: 12)
        
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.returnKeyType = .next
        titleTextField.delegate = self
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(confirmButtonHeight)
        }
        titleTextField.becomeFirstResponder()
        
        view.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topOffset)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
    }
    
    private func setupLocationTextField() {
        locationTextField.backgroundColor = .white
        locationTextField.borderStyle = .roundedRect
        locationTextField.delegate = self
        view.addSubview(locationTextField)
        
        locationTextField.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(confirmButtonHeight)
        }
    }
    
    private func setupRecordButton() {
        view.addSubview(recordButton)
        
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(locationTextField.snp.bottom).offset(topOffset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupAddPhotoButton() {
        view.addSubview(addPhotoButton)
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(recordButton.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupConfirmButton() {
        view.addSubview(confirmButton)
        
        confirmButton.layer.borderWidth = 1
        confirmButton.layer.borderColor = UIColor.lightGray.cgColor
        confirmButton.layer.cornerRadius = 8
        
        confirmButtonBottomConstraint = confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        confirmButtonBottomConstraint?.isActive = true
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(locationTextField)
            make.height.equalTo(confirmButtonHeight)
        }
    }
    
    func showImagePicker(with sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    // MARK: - Actions
    
    @objc func addPhotoTapped() {
        let actionSheet = UIAlertController(
            title: viewModel.addPhotoDialogueTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.showImagePicker(with: .camera)
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Choose from library",
                style: .default,
                handler: { [weak self] _ in
                    self?.showImagePicker(with: .photoLibrary)
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
                              
        present(actionSheet, animated: true)
    }
    
    // MARK: - Keyboard notifications
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: AddStoryViewController.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: AddStoryViewController.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: AddStoryViewController.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: AddStoryViewController.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            confirmButtonBottomConstraint?.constant = -keyboardSize.height
            
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            confirmButtonBottomConstraint?.constant = -padding
            
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddStoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            locationTextField.becomeFirstResponder()
            titleTextField.resignFirstResponder()
        } else if textField == locationTextField {
            locationTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleTextField {
            titleTextFieldErrorLabel.alpha = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            viewModel.title = textField.text
            updateTitleTextField()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddStoryViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
}
