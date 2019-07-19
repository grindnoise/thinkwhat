import UIKit

var str = "Hello, playground"


class AppData {
    static let shared = AppData()
    var user = User()
    var userProfile = UserProfile()
    
    struct User {
        var ID: String! {
            didSet {
                if ID != oldValue {
                    UserDefaults.standard.set(ID, forKey: "userId")
                } else if ID.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userId")
                }
            }
        }
        var username: String! {
            didSet {
                if username != oldValue {
                    UserDefaults.standard.set(username, forKey: "username")
                } else if username.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "username")
                }
            }
        }
        var firstName: String! {
            didSet {
                if firstName != oldValue {
                    UserDefaults.standard.set(firstName, forKey: "firstName")
                } else if firstName.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "firstName")
                }
            }
        }
        var lastName: String! {
            didSet {
                if lastName != oldValue {
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                } else if lastName.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "lastName")
                }
            }
        }
        var email: String! {
            didSet {
                if email != oldValue {
                    UserDefaults.standard.set(email, forKey: "userMail")
                } else if email.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userMail")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kFirstName = UserDefaults.standard.object(forKey: "firstname") {
                self.firstName = kFirstName as? String
            }
            if let kLastName = UserDefaults.standard.object(forKey: "lastname") {
                self.lastName = kLastName as? String
            }
            if let kUserName = UserDefaults.standard.object(forKey: "userName") {
                self.username = kUserName as? String
            }
            if let kUserMail = UserDefaults.standard.object(forKey: "userMail") {
                self.email = kUserMail as? String
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userID") {
                self.ID = kUserID as? String
            }
        }
        
        mutating func eraseData() {
            firstName               = ""
            lastName                = ""
            username                = ""
            ID                      = ""
            email                   = ""
        }
    }
    
    struct UserProfile {
        var ID: String! {
            didSet {
                if ID != oldValue {
                    UserDefaults.standard.set(ID, forKey: "userProfileID")
                } else if ID.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userProfileID")
                }
            }
        }
        var imagePath: String! {
            didSet {
                if !imagePath.isEmpty {
                    UserDefaults.standard.set(imagePath, forKey: "userImagePath")
                } else {
                    UserDefaults.standard.removeObject(forKey: "userImagePath")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kImagePath = UserDefaults.standard.object(forKey: "userImagePath") {
                self.imagePath = kImagePath as? String
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userProfileID") {
                self.ID = kUserID as? String
            }
        }
        
        mutating func eraseData() {
            imagePath = ""
            ID        = ""
        }
    }
    
    private init() {}
}

AppData.shared.userProfile.ID = "2"
AppData.shared.userProfile.ID
