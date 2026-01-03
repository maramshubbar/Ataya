//
//  MailView.swift
//  Ataya
//
//  Created by Fatema Maitham on 03/01/2026.
//


import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {

    struct Payload {
        var to: String
        var subject: String
        var body: String
    }

    let payload: Payload
    let onFinish: (MFMailComposeResult, Error?) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([payload.to])
        vc.setSubject(payload.subject)
        vc.setMessageBody(payload.body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: (MFMailComposeResult, Error?) -> Void
        init(onFinish: @escaping (MFMailComposeResult, Error?) -> Void) { self.onFinish = onFinish }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            onFinish(result, error)
            controller.dismiss(animated: true)
        }
    }
}
