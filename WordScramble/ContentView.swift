//
//  ContentView.swift
//  WordScramble
//
//  Created by Constantin Lisnic on 13/11/2024.
//

import Inject
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                        Text("Score: \(usedWords.count)")
                    }
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart", action: startGame)
            }
        }

        .enableInjection()
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(
                title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }

        guard isReal(word: answer) else {
            wordError(
                title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }

        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Words must be at least 3 letters long")
            return
        }

        guard isNotRootWord(word: answer) else {
            wordError(title: "Word is root word", message: "You can't use the root word")
            return
        }

        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Words must be at least 3 letters long")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(
            forResource: "start", withExtension: "txt")
        {
            if let startWords = try? String(
                contentsOf: startWordsURL, encoding: .utf8)
            {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                newWord = ""
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
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
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func isLongEnough(word: String) -> Bool {
        word.count >= 3
    }

    func isNotRootWord(word: String) -> Bool {
        word != rootWord
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
