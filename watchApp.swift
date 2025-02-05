//
//  ContentView.swift
//  bolt Watch App
//
//  Created by Adan Sandoval on 01/02/25.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var life: Int = 40
    @State private var crownValue: Double = 0.0
    @State private var lastWholeCrownValue: Int = 0
    @State private var isHolding: Bool = false
    @State private var timer: Timer?
    private let timerDuration: Double = 0.3
    private let longPressMinDuration: Double = 0.5
    
    func modifyLife(_ value: Int) -> Void {
        life = max(0, life + value) //dont go below 0
    }
        
    func startRepeatingChange(_ delta: Int) {
        timer = Timer.scheduledTimer(withTimeInterval: timerDuration, repeats: true) { _ in
            modifyLife(delta)
        }
    }
    
    func stopRepeatingChange() {
        timer?.invalidate()
        isHolding = false
    }
    
    // template to create buttons since code is large and changes are minimal
    func createButton(_ type: ButtonOptions) -> some View {
        let (label, value) = type == .Add ? ("+", 1) : ("-", -1)
        return Button(label) {
            if !isHolding {
                modifyLife(value)
            }
            
            isHolding = false //stop incrementing when finger leaves the touchscreen
        }
            .simultaneousGesture(LongPressGesture(minimumDuration: longPressMinDuration).onEnded { _ in
                isHolding = true //start the hold flag when longpress starts
                startRepeatingChange(value * 10)
                
            })
            .onChange(of: isHolding) { holding in
                if !holding { stopRepeatingChange() }
            }
            .font(.title)
            .padding()
            .cornerRadius(10)
    }
    
    var body: some View {
        VStack {
            Text(life > 0 ? "\(life)" : "You lost!")
                .font(.largeTitle)
                .padding()
                .foregroundColor(life > 0 ? .white : .red)
            Spacer()
            HStack {
                createButton(.Subtract)
                createButton(.Add)
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .focusable()
            //digital crown shenanigans
            .digitalCrownRotation($crownValue, from: -100, through: 100, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
            .onChange(of: crownValue) { newValue in
                let newWholeVal = Int(round(newValue)) //round and cast to int seems pretty dumb but xcode was not happy
                let difference = newWholeVal - lastWholeCrownValue
                
                if abs(difference) >= 1 && abs(difference) <= 4 { // track when the int changes but avoid big spikes on under/overflow
                    modifyLife(difference)
                }
                
                lastWholeCrownValue = newWholeVal //store final whole number
            }
    }
}

enum ButtonOptions {
    case Add
    case Subtract
}

#Preview {
    ContentView()
}
