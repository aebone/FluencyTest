import UIKit

class ResultViewController: UIViewController {

    var levenshtein: Double!
    var damerauLevenshtein: Double!
    var jaroWinkler: Double!
    var average: Double!
    var locale: String!
    
    @IBOutlet weak var levenshteinLabel: UILabel!
    @IBOutlet weak var damerauLevenshteinLabel: UILabel!
    @IBOutlet weak var jaroWinklerLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var localeLabel: UILabel!
    
    var grade: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateAverage()
        calculateGrade()
        
        gradeLabel.text = "Your score is: \(grade!)"
        levenshteinLabel.text = "Levenshtein: \(String(format: "%.2f", levenshtein))"
        damerauLevenshteinLabel.text = "Damerau Levenshtein: \(String(format: "%.2f", damerauLevenshtein))"
        jaroWinklerLabel.text = "Jaro Winkler: \(String(format: "%.2f", jaroWinkler))"
        averageLabel.text = "Average: \(String(format: "%.2f", average))"
        
        localeLabel.text = self.locale
    }
    
    func calculateAverage() {
        self.average = (self.damerauLevenshtein + self.jaroWinkler + self.levenshtein) / 3
    }
    
    func calculateGrade() {
        if average >= 90 && average <= 100 {
            self.grade = "A+"
        } else if average >= 85 && average <= 89 {
            self.grade = "A"
        } else if average >= 80 && average <= 84 {
            self.grade = "A-"
        } else if average >= 77 && average <= 79 {
            self.grade = "B+"
        } else if average >= 73 && average <= 76 {
            self.grade = "B"
        } else if average >= 70 && average <= 72 {
            self.grade = "B-"
        } else if average >= 65 && average <= 69 {
            self.grade = "C+"
        } else if average >= 60 && average <= 64 {
            self.grade = "C"
        } else if average >= 55 && average <= 59 {
            self.grade = "C-"
        } else if average >= 50 && average <= 54 {
            self.grade = "D"
        } else if average >= 0 && average <= 49 {
            self.grade = "F"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ViewController {
            viewController.locale = locale
        }
    }}
