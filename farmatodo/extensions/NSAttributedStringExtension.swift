//
//  NSAttributedStringExtension.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    class func fromString(string: String, lineHeightMultiple: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.baselineOffset: -1], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
}
