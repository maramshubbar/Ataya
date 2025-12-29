//
//  SupportTicketModelsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import UIKit

enum SupportTicketStatus: String {
    case pending = "Pending"
    case resolved = "Resolved"
}

struct SupportTicket {
    let id: String
    let status: SupportTicketStatus
    let userIssue: String
    let adminReply: String?
    let updatedAt: Date
}

final class SupportTicketCardView: UIView {

    var onViewDetails: (() -> Void)?

    private let yellow = UIColor(named: "#F7D44C")

    private let idLabel = UILabel()
    private let statusLabel = UILabel()
    private let replyTitle = UILabel()
    private let replyPreview = UILabel()
    private let viewButton = UIButton(type: .system)

    init(ticket: SupportTicket) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        fill(ticket: ticket)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.87, alpha: 1).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        idLabel.textColor = .black

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = UIColor(white: 0.25, alpha: 1)

        replyTitle.translatesAutoresizingMaskIntoConstraints = false
        replyTitle.text = "Admin Reply:"
        replyTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        replyTitle.textColor = .black

        replyPreview.translatesAutoresizingMaskIntoConstraints = false
        replyPreview.font = .systemFont(ofSize: 13, weight: .regular)
        replyPreview.textColor = UIColor(white: 0.25, alpha: 1)
        replyPreview.numberOfLines = 2

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View Details", for: .normal)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        viewButton.backgroundColor = yellow
        viewButton.layer.cornerRadius = 8
        viewButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        addSubview(idLabel)
        addSubview(statusLabel)
        addSubview(replyTitle)
        addSubview(replyPreview)
        addSubview(viewButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 130),

            idLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            idLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),

            statusLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),

            replyTitle.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            replyTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            replyTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            replyPreview.topAnchor.constraint(equalTo: replyTitle.bottomAnchor, constant: 6),
            replyPreview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            replyPreview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            viewButton.topAnchor.constraint(equalTo: replyPreview.bottomAnchor, constant: 12),
            viewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            viewButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    private func fill(ticket: SupportTicket) {
        idLabel.text = ticket.id
        statusLabel.text = "Status: \(ticket.status.rawValue)"
        replyPreview.text = "\"\(ticket.adminReply ?? "")\""
    }

    @objc private func viewTapped() {
        onViewDetails?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

}
