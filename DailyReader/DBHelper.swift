//
//  DBHelper.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/5.
//

import UIKit
import WCDBSwift

class DBHelper: NSObject {
  
  static let shared = DBHelper()
  
  var database: Database?
  
  override init() {
    super.init()
    
    create()
    
    Database.globalTrace(ofPerformance: { (tag, sqls, cost) in
        if let wrappedTag = tag {
            print("Tag: \(wrappedTag) ")
        }else {
            print("Nil tag")
        }
        sqls.forEach({ (arg) in
            print("SQL: \(arg.key) Count: \(arg.value)")
        })
        print("Total cost \(cost) nanoseconds")
    })
    
    Database.globalTrace(ofSQL: { (sql) in
        print("SQL: \(sql)")
    })
    
    Database.globalTrace(ofError: { (error) in
       switch error.type {
       case .sqliteGlobal:
           debugPrint("[WCDB][DEBUG] \(error.description)")
       case .warning:
           print("[WCDB][WARNING] \(error.description)")
       default:
           print("[WCDB][ERROR] \(error.description)")
       }
    })
  }
  
  func create() {
    if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
      let path = documentsPath + "/" + "status.db"
      print(path)
      database = Database(withPath: path)
      do {
//        try database?.drop(table: "statusTable")
        try database?.create(table: "statusTable", of: Status.self)
      } catch let error {
        print(error)
      }
    }
  }
  
  func getAll() -> [Status] {
    do {
      let order = [Status.Properties.createdAt.asOrder(by: .descending)]
      if let objects: [Status] = try database?.getObjects(fromTable: "statusTable",
                                                          orderBy: order) {
        return objects
      }
    } catch let error {
      print(error)
    }
    return []
  }

  func add(status: Status) {
    do {
      try database?.insertOrReplace(objects: status, intoTable: "statusTable")
    } catch let error {
      print(error)
    }
  }

  func close() {
    database?.close()
  }

  func getLatest() -> Status? {
    let order = [Status.Properties.createdAt.asOrder(by: .descending)]
    let status: Status? = try? database?.getObject(fromTable: "statusTable", orderBy: order)
    return status
  }

}
