//
//  ContentView.swift
//  WordScramble
//
//  Created by Terry Thrasher on 2021-04-19.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var wordScore = 0
    @State private var letterScore = 0
    
    // Challenge 3 asks me to put a text view below the list that displays the user's score. I am calculating score as 5 points per word + 1 point per letter in each word. This will be cleared when a new word is shown.
    var score: Int {
        let userWordsScore = usedWords.count * 5
        var userLettersScore = 0
        
        for word in usedWords {
            userLettersScore += word.count
        }
        
        return userWordsScore + userLettersScore
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords,id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Score: \(score)")
            }
            .navigationBarTitle(rootWord)
            // Challenge 2 asks me to add a left bar button that calls startGame() for a new word. I added having the method remove all usedWords.
            .navigationBarItems(leading: Button("New word") {
                startGame()
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        // Challenge 1 asks me to prevent words that are shorter than three letters or are equal to our starting word.
        guard answer.count > 2 else {
            wordError(title: "Word too short", message: "Your words must be at least 3 letters!")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Lazy answer", message: "You just entered the original word! Find your own!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Give us a new word instead!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Uses invalid letters", message: "This word uses letters that aren't found in the original!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "English doesn't include this word. Try again!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    // As of this tutorial we check misspellings with UITextChecker, which requires converting the string into a range, and if the misspell check comes back positive, we get a location, otherwise we get an NSNotFound (similar to nil). This lets us return a bool depending on the comparison between the location and the NSNotFound.
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
