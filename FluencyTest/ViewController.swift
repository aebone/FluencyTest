import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var textToReadTextView: UITextView!
    @IBOutlet weak var transcribedTextView: UITextView!
    @IBOutlet weak var startTalkingButton: UIButton!
    
    var textToRead: String = ""
    var transcribedText: String = ""
    var textToReadParameterized: String = ""
    var transcribedTextParameterized: String = ""
    
    var biggestString: Double = 0.0
    
    var levenshtein: Double = 0.0
    var damerauLevenshtein: Double = 0.0
    var jaroWinkler: Double = 0.0
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    var request: SFSpeechAudioBufferRecognitionRequest?
    var task: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        textToRead = "Testing this app"
        transcribedText = "Waiting..."
        
        textToReadTextView.text = textToRead
        transcribedTextView.text = transcribedText
    
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                    
                case .authorized: self.startTalkingButton.isEnabled = true
                self.promptLabel.text = "Tap \"Start Talking\" to dictate..."
                    
                default: self.startTalkingButton.isEnabled = false
                self.promptLabel.text = "Dictation not authorized..."
                    
                }
            }
        }
        
        startTalkingButton.isEnabled = false
        speechRecognizer.delegate = self
    }
    
    @IBAction func startTalkingButtonClicked(_ sender: Any) {
        
        if audioEngine.isRunning {
            startTalkingButton.setTitle("Start Recording", for: .normal)
            promptLabel.text = "Tap the button to dictate..."
            
            request?.endAudio()
            audioEngine.stop()
        } else {
            startTalkingButton.setTitle("Stop Recording", for: .normal)
            promptLabel.text = "Go ahead. I'm listening..."
            
            startDictation()
        }
    }
    
    
    func startDictation() {
        
        task?.cancel()
        task = nil
        
        // Initializes the request variable
        request = SFSpeechAudioBufferRecognitionRequest()
        
        // Assigns the shared audio session instance to a constant
        let audioSession = AVAudioSession.sharedInstance()
        
        // Assigns the input node of the audio engine to a constant
        let inputNode = audioEngine.inputNode
        
        // If possible, the request variable is unwrapped and assigned to a local constant
        guard let request = request else { return }
        request.shouldReportPartialResults = true
        
        // Attempts to set various attributes and returns nil if fails
        try? audioSession.setCategory(AVAudioSessionCategoryRecord)
        try? audioSession.setMode(AVAudioSessionModeMeasurement)
        try? audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        // Initializes the task with a recognition task
        task = speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let result = result else { return }
            self.transcribedText = result.bestTranscription.formattedString
            self.transcribedTextView.text = self.transcribedText
            
            if error != nil || result.isFinal {
                self.audioEngine.stop()
                self.request = nil
                self.task = nil
                
                inputNode.removeTap(onBus: 0)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startTalkingButton.isEnabled = true
        } else {
            startTalkingButton.isEnabled = false
        }
    }
    
    func calculateBiggestString(s1: String, s2:String) -> Double {
        if s1.count >= s2.count {
            return Double(s1.count)
        }
        return Double(s2.count)
    }
    
    @IBAction func checkButtonClicked(_ sender: Any) {
        
        removePontuaction()
        returnTheBiggestString()

        // distances
        let levenshteinDistance: Double = Double(textToReadParameterized.levDis(between: transcribedTextParameterized))
        let damerauLevenshteinDistance: Double = Double(textToReadParameterized.distanceDamerauLevenshtein(between: transcribedTextParameterized))
        let jaroWinklerDistance: Double = textToReadParameterized.distanceJaroWinkler(between: transcribedTextParameterized)
        
        
        print("target: \(textToReadParameterized)")
        print("to compare: \(transcribedTextParameterized)")
        print("Numero de caracteres da maior string: \(biggestString)\n")
        
        print("Levenshtein: \(levenshteinDistance)")
        print("DamerauLevenshtein: \(damerauLevenshteinDistance)")
        print("JaroWinkler: \(jaroWinklerDistance)\n")
        
        levenshtein = (1 - (levenshteinDistance/biggestString)) * 100
        damerauLevenshtein = (1 - damerauLevenshteinDistance/biggestString) * 100
        jaroWinkler = textToReadParameterized.distanceJaroWinkler(between: transcribedTextParameterized) * 100
        
        print("Levenshtein: \(levenshtein)")
        print("DamerauLevenshtein: \(damerauLevenshtein)")
        print("JaroWinkler: \(jaroWinkler)")
        
    }
    
    func removePontuaction() {
        textToReadParameterized = textToRead.lowercased().replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "...", with: "")
        transcribedTextParameterized = transcribedText.lowercased().replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "...", with: "")
    }
    
    func returnTheBiggestString() {
        biggestString = calculateBiggestString(s1: textToReadParameterized, s2: transcribedTextParameterized)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.levenshtein = levenshtein
            resultViewController.damerauLevenshtein = damerauLevenshtein
            resultViewController.jaroWinkler = jaroWinkler
        }
    }
}
