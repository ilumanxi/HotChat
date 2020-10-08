//
//  ForgotPasswordViewModel.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities



class ForgotPasswordViewModel {
    
    
    static var countdownSeconds: Int = 6
    
    let validatedPhone: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    let validatedPasswordRepeated: Driver<ValidationResult>
    let validatedCode: Driver<ValidationResult>
    
    // Is code button enabled
    let codeEnabled: Driver<Bool>
    
    // Is signup button enabled
    let resetEnabled: Driver<Bool>
    
    let countdownEnabled: Driver<Bool>
    
    // Has user code
     let code: Driver<Bool>

    // Has user signed in
    let reseted: Driver<Bool>
    
    // Is countdown process in progress
    let countdown: Driver<Bool>
    
    // Is coding process in progress
    let coding: Driver<Bool>

    // Is signing process in progress
    let reseting: Driver<Bool>
    
    // Is countdown process in progress
    let countdowning: Driver<Int>
    
    
    init (
        input: (
            phone: Driver<String>,
            password: Driver<String>,
            repeatedPassword: Driver<String>,
            code: Driver<String>,
            codeTaps: Signal<()>,
            resetTaps: Signal<()>
        ),
        dependency: (
            API: ForgotPasswordAPI,
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
        
        validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
        
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
                        wireframe.show(result.msg)
                    }, onError: { error in
                        wireframe.show(error.localizedDescription)
                    })
                    .map { result in
                        return result.isSuccessd
                    }
                    .trackActivity(coding)
                    .asDriver(onErrorJustReturn: false)
            }
        
        let countdowning = countdownTrigger
               .flatMapLatest {
                    return Observable<Int>.countdown(Self.countdownSeconds)
                        .asDriver(onErrorJustReturn: 0)
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
        
        let reseting = ActivityIndicator()
        self.reseting = reseting.asDriver()
        
        reseted = input.resetTaps.withLatestFrom(phoneAndPasswordAndCode)
            .flatMapLatest { tuple in
                return API.resetPassword(tuple.phone, password: tuple.password, code: tuple.code)
                    .do(onSuccess: { result in
                        wireframe.show(result.msg)
                    }, onError: { error in
                        wireframe.show(error.localizedDescription)
                    })
                    .map { result in
                        return result.isSuccessd
                    }
                    .trackActivity(reseting)
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
        
        
        resetEnabled = Driver.combineLatest(
            validatedPhone,
            validatedPassword,
            validatedPasswordRepeated,
            validatedCode,
            reseting
        ) { phone, password, repeatPassword, code, reseting in
                phone.isValid &&
                password.isValid &&
                repeatPassword.isValid &&
                code.isValid &&
                !reseting
         }
        .distinctUntilChanged()
    }
}
