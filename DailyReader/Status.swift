//
//  Status.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/4.
//  Copyright © 2019 stoprain. All rights reserved.
//

import Foundation
import WCDBSwift

struct HomeTimeline: Codable {
  var statuses: [Status]
}

struct Status: TableDecodable, TableEncodable {
  var idstr: String
  var text: String
  var createdAt: Date
  var picUrls: [PicUrls]?
  var repostsCount: Int?
  var commentsCount: Int?
  var attitudesCount: Int?
  var source: String?
  var favorited: Bool?
  var truncated: Bool?
  var isLongText: Bool?
  var longText: String?
  var user: User?
  var retweetedStatus: RetweetedStatus?
  
  enum CodingKeys: String, CodingTableKey {
    typealias Root = Status
    static let objectRelationalMapping = TableBinding(CodingKeys.self)
    case idstr
    case text
    case createdAt
    case picUrls
    case repostsCount
    case commentsCount
    case attitudesCount
    case source
    case favorited
    case truncated
    case isLongText
    case longText
    case user
    case retweetedStatus
  }
}

class PicUrls: ColumnCodable, Codable {
  var thumbnailPic: String
  
  static var columnType: ColumnType {
    return .text
  }
  
  required init?(with value: FundamentalValue) {
    thumbnailPic = value.stringValue
  }
  
  func archivedValue() -> FundamentalValue {
    return FundamentalValue(thumbnailPic)
  }
}

class User: ColumnCodable, Codable {
  var idstr: String
  var name: String
  var profileImageUrl: String
  
  static var columnType: ColumnType {
    return .BLOB
  }

  required init?(with value: FundamentalValue) {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(User.self, from: value.dataValue) else {
      fatalError()
    }
    idstr = json.idstr
    name = json.name
    profileImageUrl = json.profileImageUrl
  }
  
  func archivedValue() -> FundamentalValue {
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(self) else {
      fatalError()
    }
    return FundamentalValue(data)
  }
}

class RetweetedStatus: ColumnCodable, Codable {
  var idstr: String
  var text: String
  var createdAt: Date
  var picUrls: [PicUrls]?
  var user: User?
  
  static var columnType: ColumnType {
    return .BLOB
  }
  
  enum CodingKeys: String, CodingTableKey {
    typealias Root = Status
    static let objectRelationalMapping = TableBinding(CodingKeys.self)
    case idstr
    case text
    case createdAt
    case picUrls
    case user
  }
  
  required init?(with value: FundamentalValue) {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(RetweetedStatus.self, from: value.dataValue) else {
      fatalError()
    }
    idstr = json.idstr
    text = json.text
    createdAt = json.createdAt
    picUrls = json.picUrls
    user = json.user
  }
  
  func archivedValue() -> FundamentalValue {
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(self) else {
      fatalError()
    }
    return FundamentalValue(data)
  }
}

struct CommentsShow: Codable {
  var comments: [Comment]
}

struct Comment: Codable {
  var rootidstr: String
  var text: String
  var createdAt: Date
  var user: User
  var replyComment: ReplyComment?
}

struct ReplyComment: Codable {
  var rootidstr: String
  var text: String
  var createdAt: Date
  var user: User
}

struct Favorites: Codable {
  var favorites: [Favorite]
}

struct Favorite: Codable {
  var status: Status
}
