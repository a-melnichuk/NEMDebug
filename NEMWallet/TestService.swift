//
//  TestService.swift
//  NEMWallet
//
//  Created by Alex Melnichuk on 5/12/18.
//  Copyright © 2018 NEM. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

extension Array where Element == UInt8 {
    var pretty: String {
        return self.reduce("") { $0 == "" ? $0 + "\($1)" : $0 + ", \($1)" }
    }
}

extension Data {
    var pretty: String {
        return self.reduce("") { $0 == "" ? $0 + "\($1)" : $0 + ", \($1)" }
    }
}

class TestService {
    
    private var mnemonic = "zero render track search kid victory shell abuse merge quality royal clip ugly lyrics rough nation huge struggle hard exercise ball provide duty now"
    private var seedData = Data([122, 101, 114, 111, 32, 114, 101, 110, 100, 101, 114, 32, 116, 114, 97, 99, 107, 32, 115, 101, 97, 114, 99, 104, 32, 107, 105, 100, 32, 118, 105, 99, 116, 111, 114, 121, 32, 115, 104, 101, 108, 108, 32, 97, 98, 117, 115, 101, 32, 109, 101, 114, 103, 101, 32, 113, 117, 97, 108, 105, 116, 121, 32, 114, 111, 121, 97, 108, 32, 99, 108, 105, 112, 32, 117, 103, 108, 121, 32, 108, 121, 114, 105, 99, 115, 32, 114, 111, 117, 103, 104, 32, 110, 97, 116, 105, 111, 110, 32, 104, 117, 103, 101, 32, 115, 116, 114, 117, 103, 103, 108, 101, 32, 104, 97, 114, 100, 32, 101, 120, 101, 114, 99, 105, 115, 101, 32, 98, 97, 108, 108, 32, 112, 114, 111, 118, 105, 100, 101, 32, 100, 117, 116, 121, 32, 110, 111, 119])
    private let seedHex = "7a65726f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77"
    
    func testAddresses() {
        var data = Data(count: 32)
        
        let _ = data.withUnsafeMutableBytes { (p: UnsafeMutablePointer<UInt8>) in
            seedData.withUnsafeBytes { createPrivateKeyWithSeed(p, $0) }
            //seedData.withUnsafeBytes { createPrivateKeyWithSeed(p, $0) }
            //createPrivateKeyWithSeed(p, &seedData)
        }
        
        var testData = "Hello, world!"
        var out = Data(count: 32)
        let _ = out.withUnsafeMutableBytes { p in
            testData.withCString { sha3_512_test(p, $0) }
        }
        print("\n\n__NEM: testData: \(out.pretty)\n\n")
     
        let privateKey = data.toHexadecimalString()
        
        print("__NEM: privateKey: \(privateKey)")
        
        print("__NEM: seed size: \(seedData.count), seed: \(data.reduce("") { $0 == "" ? $0 + "\($1)" : $0 + ", \($1)" })")
        
        AccountManager.sharedInstance.create(account: "MyAccount",
                                             withPrivateKey: privateKey,
                                             completion: { (result, account) in
                                                guard result == .success, let account = account else {
                                                    print("__NM account creation failure")
                                                    return
                                                }
                                                self.extractAccountInfo(account: account)
                                             })
    }
    
    private func extractAccountInfo(account: Account) {
        let amount = 0.001 * 1e6
        let fee = TransactionManager.sharedInstance.calculateFee(forTransactionWithAmount: amount)
        let timestamp = 1526573983372 / 1000
        let deadline = 1526573983372 / 1000 + 21600
        let recipient = "NBZMQO7ZPBYNBDUR7F75MAKA2S3DHDCIFG775N3D"
        let tx = TransferTransaction(version: 1,
                                     timeStamp: timestamp,
                                     amount: amount,
                                     fee: Int(fee),
                                     recipient: recipient,
                                     message: nil,
                                     deadline: deadline,
                                     signer: account.publicKey)!
        let requestAnnounce = TransactionManager.sharedInstance.signTransaction(tx, account: account)
        
        let info = """
        __NEM: privateKey: \(account.privateKey)
        __NEM: privateKeyDecrypted: \(AccountManager.sharedInstance.decryptPrivateKey(encryptedPrivateKey: account.privateKey))
        __NEM: publicKey: \(account.publicKey)
        __NEM: address: \(account.address)
        __NEM: addressNormalized: \(account.address.nemAddressNormalised())
        __NEM: data: \(requestAnnounce.data)
        __NEM: signer: \(requestAnnounce.signature)
        """
        print(info)
    }
}
