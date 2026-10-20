//
//  DateFormatterUtility.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 14/10/26.
//

import Foundation

enum DateFormatterUtility {

    static func formattedNoteDate(_ value: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        var parsedDate: Date?

        for format in formats {
            inputFormatter.dateFormat = format

            if let date = inputFormatter.date(from: value) {
                parsedDate = date
                break
            }
        }

        guard let parsedDate else {
            return value
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = .current
        outputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short

        return outputFormatter.string(from: parsedDate)
    }
}
