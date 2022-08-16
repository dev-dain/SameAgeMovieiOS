//
//  FooterView.swift
//  SameAgeMovie
//
//  Created by Dain Kim on 2022/08/16.
//

import UIKit
import SnapKit

class FooterView: UITableViewHeaderFooterView {
    private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "여기까지입니다"
        label.font = .systemFont(ofSize: 16.0, weight: .bold)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupFooterView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFooterView() {
        contentView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
