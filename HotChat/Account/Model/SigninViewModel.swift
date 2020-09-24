//
//  SigninViewModel.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities


class SigninViewModel {
    
    
    static var countdownSeconds: Int = 6
    
    let validatedPhone: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    

    // Is signup button enabled
    let signinEnabled: Driver<Bool>
    

    // Has user signed in
    let signedIn: Driver<Bool>
    

    // Is signing process in progress
    let signingIn: Driver<Bool>
    
    
    init (
        input: (
            phone: Driver<String>,
            password: Driver<String>,
            signInTaps: Signal<()>
        ),
        dependency: (
            API: SigninAPI,
            validationService: ValidationService,
            wireframe: Wireframe
        )
         
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        
        validatedPhone = input.phone
            .map { phone in
                return validationService.validatePhone(phone)
            }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
        
        
        let phoneAndPassword = Driver.combineLatest(input.phone, input.password) { (phone: $0, password: $1) }
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asDriver()
        
        signedIn = input.signInTaps.withLatestFrom(phoneAndPassword)
            .flatMapLatest { pair in
                return API.signin(pair.phone, password: pair.password)
                    .do(onSuccess: { result in
                        wireframe.show(result.msg)
                    }, onError: { error in
                        wireframe.show(error.localizedDescription)
                    })
                    .map { result in
                        return result.isSuccessd
                    }
                    .trackActivity(signingIn)
                    .asDriver(onErrorJustReturn: false)
        }
        
        
        signinEnabled = Driver.combineLatest(
            validatedPhone,
            validatedPassword,
            signingIn
        ) { phone, password, signingIn in
                phone.isValid &&
                password.isValid &&
                !signingIn
         }
        .distinctUntilChanged()
    }
}
