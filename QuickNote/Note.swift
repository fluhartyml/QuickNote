//
//  Note.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var dateCreated: Date
    var body: String
    var dateModified: Date
    @Attribute(.externalStorage) var imageData: [Data]

    init(title: String = "", dateCreated: Date = .now, body: String = "", dateModified: Date = .now, imageData: [Data] = []) {
        self.title = title
        self.dateCreated = dateCreated
        self.body = body
        self.dateModified = dateModified
        self.imageData = imageData
    }
}
