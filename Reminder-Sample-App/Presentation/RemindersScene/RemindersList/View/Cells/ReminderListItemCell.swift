//
//  ReminderCell.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import Foundation
import UIKit
import PinLayout

class ReminderListItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ReminderListItemCell.self)
    static let height = CGFloat(120)
    private let padding: CGFloat = 10
    
    private let reminderTitleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .body).bold
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .black
        return l
    }()
    
    private let reminderContentLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .footnote)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .gray
        return l
    }()
    
    private let reminderDateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .caption1)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .gray
        return l
    }()
    
    private let reminderImageView: UIImageView = {
        let i = UIImageView(image: UIImage(systemName: "photo"))
        i.contentMode = .center
        i.tintColor = .darkGray
        i.layer.borderWidth = 1
        i.layer.borderColor = UIColor.darkGray.cgColor
        i.clipsToBounds = true
        return i
    }()
    
    private lazy var rootView: UIView = {
        let v = UIView()
        v.addSubview(reminderTitleLabel)
        v.addSubview(reminderContentLabel)
        v.addSubview(reminderImageView)
        v.addSubview(reminderDateLabel)
        return v
    }()
    
    
    var viewModel: RemindersListItemViewModel! {
        didSet {
            reminderDateLabel.text = viewModel.date
            reminderTitleLabel.text = viewModel.title
            reminderContentLabel.text = viewModel.content
            
            if let imageData = viewModel.imageData {
                reminderImageView.image = UIImage(data: imageData)
                reminderImageView.contentMode = .scaleAspectFill
            }
            
            if let date = viewModel.reminder.date {
                if date.isInPast {
                    rootView.backgroundColor = UIColor(rgbHex: 0xb8f5bd)
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rootView.backgroundColor = .white
        reminderImageView.image = UIImage(systemName: "photo")
        reminderImageView.contentMode = .center
        reminderContentLabel.text = ""
        reminderDateLabel.text = ""
        reminderTitleLabel.text = ""
    }
    
    private func setup() {
        contentView.addSubview(rootView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        
        // Simple size to fit because they are all 1 line labels and don't
        // need to resize the width based on the content.
        reminderDateLabel.sizeToFit()
        reminderTitleLabel.sizeToFit()
        reminderContentLabel.sizeToFit()
        
        rootView.pin.all()
        
        let leftRightPadding:CGFloat = 14
        
        reminderImageView.pin
            .size(CGSize(width: 44, height: 44))
            .top(padding)
            .start(leftRightPadding)
        
        reminderTitleLabel.pin
            .after(of: reminderImageView, aligned: .top)
            .marginTop(-1)
            .marginStart(10)
            .end(leftRightPadding)
        
        reminderDateLabel.pin
            .below(of: reminderTitleLabel, aligned: .end)
            .marginTop(4)
            .sizeToFit(.content)
        
        reminderContentLabel.pin
            .horizontallyBetween(reminderImageView, and: reminderDateLabel)
            .marginHorizontal(10)
            .vCenter(to: reminderDateLabel.edge.vCenter)
            

        reminderImageView.layer.cornerRadius = reminderImageView.frame.size.height / 2
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width,
                      height: reminderImageView.frame.maxY + padding)
    }
    
}

