//
//  ReminderEditViewController.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/11/20.
//

import UIKit

class ReminderEditViewController: UIViewController, Alertable {
    
    private var viewModel: ReminderEditViewModel!
    private var keyboardHeight: CGFloat = 0
    
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    private lazy var rootView: UIView = {
        let v = UIView()
        v.addSubview(reminderImageButton)
        v.addSubview(reminderTitleTextField)
        v.addSubview(reminderContenTextView)
        v.addSubview(reminderDatePicker)
        return v
    }()
    
    private lazy var reminderImageButton: UIButton = {
        let b = UIButton()
        b.imageView?.contentMode = .scaleAspectFill
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.black.cgColor
        b.backgroundColor = .white
        b.tintColor = .darkGray
        b.layer.shadowRadius = 2.0
        b.layer.shadowOffset = CGSize(width: 0, height: 2) // Use any CGSize
        b.layer.shadowColor = UIColor.gray.cgColor
        b.layer.shadowOpacity = 0.4
        b.layer.masksToBounds = false
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return b
    }()
    
    private lazy var reminderTitleTextField: UITextField = {
        let t = UITextField()
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.black.cgColor
        
        t.layer.cornerRadius = 6
        t.layer.shadowRadius = 2.0
        t.layer.shadowOffset = CGSize(width: 0, height: 2) // Use any CGSize
        t.layer.shadowColor = UIColor.gray.cgColor
        t.layer.shadowOpacity = 0.4
        t.layer.masksToBounds = false
        
        t.textColor = .black
        t.adjustsFontForContentSizeCategory = true
        t.font = UIFont.preferredFont(forTextStyle: .body)
        t.backgroundColor = .white
        t.setLeftPaddingPoints(10)
        t.setRightPaddingPoints(10)
        t.delegate = self
        t.placeholder = "Title".localized()
        return t
    }()
    
    private lazy var reminderContenTextView: UITextView = {
       let t = UITextView()
        t.layer.cornerRadius = 6
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.black.cgColor
        t.textColor = .black
        t.adjustsFontForContentSizeCategory = true
        t.font = UIFont.preferredFont(forTextStyle: .body)
        t.backgroundColor = .white
        t.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return t
    }()
    
    private lazy var reminderDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerClosed), for: .editingDidEnd)
        
        let calendar = Calendar(identifier: .gregorian)
        
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = 150
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .lightGray
        
        return datePicker
    }()
    
    private var saveRightButtonBar: UIBarButtonItem!
    
    static func create(with viewModel: ReminderEditViewModel) -> ReminderEditViewController {
        let view = ReminderEditViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .darkGray
        view.addSubview(rootView)
        
        saveRightButtonBar = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(saveReminder))
        self.navigationItem.rightBarButtonItem = saveRightButtonBar
        

        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func bind() {
        // We don't need to observe the title and the content because
        // We just set their initial values and update on save.
        reminderTitleTextField.text = viewModel.reminderTitle
        reminderContenTextView.text = viewModel.reminderContent
        
        // we need to observe the reminderImage and Date because they
        // are going to change upon user action and we need to reflect this changes,
        // regardless if the user will save the Reminder or not.
        viewModel.reminderImageData.observe(on: self) { [weak self] in
            self?.setReminderButtonImage(data: $0)
        }
        viewModel.reminderDate.observe(on: self) { [weak self] in
            self?.setReminderDate($0)
        }
        
        // Show an alert on error
        viewModel.saveError.observe(on: self) { [weak self] in
            self?.showError($0)
        }
    }

    private func layout(keyboardHeight: CGFloat = 0) {
        
        // Auto Layout vs Pinlayout
        
        // MARK: - Auto Layout
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        reminderImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reminderImageButton.widthAnchor.constraint(equalToConstant: 44),
            reminderImageButton.heightAnchor.constraint(equalToConstant: 44),
            reminderImageButton.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 16),
            reminderImageButton.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 16),
        ])
        
        reminderTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reminderTitleTextField.heightAnchor.constraint(equalToConstant: 44),
            reminderTitleTextField.leadingAnchor.constraint(equalTo: reminderImageButton.trailingAnchor, constant: 16),
            reminderTitleTextField.centerYAnchor.constraint(equalTo: reminderImageButton.centerYAnchor),
            reminderTitleTextField.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -16),
        ])
        
        reminderDatePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reminderDatePicker.topAnchor.constraint(equalTo: reminderImageButton.bottomAnchor, constant: 14),
            reminderDatePicker.leadingAnchor.constraint(equalTo: reminderImageButton.leadingAnchor),
            reminderDatePicker.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: 16),
            reminderDatePicker.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        reminderContenTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reminderContenTextView.topAnchor.constraint(equalTo: reminderDatePicker.bottomAnchor, constant: 14),
            reminderContenTextView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 16),
            reminderContenTextView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -16),
            reminderContenTextView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -(keyboardHeight+16))
        ])
                
        // MARK: - PinLayout
        // Uncomment the following few lines of code and comment out all the previous Code
        // They produce he same results but this has the following advantages:
        // 1. Less code to write
        // 2. Less error prone
        // 3. Up to 10x more performance. Particularly within a UITableView with lot of UITableViewCell (Or UICollactionView)
        
