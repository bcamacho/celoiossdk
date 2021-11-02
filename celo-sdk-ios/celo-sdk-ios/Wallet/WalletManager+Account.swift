import Foundation
import PromiseKit
import web3swift

extension WalletManager {
    // MARK: - Account

    class func storeAccountsToCache() {
        do {
            let data = try JSONEncoder().encode(WalletManager.Accounts!)
            Defaults[\.accountsData] = data

        } catch {
            TLog(WalletError.createAccountFailure)
           
        }
    }

    class func fetchAccountsFromCache() -> Promise<[Account]> {
        return Promise<[Account]> { seal in

            guard let data = Defaults[\.accountsData] else {
                if Defaults[\.isFirstTimeOpen] == false {
                    let error = WalletError.custom("Decode accounts failed")
                    seal.reject(error)
                }
                return
            }
            do {
                let accounts = try JSONDecoder().decode([Account].self, from: data)
                WalletManager.Accounts = accounts
                seal.fulfill(accounts)
            } catch {
                let error = WalletError.custom("Decode accounts failed")
                seal.reject(error)
            }
        }
    }

    class func createAccount() {
        let oldPaths = WalletManager.shared.keystore!.paths.keys

        do {
            try WalletManager.shared.keystore?.createNewChildAccount()
            try WalletManager.shared.saveKeystore(WalletManager.shared.keystore!)

            let animal = Constant.randomAnimal()
            let name = "\(animal.firstUppercased) Wallet"

            let newPaths = WalletManager.shared.keystore!.paths.keys

            let newPath = newPaths.filter { !oldPaths.contains($0) }.first!
            let address = WalletManager.shared.keystore!.paths[newPath]!.address
            let account = Account(address: address, name: name, imageName: animal)
            WalletManager.Accounts?.append(account)


        } catch {
            TLog(error: WalletError.createAccountFailure)
        }
    }

    class func deleteAccount() {
        if WalletManager.Accounts!.count <= 1 {
            TLog(text: "Can't delete the last account")
            return
        }
    }

    class func switchAccount(account: Account) {
        // if same account, not change
        if account == WalletManager.currentAccount {
            return
        }

        WalletManager.currentAccount = account
        Defaults[\.defaultAccountIndex] = WalletManager.Accounts!.firstIndex(of: account)!
        NotificationCenter.default.post(name: .accountChange, object: nil)
    }

    func walletChange() {
        Defaults[\.defaultAccountIndex] = 0
        WalletManager.storeAccountsToCache()
    }

    // MARK: - Account info

    func updateAccount(account: Account, imageName: String?, name: String?) {
        guard let index = WalletManager.Accounts?.firstIndex(of: account) else {
            return
        }

        if let image = imageName {
            WalletManager.Accounts?[index].imageName = image
        }

        if let walletName = name {
            WalletManager.Accounts![index].name = walletName
        }

        WalletManager.storeAccountsToCache()

        if account == WalletManager.currentAccount {
            if let image = imageName {
                WalletManager.currentAccount?.imageName = image
            }

            if let walletName = name {
                WalletManager.currentAccount?.name = walletName
            }
        }

    }
}
