//
//  StringExt.swift
//  FluencyTest
//
//  Created by Aline Ebone on 17/09/18.
//  Copyright © 2018 Aline Ebone. All rights reserved.
//

import UIKit

extension String {
    func index(_ i: Int) -> String.CharacterView.Index {
        if i >= 0 {
            return self.index(self.startIndex, offsetBy: i)
        } else {
            return self.index(self.endIndex, offsetBy: i)
        }
    }
    
    subscript(i: Int) -> Character? {
        if i >= count || i < -count {
            return nil
        }
        
        return self[index(i)]
    }
    
    subscript(r: Range<Int>) -> String {
        return String(self[index(r.lowerBound)..<index(r.upperBound)])
    }
}
