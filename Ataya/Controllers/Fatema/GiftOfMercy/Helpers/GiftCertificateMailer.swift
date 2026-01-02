//
//  GiftCertificateMailer.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import UIKit
import MessageUI

final class GiftCertificateMailer: NSObject, MFMailComposeViewControllerDelegate {

    static let shared = GiftCertificateMailer()
    private override init() { super.init() }

    // ✅ يكتب الاسم (والهدية/من اختياري) على الشهادة في المكان اللي تحت يمين
    func makeCertificateImage(base: UIImage,
                              recipientName: String,
                              giftName: String? = nil,
                              fromName: String? = nil) -> UIImage {

        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)

        return renderer.image { _ in
            // 1) ارسم الشهادة الأصلية
            base.draw(in: CGRect(origin: .zero, size: base.size))

            // 2) إعدادات النص
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left
            paragraph.lineBreakMode = .byTruncatingTail

            let font = UIFont.systemFont(ofSize: base.size.width * 0.035, weight: .semibold)

            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]

            // ✅ مكان الكتابة (الخطوط يمين تحت)
            let x = base.size.width * 0.36
            let w = base.size.width * 0.56
            let lineH = base.size.height * 0.035

            // ✅ هذي القيم تضبط مكان السطور
            let y1 = base.size.height * 0.835   // السطر 1 (Recipient)
            let y2 = base.size.height * 0.875   // السطر 2 (Name of Gift)
            let y3 = base.size.height * 0.915   // السطر 3 (From)

            // 3) اكتب الاسم على أول سطر
            (recipientName as NSString).draw(in: CGRect(x: x, y: y1, width: w, height: lineH), withAttributes: attrs)

            // (اختياري) اسم الهدية على ثاني سطر
            if let giftName, !giftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                (giftName as NSString).draw(in: CGRect(x: x, y: y2, width: w, height: lineH), withAttributes: attrs)
            }

            // (اختياري) From على ثالث سطر
            if let fromName, !fromName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                (fromName as NSString).draw(in: CGRect(x: x, y: y3, width: w, height: lineH), withAttributes: attrs)
            }
        }
    }

    // ✅ يفتح Mail ويجهز الايميل ويرفق الشهادة
    func presentMail(from vc: UIViewController,
                     to email: String,
                     recipientName: String,
                     certificateBaseImage: UIImage,
                     giftName: String? = nil,
                     fromName: String? = nil) {

        guard MFMailComposeViewController.canSendMail() else {
            print("❌ Mail مو متسوي بالجهاز (Settings > Mail > Accounts)")
            return
        }

        let finalImage = makeCertificateImage(
            base: certificateBaseImage,
            recipientName: recipientName,
            giftName: giftName,
            fromName: fromName
        )

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self

        mail.setToRecipients([email])
        mail.setSubject("Gift of Mercy Certificate ✅")

        let body = """
        Hi \(recipientName),

        Please find the certificate attached.

        Regards,
        Ataya
        """
        mail.setMessageBody(body, isHTML: false)

        if let data = finalImage.pngData() {
            mail.addAttachmentData(data, mimeType: "image/png", fileName: "certificate.png")
        }

        vc.present(mail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
        if let error = error {
            print("❌ Mail error:", error.localizedDescription)
        }
    }
}
