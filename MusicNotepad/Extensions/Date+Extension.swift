//
//  Date+Extension.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 23/10/2021.
//

import Foundation

extension Date
{
    func toString(dateFormat format: String ) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
        
    }

}
