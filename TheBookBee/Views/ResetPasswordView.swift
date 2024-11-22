//
//  ResetPasswordView.swift
//  TheBookBee
//
//  Created by cocobsccomp231p-019 on 2024-11-16.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isNewPasswordHidden = true
    @State private var isConfirmPasswordHidden = true
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack{
                Color("background_grey")
                    .ignoresSafeArea() //extends color over safe areas
                
                VStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 40) {
                        Text("Reset Password")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 70)
                        
                        Image("logo_bookbee")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 218, height: 64)
                            .padding(.bottom, 70)
                        
                        VStack(spacing: 20) {
                            // New Password field with eye toggle
                            HStack {
                                if isNewPasswordHidden {
                                    SecureField("New Password", text: $newPassword)
                                } else {
                                    TextField("New Password", text: $newPassword)
                                }
                                
                                Button(action: {
                                    isNewPasswordHidden.toggle()
                                }) {
                                    Image(systemName: isNewPasswordHidden ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            // Confirm Password field with eye toggle
                            HStack {
                                if isConfirmPasswordHidden {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                } else {
                                    TextField("Confirm Password", text: $confirmPassword)
                                }
                                
                                Button(action: {
                                    isConfirmPasswordHidden.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordHidden ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            // Implement reset password logic
                        }) {
                            Text("Reset Password")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("F8C95A"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        HStack {
                            Text("Don't have an account?")
                            NavigationLink(destination: SignUpView()) {
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("F8C95A"))
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .edgesIgnoringSafeArea(.top)
                    .background(Color("background_grey"))
                }
                .navigationViewStyle(.automatic)
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