//        rootView.pin.all(view.pin.safeArea)
//        reminderImageButton.pin.size(CGSize(width: 44, height: 44)).top(16).start(16)
//        reminderTitleTextField.pin.height(44).after(of: reminderImageButton, aligned: .center).marginStart(12).end(16)
//        reminderDatePicker.pin.below(of: reminderImageButton, aligned: .start).end(16).marginTop(14)
//        reminderContenTextView.pin.below(of: reminderDatePicker).marginTop(14).bottom(keyboardHeight + 16).horizontally(16)

        reminderImageButton.layer.cornerRadius = reminderImageButton.frame.size.height / 2
        
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let newHeight = UIScreen.main.bounds.height - endFrame.origin.y - view.safeAreaInsets.bottom
        guard keyboardHeight != newHeight else { return }
        keyboardHeight = newHeight < 0 ? 0 : newHeight
        
        reminderContenTextView.contentInset.bottom = keyboardHeight
        
        // Using PinLayout is very easy to resize the reminderContenTextView instead of manupilating its content inset.
//        layout(keyboardHeight: keyboardHeight)
    }
    
    @objc private func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc private func selectDate() {
        
    }
    
    @objc private func selectImage() {
        reminderTitleTextField.resignFirstResponder()
        reminderContenTextView.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.permittedArrowDirections = .down
        
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { _ in
            self.openCamera()
        }
        let libraryAction = UIAlertAction(title: "Photos".localized(), style: .default) { _ in
            self.openGallery()
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func openGallery() {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(datePicker: UIDatePicker) {
        viewModel.didSelectReminderDate(date: datePicker.date)
    }
    
    @objc private func datePickerClosed(datePicker: UIDatePicker) {
        print("Date picker closed")
        layout()
    }
    
    @objc private func saveReminder() {
        viewModel.didSaveReminder(title: reminderTitleTextField.text, content: reminderContenTextView.text)
    }
    
    private func setReminderButtonImage(data: Data?) {
        guard let imageData = data else {
            reminderImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
            return
        }
        reminderImageButton.setImage(UIImage(data: imageData), for: .normal)
    }
    
    private func setReminderDate(_ date: Date?) {
        guard let date = date else { return }
        reminderDatePicker.date = date
    }
    
}

extension ReminderEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 35 characters
        return updatedText.count <= 35
    }
}

extension ReminderEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        
        var newImage: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        guard let data = newImage.jpegData(compressionQuality: 0.4) else {
            return
        }
        viewModel.didSelectImage(data: data)
        
    }
}

