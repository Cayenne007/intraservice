//
//  Log.swift
//  intraservice
//
//  Created by user184795 on 20.12.2020.
//

import Foundation

struct Logger {

    static var file: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("log.txt")
    }
    
    
    static func log(text: String) {
        if let handle = try? FileHandle(forWritingTo: Logger.file) {
            handle.seekToEndOfFile()
            let log = (Date().toString("yyyy-MM-dd HH:mm:ss")+"  "+text+"\n").data(using: .utf8)!
            handle.write(log)
            handle.closeFile()
        } else {
            try? text.data(using: .utf8)?.write(to: Logger.file)
        }
    }

}
