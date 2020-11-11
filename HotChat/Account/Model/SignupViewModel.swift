//
//  SignupViewModel.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities
import NSObject_Rx
import Toast_Swift


class SignupViewModel {
    
    
    static var countdownSeconds: Int = 60
    
    let validatedPhone: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    let validatedCode: Driver<ValidationResult>
    
    // Is code button enabled
    let codeEnabled: Driver<Bool>
    
    // Is signup button enabled
    let signupEnabled: Driver<Bool>
    
    let countdownEnabled: Driver<Bool>
    
    // Has user code
     let code: Driver<Bool>

    // Has user signed in
    let signedUp: Driver<Bool>
    
    // Is countdown process in progress
    let countdown: Driver<Bool>
    
    // Is coding process in progress
    let coding: Driver<Bool>

    // Is signing process in progress
    let signingUp: Driver<Bool>
    
    // Is countdown process in progress
    let countdowning: Driver<Int>
    
    
    init (
        input: (
            phone: Driver<String>,
            password: Driver<String>,
            code: Driver<String>,
            codeTaps: Signal<()>,
            signUpTaps: Signal<()>
        ),
        dependency: (
            API: SignupAPI,
            validationService: ValidationService,
            wireframe: IndicatorDisplay
        )
         
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        let countdownTrigger = PublishSubject<Void>()
        
        
        validatedPhone = input.phone
            .map { phone in
                return validationService.validatePhone(phone)
            }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
        
        validatedCode = input.code
            .map { code in
                return validationService.validateCode(code)
            }
        
        let coding = ActivityIndicator()
        self.coding = coding.asDriver()
        
        code = input.codeTaps.withLatestFrom(input.phone)
            .flatMapLatest { phone in
                return API.sendCode(phone)
                    .do(onSuccess: { result in
                        if result.isSuccessd {
                            countdownTrigger.onNext(())
                        }
                        wireframe.show(result.msg, in: UIApplication.shared.keyWindow!)
                    }, onError: { error in
                        wireframe.show(error.localizedDescription, in: UIApplication.shared.keyWindow!)
                    })
                    .map { result in
                        return result.isSuccessd
                    }
                    .trackActivity(coding)
                    .asDriver(onErrorJustReturn: false)
            }
        
        let countdowning = countdownTrigger
               .flatMapLatest {
                    return Observable<Int>.countdown(Self.countdownSeconds).asDriver(onErrorJustReturn: 0)
               }
              .asDriver(onErrorJustReturn: 0)
        
        self.countdowning = countdowning
        
        let countdown = ActivityIndicator()
        self.countdown = countdown.asDriver()
        
        
        self.countdownEnabled = countdownTrigger
            .flatMapLatest {
                return Observable<Int>.countdown(Self.countdownSeconds)
                    .takeLast(1)
                    .map { _ in
                        return true
                    }
                    .trackActivity(countdown)
                    
            }
            .asDriver(onErrorJustReturn: true)

        
        let phoneAndPasswordAndCode = Driver.combineLatest(input.phone, input.password, input.code) { (phone: $0, password: $1, code: $2) }
        
        let signingUp = ActivityIndicator()
        self.signingUp = signingUp.asDriver()
        
        signedUp = input.signUpTaps.withLatestFrom(phoneAndPasswordAndCode)
            .flatMapLatest { tuple in
                return API.signup(tuple.phone, password: tuple.password, code: tuple.code)
                    .do(onSuccess: { result in
                        wireframe.show(result.msg, in: UIApplication.shared.keyWindow!)
                    }, onError: { error in
                        wireframe.show(error.localizedDescription, in: UIApplication.shared.keyWindow!)
                    })
                    .map { result in
                        return result.isSuccessd
                    }
                    .trackActivity(signingUp)
                    .asDriver(onErrorJustReturn: false)
        }
        
        codeEnabled = Driver.combineLatest(
            coding,
            countdown,
            validatedPhone
        ) {
            !$0 && !$1 && $2.isValid
         }
        .distinctUntilChanged()
        
        
        signupEnabled = Driver.combineLatest(
            validatedPhone,
            validatedPassword,
            validatedCode,
            signingUp
        ) { phone, password, code, signingUp in
                phone.isValid &&
                password.isValid &&
                code.isValid &&
                !signingUp
         }
        .distinctUntilChanged()
    }
}
