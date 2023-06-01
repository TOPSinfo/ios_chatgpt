//
//  AppConstant.swift
//  chatGPTDemo
//
//  Created by Nand on 24/03/23.
//

import Foundation
//MARK:- OpenAISecretKey
struct OpenAISecretKey {
    public static let SECRETKEY = "ENTER-YOUR-SECRETE-KEY-HERE"
//    public static let SECRETKEY = "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"
}

//MARK:- String Extension
extension String {
    
    func trime() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
