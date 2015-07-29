import Foundation


// MARK: Extract dictionary
extension JSONValue {
    public var dictionary:Swift.Dictionary<String,AnyObject> {
        var dictionary = Swift.Dictionary<String,AnyObject>()
        
        switch self {
        case .JDictionary (let dict):
            for (k,v) in dict {
                if let a: AnyObject = v.str ?? v.num ?? v.bool ?? v.null {
                    dictionary[k] = a
                }
                else if v.jsonArray != nil {
                    dictionary[k] = v.array as AnyObject
                }
                else if v.jsonDictionary != nil {
                    dictionary[k] = v.dictionary as AnyObject
                }
            }
        default:
            break
        }
        return dictionary
    }
    
    public var nsDictionary:NSDictionary {
        let dictionary = NSMutableDictionary()
        
        switch self {
        case .JDictionary (let dict):
            for (k,v) in dict {
                if let a: AnyObject = v.str ?? v.num ?? v.bool ?? v.null {
                    dictionary[k] = a
                }
                else if v.jsonArray != nil {
                    dictionary[k] = v.array as NSArray
                }
                else if v.jsonDictionary != nil {
                    dictionary[k] = v.dictionary as NSDictionary
                }
            }
        default:
            break
        }
        return dictionary
    }
    
}

// Dictionary subscripting
extension JSONValue {
   

    public subscript (key:String) -> JSONValue? {
        get {
            switch self {
            case .JDictionary(let a):
                return a[key]
                
            default:
                
                return nil
            }}
        set(newValue) {
            
            switch self {
            case .JDictionary(var a):
                if let nV = newValue {
                    a[key] = nV
                    self = .JDictionary(a)
                }
            default:
                return
            }}
    }

    public subscript (key:String) -> AnyObject? {
        get {
                return nil
            }
        set(newValue) {
            
            switch self {
            case .JDictionary(var a):
                if let nV = newValue {
                    a[key] = JSONValue(value:nV)
                    self = .JDictionary(a)
                }
            default:
                return
            }}
    }
    
}


// MARK: Keys and Values
extension JSONValue {
    public var keys:[String] {
        switch self {
        case .JDictionary(let dict):
            return [String](dict.keys)
        default:
            return []
            }
     
    }
    public var values:[JSONValue] {
        switch self {
        case .JDictionary(let dict):
            return [JSONValue](dict.values)
        default:
            return []
        }
        
    }
}

extension JSONValue {
    public mutating func updateValue(value:JSONValue, forKey key:String) {
        switch self {
        case .JDictionary(var dictionary):
            dictionary[key] = value
            self = .JDictionary(dictionary)
        default:
            return
        }
        
    }
    public mutating func updateValue(value:AnyObject, forKey key:String, typesafe:Bool = true) {
        switch self {
        case .JDictionary(var dictionary):
            if typesafe == false || dictionary[key]?.null != nil  {
                dictionary[key] = JSONValue(value:value)
                self = .JDictionary(dictionary)
                break
            }
            guard let dV = dictionary[key] else {
                // dictionary key currently has no associated value
                dictionary[key] = JSONValue(value:value)
                self = .JDictionary(dictionary)
                break
            }
            dictionary[key] = typesafeReplace(dV, value: value)
            self = .JDictionary(dictionary)
    
        default:
                 fatalError("Trying to update value for key in non-dictionary type")
        }

    
}
    public mutating func nullValueForKey(key:String) {
        updateValue(NSNull(), forKey: key, typesafe: false)
    }
}

