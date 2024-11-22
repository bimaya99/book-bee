//
//  VerificationCodeView.swift
//  TheBookBee
//
//  Created by cocobsccomp231p-019 on 2024-11-16.
//

import SwiftUI

struct VerificationCodeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var code1 = ""
    @State private var code2 = ""
    @State private var code3 = ""
    @State private var code4 = ""
    
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 50)
            
            // Back button at the top
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("Back")
                }
                .padding(.leading)
                Spacer()
            }

            Spacer().frame(height: 40)
            
            VStack(spacing: 8) {
                Text("Verification Code")
                    .font(.custom("Rubik-Medium", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.vertical, 24)
                
                Text("Please enter the one-time code we sent to your xxx***@gmail.com email address")
                    .font(.custom("Rubik-Light", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 30)
            
            HStack(spacing: 12) {
                TextField("", text: $code1)
                    .frame(width: 60, height: 60)
                    .multilineTextAlignment(.center)
                    .font(.custom("Rubik-Bold", size: 24))
                    .background(Color("D69E19").opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: 1)
                    .onChange(of: code1) { oldValue, newValue in
                        if newValue.count == 1 {
                            focusedField = 2
                        }
                    }
                
                TextField("", text: $code2)
                    .frame(width: 60, height: 60)
                    .multilineTextAlignment(.center)
                    .font(.custom("Rubik-Bold", size: 24))
                    .background(Color("D69E19").opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: 2)
                    .onChange(of: code2) {oldValue, newValue in
                        if newValue.count == 1 {
                            focusedField = 3
                        }
                    }
                
                TextField("", text: $code3)
                    .frame(width: 60, height: 60)
                    .multilineTextAlignment(.center)
                    .font(.custom("Rubik-Bold", size: 24))
                    .background(Color("D69E19").opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: 3)
                    .onChange(of: code3) { oldValue, newValue in
                        if newValue.count == 1 {
                            focusedField = 4
                        }
                    }
                
                TextField("", text: $code4)
                    .frame(width: 60, height: 60)
                    .multilineTextAlignment(.center)
                    .font(.custom("Rubik-Bold", size: 24))
                    .background(Color("D69E19").opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: 4)
            }
            .padding(.bottom, 40)
            
            Button(action: {
                // Confirm code action
            }) {
                NavigationLink(destination: ResetPasswordView()) {
                    Text("Confirm Code")
                        .font(.custom("Rubik-Bold", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("D69E19"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)

            Button(action: {
                // Resend code action
            }) {
                Text("Resend Code")
                    .font(.custom("Rubik-Light", size: 14))
                    .foregroundColor(Color(.black))
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .background(Color("background_grey"))
        .ignoresSafeArea()
    }
}

struct VerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeView()
    }
}
