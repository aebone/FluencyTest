extension String {
    
    /**
     Get Levenshtein distance between target.
     Reference <https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows>.
     - parameter target: target string
     - returns: Levenshtein distance
     */
    public func distanceLevenshtein(between target: String) -> Int {
        if self == target {
            return 0
        }
        if self.count == 0 {
            return target.count
        }
        if target.count == 0 {
            return self.count
        }
        
        // The previous row of distances
        var v0 = [Int](repeating: 0, count: target.count + 1)
        // Current row of distances.
        var v1 = [Int](repeating: 0, count: target.count + 1)
        // Initialize v0.
        // Edit distance for empty self.
        for i in 0..<v0.count {
            v0[i] = i
        }
        
        for i in 0..<self.count {
            // Calculate v1 (current row distances) from previous row v0
            // Edit distance is delete (i + 1) chars from self to match empty t.
            v1[0] = i + 1
            
            // Use formula to fill rest of the row.
            for j in 0..<target.count {
                let cost = self[j] == target[j] ? 0 : 1
                v1[j + 1] = Swift.min(
                    v1[j] + 1,
                    v0[j + 1] + 1,
                    v0[j] + cost
                )
            }
            
            // Copy current row to previous row for next iteration.
            for j in 0..<v0.count {
                v0[j] = v1[j]
            }
        }
        
        return v1[target.count]
    }
    
    
    func levDis(between target: String) -> Int {
        
        let (t, s) = (target.characters, self.characters)
        
        let empty = Array<Int>(repeating:0, count: s.count)
        var last = [Int](0...s.count)
        
        for (i, tLett) in t.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in s.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }
        return last.last!
    }
    
    
    /**
     Get Damerau-Levenshtein distance between target.
     Reference <https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#endnote_itman#Distance_with_adjacent_transpositions>
     - parameter target: target string
     - returns: Damerau-Levenshtein distance
     */
    public func distanceDamerauLevenshtein(between target: String) -> Int {
        if self == target {
            return 0
        }
        if self.count == 0 {
            return target.count
        }
        if target.count == 0 {
            return self.count
        }
        
        var da: [Character: Int] = [:]
        
        var d = Array(repeating: Array(repeating: 0, count: target.count + 2), count: self.count + 2)
        
        let maxdist = self.count + target.count
        d[0][0] = maxdist
        for i in 1...self.count + 1 {
            d[i][0] = maxdist
            d[i][1] = i - 1
        }
        for j in 1...target.count + 1 {
            d[0][j] = maxdist
            d[1][j] = j - 1
        }
        
        for i in 2...self.count + 1 {
            var db = 1
            
            for j in 2...target.count + 1 {
                let k = da[target[j - 2]!] ?? 1
                let l = db
                
                var cost = 1
                if self[i - 2] == target[j - 2] {
                    cost = 0
                    db = j
                }
                
                let substition = d[i - 1][j - 1] + cost
                let injection = d[i][j - 1] + 1
                let deletion = d[i - 1][j] + 1
                let selfIdx = i - k - 1
                let targetIdx = j - l - 1
                let transposition = d[k - 1][l - 1] + selfIdx + 1 + targetIdx
                
                d[i][j] = Swift.min(
                    substition,
                    injection,
                    deletion,
                    transposition
                )
            }
            
            da[self[i - 2]!] = i
        }
        
        return d[self.count + 1][target.count + 1]
    }

    
    /**
     Get Jaro-Winkler distance.
     (Score is normalized such that 0 equates to no similarity and 1 is an
     exact match.)
     <https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance>
     - parameter target: target string
     - returns: Jaro-Winkler distance
     */
    public func distanceJaroWinkler(between target: String) -> Double {
        if self.count == 0 && target.count == 0 {
            return 1.0
        }
        
        let matchingWindowSize = max(self.count, target.count) / 2 - 1
        var selfFlags = Array(repeating: false, count: self.count)
        var targetFlags = Array(repeating: false, count: target.count)
        
        // Count matching characters.
        var m: Double = 0
        for i in 0..<self.count {
            let left = max(0, i - matchingWindowSize)
            let right = min(target.count - 1, i + matchingWindowSize)
            
            if left <= right {
                for j in left...right {
                    // Already has a match, or does not match
                    if targetFlags[j] || self[i] != target[j] {
                        continue;
                    }
                    
                    m += 1
                    selfFlags[i] = true
                    targetFlags[j] = true
                    break
                }
            }
        }
        
        if m == 0.0 {
            return 0.0
        }
        
        // Count transposition.
        var t: Double = 0
        var k = 0
        for i in 0..<self.count {
            if (selfFlags[i] == false) {
                continue
            }
            while (targetFlags[k] == false) {
                k += 1
            }
            if (self[i] != target[k]) {
                t += 1
            }
            k += 1
        }
        t /= 2.0
        
        // Count common prefix.
        var l: Double = 0
        for i in 0..<4 {
            if self[i] == target[i] {
                l += 1
            } else {
                break
            }
        }
        
        let dj = (m / Double(self.count) + m / Double(target.count) + (m - t) / m) / 3
        
        let p = 0.1
        let dw = dj + l * p * (1 - dj)
        
        return dw;
    }
    

}
