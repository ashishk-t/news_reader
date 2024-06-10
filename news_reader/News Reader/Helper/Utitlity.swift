//
//  Utitlity.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation
import UIKit

// MARK: - View Helper

struct Utitlity {
  
    private static var imageCache: NSCache<NSString, UIImage> = NSCache()

    static func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        let placeholder = UIImage(named: "placeholderimage")
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(placeholder)
                return
            }

            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                completion(image)
            } else {
                completion(placeholder)
            }
        }.resume()
    }
    
  // Create a Label
  static func createLabel(with color: UIColor, text: String, alignment: NSTextAlignment, font: UIFont) -> UILabel {
    
    let newLabel = UILabel()
    newLabel.textColor = color
    newLabel.text = text
    newLabel.textAlignment = alignment
    newLabel.font = font
    newLabel.translatesAutoresizingMaskIntoConstraints = false
    newLabel.adjustsFontSizeToFitWidth = true
    return newLabel
  }
  
  // Create a Stack View
  static func createStackView(_ axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = axis
    stackView.distribution = distribution
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }
  
  // Create an ImageView
  static func createImageView() -> UIImageView {
    let newImageView = UIImageView()
    newImageView.contentMode = .scaleAspectFill
    newImageView.backgroundColor = .clear
    newImageView.translatesAutoresizingMaskIntoConstraints = false
    return newImageView
  }
    
    static func getTimeAgo(dateString: String) -> String {
        let date = Utitlity.dateFromISO8601String(dateString)
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date ?? Date(), to: now)

        if let dayDifference = components.day, dayDifference > 0 {
            return "\(dayDifference) day\(dayDifference == 1 ? "" : "s") ago"
        } else if let hourDifference = components.hour, hourDifference > 0 {
            return "\(hourDifference) hour\(hourDifference == 1 ? "" : "s") ago"
        } else if let minuteDifference = components.minute, minuteDifference > 0 {
            return "\(minuteDifference) minute\(minuteDifference == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
    
    static func dateFromISO8601String(_ dateString: String) -> Date? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate        ]

        return isoDateFormatter.date(from: dateString)
    }
  
}
