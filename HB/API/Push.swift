//


import Foundation

let fcmUrl = "https://fcm.googleapis.com/fcm/send"

func sendRequestNotification(toUid: String, title: String, subtitle: String, type: String, linkId: String, badge: Int) {
    var request = URLRequest(url: URL(string: fcmUrl)!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("key=\(Constants.Links.serverKey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let notification: [String: Any] = [
        "to" : "/topics/\(toUid)",
        "notification" : [
            "title": title,
            "body": subtitle,
            "sound": "default",
            "badge": badge
        ],
        "data": [
            "type": type,
            "linkId": linkId
        ]
    ]
    
    let data = try! JSONSerialization.data(withJSONObject: notification, options: [])
    request.httpBody = data
    
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else { return }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            debugPrint("HttpUrlResponse \(httpResponse.statusCode)")
            debugPrint("response \(response!)")
        }
        
        if let responseString = String(data: data, encoding: String.Encoding.utf8) {
            debugPrint("responseString \(responseString)")
        }
    }.resume()
    
}
