//
//  ListCollectionViewCell.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//
import UIKit

final class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCollectionViewCell"
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
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(emailLabel)
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(100)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.top.trailing.equalToSuperview().inset(10)
        }
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    public func apply(user: User) {
        imageView.kf.setImage(with: user.picture.mediumURL)
        nameLabel.text = user.fullName
        emailLabel.text = user.email
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


