//
//  DonateSheetContainerViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

final class DonateSheetContainerViewController: UIViewController {
    
    var onDismiss: (() -> Void)?
    
    private let dimView = UIView()
    private let cardView = UIView()
    private let grabber = UIView()
    
    private let content: UIViewController
    private let tabBarHeight: CGFloat
    
    private var cardBottom: NSLayoutConstraint!
    private var cardHeight: NSLayoutConstraint!
    private var cardLeading: NSLayoutConstraint!
    private var cardTrailing: NSLayoutConstraint!
    
    private var didNotifyDismiss = false
    
    init(content: UIViewController, tabBarHeight: CGFloat) {
        self.content = content
        self.tabBarHeight = tabBarHeight
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // Dim
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        dimView.alpha = 0
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 28
        cardView.layer.masksToBounds = true
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardBottom = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                      constant: -(tabBarHeight + 10))
        cardLeading = cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        cardTrailing = cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        cardHeight = cardView.heightAnchor.constraint(equalToConstant: 600)
        
        NSLayoutConstraint.activate([cardBottom, cardLeading, cardTrailing, cardHeight])
        
        // Grabber
        grabber.backgroundColor = UIColor.systemGray4
        grabber.layer.cornerRadius = 2.5
        cardView.addSubview(grabber)
        grabber.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            grabber.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 54),
            grabber.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        // Content
        addChild(content)
        cardView.addSubview(content.view)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 6),
            content.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            content.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        content.didMove(toParent: self)
        
        // Tap outside dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMe))
        dimView.addGestureRecognizer(tap)
        
        // Pan down dismiss
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cardView.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maxH = view.bounds.height - (tabBarHeight + 10) - 24
        let target = min(740, max(540, maxH * 0.85))
        cardHeight.constant = target
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cardView.transform = CGAffineTransform(translationX: 0, y: 320)
        UIView.animate(withDuration: 0.22) {
            self.dimView.alpha = 1
            self.cardView.transform = .identity
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            notifyDismissIfNeeded()
        }
    }
    
    private func notifyDismissIfNeeded() {
        guard !didNotifyDismiss else { return }
        didNotifyDismiss = true
        onDismiss?()
    }
    
    @objc private func dismissMe() {
        UIView.animate(withDuration: 0.18, animations: {
            self.dimView.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 320)
        }, completion: { _ in
            self.dismiss(animated: false) {
                self.notifyDismissIfNeeded()
            }
        })
    }
    
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        let t = g.translation(in: view)
        let y = max(0, t.y)
        
        switch g.state {
        case .changed:
            cardView.transform = CGAffineTransform(translationX: 0, y: y)
            dimView.alpha = max(0, 1 - (y / 350))
            
        case .ended, .cancelled:
            let v = g.velocity(in: view).y
            if y > 140 || v > 900 {
                dismissMe()
            } else {
                UIView.animate(withDuration: 0.18) {
                    self.cardView.transform = .identity
                    self.dimView.alpha = 1
                }
            }
            
        default:
            break
        }
    }
}
