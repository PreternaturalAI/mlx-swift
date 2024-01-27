import Foundation

class Cache<Key: Hashable, Element> {

    let queue = DispatchQueue(label: "Cache")

    let maxSize: Int

    struct Entry {
        let value: Element
        let serial: Int
    }

    var contents = [Key: Entry]()
    var serial = 0

    init(maxSize: Int = 10) {
        self.maxSize = maxSize
    }

    subscript(key: Key) -> Element? {
        get {
            queue.sync {
                contents[key]?.value
            }
        }
        set {
            queue.sync {
                if let newValue {
                    // handle wrap on the serial number
                    if serial == Int.max {
                        contents.removeAll()
                        serial = 0
                    }
                    contents[key] = Entry(value: newValue, serial: serial)
                    serial += 1

                    // if too large, remove oldest
                    if contents.count > maxSize {
                        let minKey = contents.min { lhs, rhs in
                            lhs.value.serial < rhs.value.serial
                        }?.key
                        if let minKey {
                            contents[minKey] = nil
                        }
                    }
                } else {
                    contents[key] = nil
                }
            }
        }
    }
}