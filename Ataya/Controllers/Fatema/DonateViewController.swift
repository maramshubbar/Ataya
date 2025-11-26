//
//  DonateViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//

import UIKit

class DonateViewController: UIViewController {

    @IBOutlet weak var card1: UIView!
    @IBOutlet weak var card2: UIView!
    @IBOutlet weak var card3: UIView!
    @IBOutlet weak var card4: UIView!
    @IBOutlet weak var card5: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply the style to all cards
        styleCard(card1)
        styleCard(card2)
        styleCard(card3)
        styleCard(card4)
        styleCard(card5)
   
    }
        
    // MARK: - Style Function (shadow + corner radius)
        func styleCard(_ card: UIView) {
            card.layer.cornerRadius = 10
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
            card.layer.shadowRadius = 14
            card.layer.masksToBounds = false
        }

        // MARK: - Perfect shadow path rendering
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            let cards = [card1, card2, card3, card4, card5]

            for card in cards {
                card?.layer.shadowPath = UIBezierPath(
                    roundedRect: card!.bounds,
                    cornerRadius: 24
                ).cgPath
            }
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
