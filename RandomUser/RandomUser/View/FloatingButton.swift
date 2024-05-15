//
//  FloatingButton.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import UIKit

final class FloatingButton: UIButton {
   
    init(title: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        configuration = config
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
