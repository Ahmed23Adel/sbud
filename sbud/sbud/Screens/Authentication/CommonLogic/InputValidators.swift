//
//  InputValidators.swift
//  sbud
//
//  Created by ahmed on 01/01/2026.
//

import Foundation
import AdelsonValidator

class InputValidators {

    func validateInputs(email: String,
                        password: String,
                        emailAlertFunction: @escaping () -> Void,
                        passwordAlertFunction: @escaping () -> Void)
    -> Bool {
        return isEmailValid(email,
                            emailAlertFunction: emailAlertFunction) &&
        isPasswordValid(password,
                        passwordAlertFunction: passwordAlertFunction)
    }

    func isEmailValid(_ email: String, emailAlertFunction: @escaping () -> Void) -> Bool {
        var policy = SingleInputPolicy<String>(singleInputValidators: [
            EmailValidator()
        ])
        policy.setInput(inputs: [email])
        if !policy.check() {
            emailAlertFunction()
            return false
        }
        return true
    }

    func isPasswordValid(_ password: String, passwordAlertFunction: @escaping () -> Void) -> Bool {
        var policy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        policy.setInput(inputs: [password])
        if !policy.check() {
            passwordAlertFunction()
            return false
        }
        return true
    }
}
