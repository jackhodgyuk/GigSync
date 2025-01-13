import Foundation

class EmailService {
    static let senderEmail = "gigsyncingapp@gmail.com"
    
    static func sendGigNotification(gig: Gig, to emails: [String]) {
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailContent = """
        New Gig Details:
        
        Event: \(gig.title)
        Date: \(gig.formattedDate)
        Venue: \(gig.venue)
        
        Additional Information:
        \(gig.notes)
        
        Please update your attendance status in the GigSync app.
        """
        
        let emailData: [String: Any] = [
            "personalizations": [
                ["to": emails.map { ["email": $0] }]
            ],
            "from": ["email": senderEmail],
            "subject": "New Gig: \(gig.title)",
            "content": [
                [
                    "type": "text/plain",
                    "value": emailContent
                ]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: emailData)
        
        URLSession.shared.dataTask(with: request).resume()
    }
}
