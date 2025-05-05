//
//  LoginView.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @State private var fullName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)

                Text(isSignUp ? "アカウント作成" : "ログイン")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                VStack(spacing: 15) {
                    TextField("メールアドレス", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if isSignUp {
                        TextField("氏名", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }

                    SecureField("パスワード", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await performAuth()
                    }
                }) {
                    Text(isSignUp ? "登録" : "ログイン")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(authViewModel.isLoading)

                if authViewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                Button(action: {
                    isSignUp.toggle()
                    email = ""
                    password = ""
                    fullName = ""
                }) {
                    Text(isSignUp ? "既にアカウントをお持ちの方はこちら" : "アカウントをお持ちでない方はこちら")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("エラー"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: authViewModel.authError) { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    private func performAuth() async {
        if isSignUp {
            if email.isEmpty || password.isEmpty {
                alertMessage = "メールアドレスとパスワードを入力してください"
                showAlert = true
                return
            }

            let success = await authViewModel.signUp(
                email: email,
                password: password,
                fullName: fullName.isEmpty ? nil : fullName
            )

            if !success && authViewModel.authError == nil {
                alertMessage = "アカウント作成に失敗しました"
                showAlert = true
            }
        } else {
            if email.isEmpty || password.isEmpty {
                alertMessage = "メールアドレスとパスワードを入力してください"
                showAlert = true
                return
            }

            let success = await authViewModel.signIn(email: email, password: password)

            if !success && authViewModel.authError == nil {
                alertMessage = "ログインに失敗しました"
                showAlert = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
