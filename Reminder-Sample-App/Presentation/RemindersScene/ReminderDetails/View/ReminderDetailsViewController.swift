//
//  ReminderDetailsViewController.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import UIKit

class ReminderDetailsViewController: UIViewController {
    
    private lazy var rootView: UIView = {
        let v = UIView()
        v.addSubview(reminderTitleTextField)
        v.addSubview(reminderDateLabel)
        v.addSubview(reminderContentTextView)
        v.addSubview(reminderImageView)
        v.addSubview(closeImageButton)
        return v
    }()
    
    private lazy var reminderImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.borderWidth = 1
        i.layer.borderColor = UIColor.black.cgColor
        i.backgroundColor = .white
        i.tintColor = .darkGray
        i.layer.shadowRadius = 2.0
        i.layer.shadowOffset = CGSize(width: 0, height: 2) // Use any CGSize
        i.layer.shadowColor = UIColor.gray.cgColor
        i.layer.shadowOpacity = 0.4
        i.layer.masksToBounds = false
        i.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openImage))
        i.isUserInteractionEnabled = true
        i.addGestureRecognizer(tapGestureRecognizer)
        
        return i
    }()
    
    private lazy var closeImageButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(closeImage), for: .touchUpInside)
        b.isHidden = true
        return b
    }()
    
    private lazy var reminderTitleTextField: UITextField = {
        let t = UITextField()
        t.isUserInteractionEnabled = false
        
        t.layer.cornerRadius = 6
        t.layer.shadowRadius = 2.0
        t.layer.shadowOffset = CGSize(width: 0, height: 2) // Use any CGSize
        t.layer.shadowColor = UIColor.gray.cgColor
        t.layer.shadowOpacity = 0.4
        t.layer.masksToBounds = false
        
        t.textColor = .white
        t.backgroundColor = .clear
        t.adjustsFontForContentSizeCategory = true
        t.font = UIFont.preferredFont(forTextStyle: .body)
        t.setLeftPaddingPoints(10)
        t.setRightPaddingPoints(10)
        t.placeholder = "Title".localized()
        return t
    }()
    
    private lazy var reminderContentTextView: UITextView = {
        let t = UITextView()
        t.isEditable = false
        t.layer.cornerRadius = 6
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.white.cgColor
        t.textColor = .white
        t.adjustsFontForContentSizeCategory = true
        t.font = UIFont.preferredFont(forTextStyle: .body)
        t.backgroundColor = .clear
        t.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return t
    }()
    
    private let reminderDateLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.font = UIFont.preferredFont(forTextStyle: .body).semibold
        l.textColor = .white
        l.adjustsFontForContentSizeCategory = true
        return l
    }()
    
    
    private var saveRightButtonBar: UIBarButtonItem!
    
    private var viewModel:ReminderDetailsViewModel!
    
    static func create(with viewModel: ReminderDetailsViewModel) -> ReminderDetailsViewController {
        let view = ReminderDetailsViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    private func setup() {
        let editRightButtonBar = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(editReminder))
        
        let deleteRightButtonBar = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(deleteReminder))
        self.navigationItem.rightBarButtonItems = [editRightButtonBar, deleteRightButtonBar]

        view.backgroundColor = .darkGray
        view.addSubview(rootView)
    }
    
    private func bind() {
        viewModel.reminder.observe(on: self) { [weak self] in
            self?.reminderTitleTextField.text = $0.title
            self?.reminderContentTextView.text = $0.content
            if let date = $0.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                self?.reminderDateLabel.text = formatter.string(from: date)
            }
            if let imageData = $0.imageData {
                self?.reminderImageView.contentMode = .scaleAspectFill
                self?.reminderImageView.image = UIImage(data: imageData)
            } else {
                self?.reminderImageView.contentMode = .center
                self?.reminderImageView.image = UIImage(systemName: "photo")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func layout() {
        rootView.pin.all(view.pin.safeArea)
        
        // make sure the label height is always updated even if the phone use big font
        // and zoomed view.
        reminderDateLabel.sizeToFit()
        
        reminderImageView.pin
            .size(CGSize(width: 44, height: 44))
            .top(16)
            .start(16)
        
        closeImageButton.pin
            .top(20)
            .end(20)
            .size(CGSize(width: 34, height: 34))
        
        reminderTitleTextField.pin
            .height(44)
            .after(of: reminderImageView, aligned: .center)
            .marginStart(12)
            .end(16)
        
        reminderDateLabel.pin
            .below(of: reminderImageView, aligned: .start)
            .marginTop(14)
            .end(16)
        
        reminderContentTextView.pin
            .below(of: reminderDateLabel)
            .marginTop(14)
            .bottom(16)
            .horizontally(16)
        
        reminderImageView.layer.cornerRadius = reminderImageView.frame.size.height / 2
    }
    
    @objc private func openImage() {
        guard let _ = viewModel.reminder.value.imageData else {
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.reminderImageView.contentMode = .scaleAspectFit
            self.reminderImageView.backgroundColor = .black
            self.reminderImageView.pin.all()
        } completion: { (_) in
            self.closeImageButton.isHidden = false
        }
        reminderImageView.animateCornerRadius(from: reminderImageView.layer.cornerRadius,
                                              to: 0,
                                              duration: 0.2)
    }
    
    @objc private func closeImage() {
        self.closeImageButton.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.reminderImageView.contentMode = .scaleAspectFill
            self.reminderImageView.backgroundColor = .white
        
            self.reminderImageView.pin
                .size(CGSize(width: 44, height: 44))
                .top(16)
                .start(16)
        } completion: { (_) in
            
        }
        reminderImageView.animateCornerRadius(from: reminderImageView.layer.cornerRadius,
                                              to: 22,
                                              duration: 0.2)
    }
    
    @objc private func editReminder() {
        closeImage()
        viewModel.didSelectEdit()
    }
    
    @objc private func deleteReminder() {
        let alertController = UIAlertController(title: "Do you want to delete this Reminder?".localized(), message: nil, preferredStyle: .actionSheet)
        let deleteReminderAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] _ in
            self?.viewModel.didSelectDelete()
        }
        alertController.addAction(deleteReminderAction)
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIView {
    func animateCornerRadius(from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.fillMode = .forwards;
        animation.isRemovedOnCompletion = false;
        layer.add(animation, forKey: "cornerRadius")
        CATransaction.commit()
    }
}
