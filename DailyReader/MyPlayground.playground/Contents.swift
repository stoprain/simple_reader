import UIKit

var str = "Sun Sep 29 14:30:10 +0800 2019"
let dateFormatterGet = DateFormatter()
dateFormatterGet.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
print(dateFormatterGet.date(from: str))

print(dateFormatterGet.string(from: Date()))
