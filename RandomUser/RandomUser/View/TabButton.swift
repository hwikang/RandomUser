//
//  TabButton.swift
//  RandomUser
//
//  Created by paytalab on 5/14/24.
//

import UIKit

final class TabButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .systemBlue
            } else {
                backgroundColor = .white
            }
        }
    }
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        setTitleColor(.black, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
