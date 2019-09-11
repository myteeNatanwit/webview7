//
//  my_functions.swift
//  swift_bridge
//
//  Created by Michael Tran on 8/10/2015.
//  Copyright © 2015 intcloud. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

// for Bridge
let bridge_theme = "bridge";
var myrecord = (function:"", param:"");
// myrecord = process_scheme((request.URL?.absoluteString)!);
/*
 'bridge:ios_popup?param=http://google.com';
 scheme= bride
 function = ios_popup
 param = http://google.com
*/
 func process_scheme(url: String) -> (String, String) {
    var functionName = "";
    var param = "";
    let urlString = url;
    let theme_length = bridge_theme.count + 1 ; // take into the :
    //delete first 7 chars
    var index1 = urlString.index(urlString.startIndex, offsetBy: theme_length);
    let str = urlString.substring(from: index1);
    //look for the ? char
    let needle: Character = "?";
    //if it is not nul  -> found
    if let idx = str.firstIndex(of: needle) {
 
        //take only whatever before the ?
        functionName = str.substring(to: idx);
        
        //take the whole param string
        index1 = str.index(str.startIndex, offsetBy: functionName.count);
        param=str.substring(from: index1);
        //delete the '?param=' part, it is 7 character length
        index1 = param.index(param.startIndex, offsetBy: 7);
        param=param.substring(from:index1);
        //remove the uuencode for space
        param = param.replacingOccurrences(of: "%20", with: " ", options: NSString.CompareOptions.literal, range:nil);

        print("function = " + functionName + "\n" + "param= '" + param + "'");
    }
    else {
        index1 = urlString.index(urlString.startIndex, offsetBy: theme_length);
        let str = urlString.substring(from: index1);
        functionName = str;
    }
    
    print("got an ios function call: \(functionName)");
    
    return (functionName, param);
}


// list file in document , return array of string 
// usage: var myarray = Array[]; myarray = listFiles();

func listFiles() -> [String] {
    let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true) as? [String]
    if dirs != nil {
        let dir = dirs![0]
        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: dir)
            return fileList as [String]
        }catch { }
        
    }else{
        let fileList = [""]
        return fileList
    }
    let fileList = [""]
    return fileList
    
}







