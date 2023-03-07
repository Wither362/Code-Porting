/**
 * Originally made by Haxe, ported to Swift by Wither362.
 
 * This document is in Spanish and in English.

 * If you are gonna use it, please let me know it first, along with you will have to credit me and Haxe.
 */

#if canImport(Foundation)
import Foundation
#endif

///Errors used by the `Map`
public enum MapError<K>: Error {
    public typealias Key = K
    
    ///Item doesn't exist.
    ///---
    ///Ítem no existe.
    case nonExists(key: K)
}
#if canImport(Foundation)
extension MapError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .nonExists(key):
            return NSLocalizedString("Key does not exists!", comment: "Key")
        }
    }
}
#else
extension MapError {
    public var errorDescription: String? {
        switch self {
        case let .nonExists(key):
            return NSLocalizedString("Key does not exists!", comment: "Key")
        }
    }
}
#endif

/**
 * Protocol for copying things.
 */
public protocol CopyProtocol {
    associatedtype CopyElement
    ///Returns a copy of itself.
    ///---
    ///Devuelve una copia de éste Struct.
    func copy() -> CopyElement
}

///Originally by Haxe, implemented to Swift by Wither362.
///---
/// Original por Haxe, implementado a Swift por Wither362.
public struct Map<Key: Hashable, Value: Equatable>: ExpressibleByDictionaryLiteral, Sequence, IteratorProtocol, ExpressibleByArrayLiteral, Collection, AsyncSequence, CopyProtocol /*, ExpressibleByStringLiteral*/ where Key: Equatable {
    public typealias CopyElement = Map<Key, Value>
    public typealias Value = Value
    public typealias Key = Key
    public typealias Element = (Key, Value)
    public typealias ArrayLiteralElement = [Any]
    public typealias StringLiteralType = String
    //public typealias Iterator = (Key, Value)
    
    ///The length or size of this Map
    ///El tamaño de este Map
    public var count: Int {return elements.count}
    
    ///The length or size of this Map but used for Haxe users.
    ///---
    ///El número de elementos de éste Map pero para usuarios de Haxe.
    public var length: Int {return count}
    
    ///Max length of this Map.
    public var maxLength: Int {
        get {
            if _maxLength == -1 {
                return count
            }
            return _maxLength
        }
        set {_maxLength = newValue}}
    
    ///The internal elements of this Map.
    ///---
    ///Los elementos internos de éste Map.
    ///- Note: If you want to use it, use instead ``self``
    internal var elements: [(Key, Value)]
    
    ///Self.
    public var `self`: [(Key, Value)] {get {return self.elements} set {self.elements = newValue}}
    
    ///Initiates this Map.
    ///---
    ///Inicia éste Map.
    public init() {
        self.elements = []
    }
    public init(dictionaryLiteral dictionary: (Key, Value)...) {
        self.elements = dictionary
    }
    public init(dictionaryArrayLiteral arrayDictionary: [(Key, Value)]) {
        self.elements = arrayDictionary
    }
    public init(keys: [Key], values: [Value]) {
        self.elements = []
        for i in 0...keys.count - 1 {
            self.elements.append((keys[i], values[i]))
        }
    }
    public init(arrayLiteral arrayElements: [Any]...) {
        self.elements = []
        for element in arrayElements {
            elements.append((element[0] as! Key, element[1] as! Value))
        }
    }
    /*public init(stringLiteral value: String, firstDelimiter: Character, secondDelimiter: Character) {
        self.elements = []
        for stringElements in value.split(separator: firstDelimiter) {
            var twoElements = stringElements.split(separator: secondDelimiter)
            elements.append((twoElements[0] as! Key, twoElements[1] as! Value))
        }
    }*/
    
    
    ///Returns if the items exists.
    ///---
    ///Devuelve si el ítem existe.
    ///- Parameter _: Key of the item. (ID (llave) del ítem a recoger)
    ///- Returns: `true` if exists, `false` if not. (`true` si existe, `false` si no)
    public func exists(_ lookKey: Key) -> Bool {
        for (key, value) in elements {
            if key == lookKey {
                return true
            }
        }
        return false
    }
    
