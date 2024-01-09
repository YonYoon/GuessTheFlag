//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Zhansen Zhalel on 22.09.2023.
//

import SwiftUI

struct FlagImage: View {
    var countryName: String
    
    var body: some View {
        Image(countryName)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct ProminentTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(ProminentTitle())
    }
}

struct ContentView: View {
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var userAnswer = 0
    @State private var numberOfQuestions = 0
    @State private var finishedGame = false
    
    @State private var opacityAmount = [1.0, 1.0, 1.0]
    @State private var tappedFlags = [false, false, false]
    @State private var animationAmount = [0.0, 0.0, 0.0]
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "US", "Spain", "UK", "Monaco"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)

    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius:700)
                .ignoresSafeArea()
           
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .titleStyle()
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            tappedFlags[number] = true
                            flagTapped(number)
                        } label: {
                            FlagImage(countryName: countries[number])
                        }
                        .rotation3DEffect(.degrees(animationAmount[number]), axis: (x: 0.0, y: 1.0, z: 0.0))
                        .scaleEffect(opacityAmount[number])
                        .animation(.easeOut(duration: 0.5), value: opacityAmount[number])
                        .opacity(opacityAmount[number])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            if scoreTitle == "Correct" {
                Text("You get 1 score!")
            } else {
                Text("This is flag of \(countries[userAnswer])")
            }
        }
        .alert("Game Over", isPresented: $finishedGame) {
            Button("Restart", action: reset)
        } message: {
            Text("Your total score is \(score)")
        }
    }
    
    func flagTapped(_ number: Int) {
        withAnimation {
            animationAmount[number] += 360
            for i in tappedFlags.indices {
                if i != number {
                    opacityAmount[i] -= 0.25
                }
            }
        }
        
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong"
            userAnswer = number
            if score > 0 {
                score -= 1
            }
        }
        
        if numberOfQuestions == 7 {
            showingScore = true
            finishedGame = true
        } else {
            numberOfQuestions += 1
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        tappedFlags = [false, false, false]
        opacityAmount = [1.0, 1.0, 1.0]
    }
    
    func reset() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        score = 0
        numberOfQuestions = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
