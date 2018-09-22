//
//  ResultViewController.swift
//  FluencyTest
//
//  Created by Aline Ebone on 18/09/18.
//  Copyright © 2018 Aline Ebone. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var levenshtein: Double!
    var damerauLevenshtein: Double!
    var jaroWinkler: Double!
    
    @IBOutlet weak var levenshteinLabel: UILabel!
    @IBOutlet weak var damerauLevenshteinLabel: UILabel!
    @IBOutlet weak var jaroWinklerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levenshteinLabel.text = "Levenshtein: \(String(levenshtein))"
        damerauLevenshteinLabel.text = "Damerau Levenshtein: \(String(damerauLevenshtein))"
        jaroWinklerLabel.text = "Jaro Winkler: \(String(jaroWinkler))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
