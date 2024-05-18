//
//  GridCollectionViewCell.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import UIKit
import Kingfisher

final public class GridCollectionViewCell: UICollectionViewCell {
    static let id = "GridCollectionViewCell"
    private let imageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        return imageView
    }()
    private let nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    private let emailLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .thin)
        return label
    }()
    private let checkButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(checkButton)
        addSubview(nameLabel)
        addSubview(emailLabel)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(120)
        }
        checkButton.snp.makeConstraints { make in
            make.top.leading.equalTo(imageView).offset(10)
            make.width.height.equalTo(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        emailLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    public func apply(user: User, isSelected: Bool) {
        imageView.kf.setImage(with: user.picture.mediumURL)
        nameLabel.text = user.fullName
        emailLabel.text = user.email
        checkButton.isHidden = !isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

