import Foundation

class EmailService {
    static let senderEmail = "gigsyncingapp@gmail.com"
    static let senderName = "GigSync"
    
    static func sendGigNotification(gig: Gig, to emails: [String]) {
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Filter out any test domain emails
        let validEmails = emails.filter { email in
            !email.hasSuffix(".test")
        }
        
        let htmlContent = """
        <html>
            <body>
                <h2>New Gig Details</h2>
                <p><strong>Event:</strong> \(gig.title)</p>
                <p><strong>Date:</strong> \(gig.formattedDate)</p>
                <p><strong>Venue:</strong> \(gig.venue)</p>
                <br>
                <p><strong>Additional Information:</strong></p>
                <p>\(gig.notes)</p>
                <br>
                <p>Please update your attendance status in the GigSync app.</p>
                <hr>
                <p style="color: #666; font-size: 12px;">
                    You received this email because you're a member of this band.<br>
                    To unsubscribe from these notifications, <a href="%unsubscribe%">click here</a>
                </p>
            </body>
        </html>
        """
        
        let emailData: [String: Any] = [
            "personalizations": [
                [
                    "to": validEmails.map { ["email": $0] },
                    "subject": "New Gig: \(gig.title)"
                ]
            ],
            "from": [
                "email": senderEmail,
                "name": senderName
            ],
            "reply_to": [
                "email": senderEmail,
                "name": senderName
            ],
            "subject": "New Gig: \(gig.title)",
            "content": [
                [
                    "type": "text/html",
                    "value": htmlContent
                ]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: emailData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📧 SendGrid Status Code:", httpResponse.statusCode)
                if let data = data {
                    print("📧 SendGrid Response:", String(data: data, encoding: .utf8) ?? "No response data")
                }
            }
            if let error = error {
                print("📧 SendGrid Error:", error.localizedDescription)
            }
        }.resume()
    }
}
