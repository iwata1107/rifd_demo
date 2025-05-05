//
//  AuthView.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

//
//  AuthView.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

import SwiftUI
import Supabase

struct AuthView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading = false
  @State private var result: Result<Void, Error>?

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("ログイン情報")) {
          TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)

          SecureField("Password", text: $password)
            .textContentType(.password)
        }

        Section {
          Button(action: signInButtonTapped) {
            HStack {
              Spacer()
              Text("Sign in")
              Spacer()
            }
          }
          .disabled(email.isEmpty || password.isEmpty || isLoading)

          if isLoading {
            HStack {
              Spacer()
              ProgressView()
              Spacer()
            }
          }
        }

        if let result {
          Section {
            switch result {
            case .success:
              Text("ログイン成功")
            case .failure(let error):
              Text(error.localizedDescription)
                .foregroundColor(.red)
            }
          }
        }
      }
      .navigationTitle("ログイン")
    }
  }

  private func signInButtonTapped() {
    isLoading = true
    result = nil

    Task {
      do {
        // メール＋パスワードでサインイン
        try await supabase.auth.signIn(
          email: email,
          password: password
        )
        result = .success(())
      } catch {
        result = .failure(error)
      }
      isLoading = false
    }
  }
}