    ///Returns the value of the specified key.
    ///---
    ///Devuelve el valor del ID especificado.
    ///---
    ///# Example:
    ///```swift
    ///var map: RealMap<String, String> = ["hello": "ola"];
    ///do {
    ///  print(try map.get("hello"));
    ///} catch {
    ///  print(error);
    ///}
    ///```
    ///- Parameter _: Key of the item. ("ID" del valor)
    ///- Throws: `MapError`.
    ///- Returns: The value of the specified `key`. (El valor del "ID" especificado, pasado a `Value`)
    ///- Note: If you don't want it to throw errors, use `safeGet(_)`.<br><br>(Si no quieres que lance errores, usa `safeGet(_)`)
    public func get(_ key: Key /*, _ defaultReturn: Any? = nil*/) throws -> Value {
        for (name, val) in elements {
            if name == key {
                return val
            }
        }
        throw MapError.nonExists(key: key)
    }
    ///Devuelve el valor del ID especificado, sin lanzar errores.
    ///- Example:
    ///```swift
    ///var map: RealMap<String, String> = ["hello": "ola"];
    ///print(map.safeGet("hello"));
    ///```
    ///- Parameter _: "ID" del valor.
    ///- Returns: El valor del "ID" especificado, `nil` si no lo encuentra.
    ///- Note: Si quieres que lance errores, usa `get(_)`.
    public func safeGet(_ key: Key) -> Value? {
        do {
            return try get(key)
        } catch {
            return nil
        }
    }
    ///Maps the specified value to the specified `key`. If `key` doesn't exists, it will append a new key with value as `newValue`.
    ///
    ///Define el valor especificado, si no lo encuentra, lo añade.
    ///En caso de no encontrar el valor, añade por sí sólo uno nuevo por el método `append()`.
    ///- Parameter key: Key to search. Valor a buscar.
    ///- Parameter newValue: New value. Nuevo valor.
    ///- Returns: The new value. El nuevo valor.
    public mutating func set(key lookKey: Key, newValue: Value) /*throws*/ -> Value {
        if self.count > 0 {
            for i in 0...elements.count - 1 {
                if elements[i].0 == lookKey {
                    elements[i].1 = newValue
                    return elements[i].1
                }
            }
        }
        if self.count < self.maxLength {
            elements.append((lookKey, newValue))
        }
        return newValue
        //throw MapError.nonExists(key: lookKey)
    }
    ///Maps the specified value to the specified keys. If the key doesn't exists, it will append a new key with value as `newValue`.
    ///
    ///Define el valor especificado a los valores de `keys`, si no lo encuentra, lo añade.
    ///En caso de no encontrar el valor, añade por sí sólo uno nuevo por el método `append()`.
    ///- Parameter keys: Keys to search. IDs a buscar.
    ///- Parameter newValue: New value. Nuevo valor.
    ///- Returns: The keys. Los IDs.
    public mutating func set(keys lookKeys: [Key], newValue: Value) -> Value {
        for i in 0...lookKeys.count - 1 {
            set(key: lookKeys[i], newValue: newValue)
        }
        return newValue
    }
    
    @available(*, deprecated , message: "this is deprecated lol, I used this while this document was in development.")
    public mutating func safeSet(key lookKey: Key, newValue: Value) -> Value? {
        for i in 0...elements.count - 1 {
            if elements[i].0 == lookKey {
                elements[i].1 = newValue
                return elements[i].1
            }
        }
        return nil
    }
    
    ///Returns all the keys of this Map.
    ///
    ///Devuelve todos los ids de éste Map.
    ///- Returns: An Array of all the keys.
    public func keys() -> [Key] {
        var keyss: [Key] = []
        for (key, value) in self {
            keyss.append(key)
        }
        return keyss
    }
    ///Returns all the values of this Map.
    ///
    ///Devuelve todos los valores de éste Map.
    ///- Returns: An Array of all the values.
    public func values() -> [Value] {
        var valuess: [Value] = []
        for (key, value) in self {
            valuess.append(value)
        }
        return valuess
    }
    
    ///Returns an `Array<Array<Any>>` of the specified `Map`.
    ///
    ///Devuelve un `Array<Array<Any>>` del `Map` especificado.
    ///
    ///# Example
    ///```Swift
    ///var map: Map<String, String> = ["bro": "not funny", "haha": "gloglo"];
    ///print(Map.toArrayArray(m: map)); // prints [["bro", "not funny"], ["haha", "gloglo"]];
    ///```
    ///- Parameter m: `Map` to convert.
    ///- Returns: An `Array<Array<Any>>` containing all the information.
    public static func toArrayArray(m: Map) -> [[Any]] {
        var a: [[Any]] = []
        var keys = m.keys()
        var values = m.values()
        for i in 0...keys.count - 1 {
            a.append([keys[i], values[i]])
        }
        return a
    }
    ///Returns an `Array<Array<Any>>` of the specified `Map`.
    ///
    ///Devuelve un `Array<Array<Any>>` del `Map` especificado.
    ///
    ///# Example
    ///```Swift
    ///var map: Map<String, String> = ["bro": "not funny", "haha": "gloglo"];
    ///print(Map.toArrayArray(map)); // prints [["bro", "not funny"], ["haha", "gloglo"]];
    ///```
    ///- Parameter _: `Map` to convert.
    ///- Returns: An `Array<Array<Any>>` containing all the information.
    public static func toArrayArray(_ m: Map) -> [[Any]] {
        return toArrayArray(m: m)
    }
    
