//
//  SpacedListCell.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit

final class SpacedListCell: UITableViewCell {

    private let inset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        selectionStyle = .none

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        contentView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds.inset(by: inset)
    }
}
