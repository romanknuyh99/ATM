import UIKit


var summForPerson = 240
var cardBalance = 700
var pinCode = 8888
var banknoteInAtm = 100

enum Currency {
    case euro
    case dollars
    case byn
}

enum AtmErrors: Error {
    case noMoneyInAtm
    case noMoneyOnCard
    case noCurrency
    case notWorking
    case pinCodeError
    case wrongEnteredSum
}

func withdrawMoney(summa: Int, atmWork: Bool, pin: Int, currency: Currency) throws {
    guard summa >= summForPerson else { throw AtmErrors.noMoneyInAtm }
    guard atmWork else { throw AtmErrors.notWorking }
    guard summForPerson < cardBalance else { throw AtmErrors.noMoneyOnCard }
    guard pin == pinCode else { throw AtmErrors.pinCodeError }
    guard summa % 5 == 0 else { throw AtmErrors.wrongEnteredSum }
    
    print("Выдаваемая сумма - \(summa) \(currency)")
}

do {
    try withdrawMoney(summa: 250, atmWork: true, pin: 8888, currency: .byn)
} catch AtmErrors.noMoneyInAtm {
    print("В банкомате закончились деньги")
} catch AtmErrors.noMoneyOnCard {
    print("На карте нет средств")
} catch AtmErrors.noCurrency {
    print("Нет необходимой валюты")
} catch AtmErrors.notWorking {
    print("Банкомат не работает")
} catch AtmErrors.pinCodeError {
    print("Вы ввели неправильный PIN-код")
} catch AtmErrors.wrongEnteredSum {
    print("Сумма должна делиться на 5, банкомат не выдает монеты")
}

class MoneyPack {
    let value: Int
    var quantity: Int
    var nextPile: MoneyPack?
    let currency: Currency
    
    init(value: Int, quantity: Int, nextPile: MoneyPack?, currency: Currency) {
        self.value = value
        self.quantity = quantity
        self.nextPile = nextPile
        self.currency = currency
    }
    
    // Сможем ли мы выдать нужную сумму используя текущую пачку? Проверка в функции.
    func canWithdraw(v: Int) -> Bool {
        var v = v
        
        func canTakeSomeBill(want: Int) -> Bool {
            return (want / self.value) > 0
        }
        
        var q = self.quantity
        
        while canTakeSomeBill(want: v) {
            if q == 0 {
                break
            }
            v -= self.value
            q -= 1
        }
        if v == 0 {
            return true
        } else if let next = self.nextPile {
            return next.canWithdraw(v: v)
        }
        
        return false
    }
    
}

class ATM {
    private var hundred: MoneyPack
    private var fifty: MoneyPack
    private var twenty: MoneyPack
    private var ten: MoneyPack
    
    private var startPile: MoneyPack {
        return self.hundred
    }
    
    init(hundred: MoneyPack, fifty: MoneyPack, twenty: MoneyPack, ten: MoneyPack) {
        
        self.hundred = hundred
        self.fifty = fifty
        self.twenty = twenty
        self.ten = ten
    }
    
    func canWithdraw(value: Int) -> String {
        return "Can withdraw: \(self.startPile.canWithdraw(v: value))"
    }
}

// Создаем пачки денег от меньшей купюры к большей 10 - 100.
let ten = MoneyPack(value: 10, quantity: 8, nextPile: nil, currency: .byn)
let twenty = MoneyPack(value: 20, quantity: 2, nextPile: ten, currency: .byn)
let fifty = MoneyPack(value: 50, quantity: 4, nextPile: twenty, currency: .byn)

let hundred = MoneyPack(value: 100, quantity: 4, nextPile: fifty, currency: .byn)

// Банкомат с пачками денег по образцу
var atm = ATM(hundred: hundred, fifty: fifty, twenty: twenty, ten: ten)
atm.canWithdraw(value: 800) // Не сможет выдать сумму 800, ведь в банкомате только 720
print(atm.canWithdraw(value: 200)) // Может выдать, так как есть 4 купюры номиналом по 100, а нам нужны 2 из них
atm.canWithdraw(value: 182) // Не сможет выдать сумму 182, так как выдает только купюры номиналом 10/20/50/100
atm.canWithdraw(value: 60)  // Может выдать 6 купюр по 10 или одну купюру по 50 и 10
