//
//  PasswordValidation.swift
//
//  Created by Jeff Potter on 11/13/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

/**
 `PasswordRule` is a subclass of RegexRule that defines how a password is validated.
 */
public class PasswordRule : RegexRule {
    
    // Alternative Regexes
    
    // 6 characters. One uppercase. One Lowercase. One number.
//    static let regex = "^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[a-z]).{8,}$"
    //
    // no length. One uppercase. One lowercae. One number.
    // static let regex = "^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[a-z]).*?$"
    
    /// Regular express string to be used in validation.
    static let regex = "^.{6,}$"

    /**
     Initializes a `PasswordRule` object that will validate a text field is a valid password.
     
     - parameter message: String of error message.
     - returns: An initialized `PasswordRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    //here comment
    //one lowercase, uppercase, number, special character and
    public convenience init(message : String =  "Password must be at least 6 characters long.") {
        self.init(regex: PasswordRule.regex, message : message)        
    }}
