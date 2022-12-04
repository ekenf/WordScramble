//
//  ContentView.swift
//  Word Scramble
//
//  Created by Furkan on 11.11.2022.
//

import SwiftUI


struct ContentView: View {

    @State private var usedWords = [String]()
    @State private var rootWord = "saçmamak"
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        NavigationView {
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                HStack{
                    Text("Score: \(score)")
                    Spacer()
                    Button("Reset") {startGame()}
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .alert(errorTitle, isPresented: $showingError){
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isShort(word: answer) else {
            wordError(title: "Too Short!", message: "Your answer must be longer than 2 letters")
            return
        }
        
        
        
        score += answer.count
        
        withAnimation{
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
    }
    
    func startGame () {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word) && word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title:String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    
    func isShort(word: String) -> Bool {
        if word.count <= 3 {
            return false
        } else {
            return true
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
