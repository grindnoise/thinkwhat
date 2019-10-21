import UIKit

var str = "Pavel Bukharov"


let separated = str.split(separator: " ")

separated.enumerated().map {
    (index, element) in
    if index == 0 && element == "Pavel" {
        print("match")
    }
    print(index, element)
}