    // Iterator protocol
    private var times: Int = 0
    mutating func hasNext() -> Bool {
        let nextNumber = elements.startIndex + times
        
        guard nextNumber < elements.count else { return false }
        return true
    }
    public mutating func next() -> (Key, Value)? {
        let nextNumber = elements.startIndex + times
        
        guard nextNumber < elements.count else { return nil }
        
        times += 1
        return elements[nextNumber]
    }
    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = (Key, Value)
        var current: Int
        let maxItems: Int
        let start: Int
        let elements: [Element]
        
        mutating func hasNext() -> Bool {
            let nextNumber = start + current
            
            guard nextNumber < maxItems else { return false }
            return true
        }
        mutating public func next() async -> (Key, Value)? {
            let nextNumber = start + current
            
            guard nextNumber < maxItems else { return nil }
            
            current += 1
            return elements[nextNumber]
        }
        init(_ superior: Map) {
            self.start = superior.startIndex
            self.maxItems = superior.count
            self.elements = superior.`self`
            self.current = 0
        }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(self)
    }
    
    public subscript(index: Int) -> (Key, Value) {
        get {
            assert(index < elements.count, "Index " + String(index) + " out of range" + String(elements.count - 1))
            //assert(index <= 0, "Index out of range 0")
            return elements[index]
        }
        set {
            assert(index < elements.count, "Index \"" + String(index) + "\" out of range")
            //assert(index <= 0, "Index out of range 0")
            elements[index] = newValue
        }
    }
    
    // Collection methods:
    public var startIndex: Int {self.elements.startIndex}
    public var endIndex: Int {self.elements.endIndex}
    public func index(after i: Int) -> Int {return self.index(after: i)}
    public func index(_ i: Int, offsetBy distance: Int) -> Int {return self.elements.index(i, offsetBy: distance)}
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {return self.elements.index(i, offsetBy: distance, limitedBy: limit)}
    public func formIndex(after i: inout Int) {return self.elements.formIndex(after: &i)}
    public func distance(from start: Int, to end: Int) -> Int {return self.elements.distance(from: start, to: end)}
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<(Key, Value)>) throws -> R) rethrows -> R? {do {return try self.elements.withContiguousStorageIfAvailable(body)} catch {throw error}}
    ///Adds the element at the end of this Map.
    public mutating func append(element: (Key, Value)) {self.elements.append(element)}
    ///Adds all the elements at the end of this Map
    public mutating func append(elements: [(Key, Value)]) {for (key, value) in elements {self.elements.append((key, value))}}
    ///Adds the element at the end of this Map.
    public mutating func push(element: (Key, Value)) {self.append(element: element)}
    ///Adds all the elements at the end of this Map.
    public mutating func push(elements: [(Key, Value)]) {self.append(elements: elements)}
    ///Deletes the last item and returns it.
    public mutating func popLast() -> Element? {return self.elements.popLast()}
    //public func makeIterator() -> IndexingIterator<RealMap<Key, Value>> {return self.elements.makeIterator()}
    //public mutating func reverse() {return self.elements.reverse()}
    //public func dropLast(k: Int) -> ArraySlice<Element> {return self.elements.dropLast(k)}
    
    public func copy() -> Map<Key, Value> {
        return Map(arrayLiteral: Map.toArrayArray(m: self))
    }
    
    ///Retuns if each one contains all the keys of the other.
    ///- Warning: NOT CONFUSE WITH `==`!!!
    public static func ~= (a: Map<Key, Value>, b: Map<Key, Value>) -> Bool {
        var yes: Bool = true
        for key in b.keys() {
            if !a.exists(key) {
                return false
            }
        }
        return true
    }
    
    internal var _maxLength: Int = -1
}

extension Array {
    ///The number of elements in the array. But turned into Haxe.
    var length: Int {return self.count}
}
