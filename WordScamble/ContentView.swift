//
//  ContentView.swift
//  WordScamble
//
//  Created by KhoiLe on 21/06/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            } //list
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }//navigation view
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //validates
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Inputted already", message: "Be more original")
            return
        }
        
        guard isRead(word: answer) else {
            wordError(title: "Not real", message: "That is not a real word")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not recognized", message: "You can not make up a word! You know!")
            return
        }
        
        //if answer passes all validates
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        //find the URL of start.txt
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //seperate string into separted string, splitting on line break
                let allWords = startWords.components(separatedBy: "\n")
                //random the words from start.txt
                rootWord = allWords.randomElement() ?? "silkworm"
                //if everything has worked, exit the function
                return
            }
        }
        
        //if we are "here", then there must be a problem - trigger a crash and report the problem
        fatalError("Could not load start.txt from bundle.")
    }
    
    //the word inputted is inputted already
    func isOriginal(word: String) -> Bool {
        /*return*/!usedWords.contains(word)
    }
    
    //the inputted word is real, but it is not extracted from the rootWord
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    //the word inputted is not a real word
    func isRead(word: String) -> Bool {
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
