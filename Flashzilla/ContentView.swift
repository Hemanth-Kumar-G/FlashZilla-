//
//  ContentView.swift
//  Flashzilla
//
//  Created by HEMANTH on 19/02/23.
//

import SwiftUI


extension View {
    
    func stacked(at position:Int , in total:Int ) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0,y: offset*10)
    }
}

struct ContentView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    
    @State private var cards = [Card](repeating: Card.example, count: 2)
    
    
    @State private var timeRemaining = 100
    
    let timer = Timer.publish(every: 1, on: .main, in: .common ).autoconnect()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isActive = true
    
    @State private var showingEditScreen = false
    
    
    var body: some View {
        ZStack{
            
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            
            VStack {
                Text("Time:  \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                VStack {
                    ZStack{
                        
                        ForEach(0..<cards.count, id: \.self ){ index in
                            CardView(card: cards[index],removal: {
                                withAnimation {
                                    removeCard(at : index)
                                }
                            })
                            .stacked(at: index, in: cards.count)
                            .allowsHitTesting(index == cards.count - 1)
                            .accessibilityHidden(index < cards.count - 1)
                        }
                    }  .allowsHitTesting(timeRemaining > 0)
                    
                }
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                     
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: {EditCards()})
        .onAppear(perform: resetCards)
        .frame(width: .infinity,height: .infinity)
        
        
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

