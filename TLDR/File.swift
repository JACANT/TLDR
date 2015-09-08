//
//  File.swift
//  TLDR
//
//  Created by Anthony Yu on 9/1/15.
//  Copyright (c) 2015 Anthony Yu. All rights reserved.
//

import Foundation

class File {
    class func open (path: String, utf8: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        var error: NSError?
        return NSFileManager().fileExistsAtPath(path) ? String(contentsOfFile: path, encoding: utf8, error: &error)! : nil
    }
    class func save (path: String, _ content: String, utf8: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        var error: NSError?
        return content.writeToFile(path, atomically: true, encoding: utf8, error: &error)
    }
}
