import Foundation

/// En minimal JSON Schema-validator for den delmængde af draft 2020-12, som
/// `bh-content-v1.schema.json` faktisk bruger.
///
/// ## Hvorfor den er skrevet i hånden
///
/// R-009 forbyder tredjeparts-SDK'er. Forbuddet er skrevet for app-binæren, men
/// et testafhængigheds-træ er også en forsyningskæde, og et skema på 300 linjer
/// retfærdiggør ikke en. Delmængden nedenfor er dét, skemaet bruger — møder
/// validatoren et nøgleord, den ikke kender, **fejler den højlydt** frem for at
/// lade det passere. Det er forskellen på en validator og en falsk tryghed.
///
/// Understøttet: `type`, `required`, `properties`, `additionalProperties`,
/// `items`, `enum`, `const`, `pattern`, `minLength`, `minItems`, `maxItems`,
/// `minimum`, `maximum`, `exclusiveMaximum`, `$ref`, `$defs`, `oneOf`, `allOf`,
/// `if`/`then`, `format`.
struct JSONSchemaValidator {

    struct ValidationError: Error, CustomStringConvertible, Hashable {
        let path: String
        let message: String

        var description: String { "\(path.isEmpty ? "(rod)" : path): \(message)" }
    }

    /// Nøgleord, der er rene annotationer og trygt kan ignoreres.
    private static let ignoredKeywords: Set<String> = [
        "$schema", "$id", "title", "description", "default", "examples", "$comment",
    ]

    private let root: [String: Any]

    init(schema: Data) throws {
        guard let object = try JSONSerialization.jsonObject(with: schema) as? [String: Any] else {
            throw ValidationError(path: "", message: "Skemaet er ikke et JSON-objekt")
        }
        root = object
    }

    /// Validerer et dokument og returnerer **alle** fejl, ikke kun den første.
    /// En forfatter, der skal rette syv ting, skal have dem at vide på én gang.
    func validate(_ document: Data) throws -> [ValidationError] {
        let instance = try JSONSerialization.jsonObject(with: document)
        var errors: [ValidationError] = []
        validate(instance, against: root, at: "", into: &errors)
        return errors
    }

    // MARK: - Kernen

    private func validate(
        _ instance: Any,
        against schema: [String: Any],
        at path: String,
        into errors: inout [ValidationError]
    ) {
        // $ref slår alt andet i samme objekt.
        if let reference = schema["$ref"] as? String {
            guard let resolved = resolve(reference) else {
                errors.append(ValidationError(path: path, message: "Kan ikke slå $ref '\(reference)' op"))
                return
            }
            validate(instance, against: resolved, at: path, into: &errors)
            return
        }

        for (keyword, value) in schema {
            if Self.ignoredKeywords.contains(keyword) || keyword == "$defs" { continue }

            switch keyword {
            case "type":
                checkType(instance, value, path, &errors)
            case "const":
                if !isEqual(instance, value) {
                    errors.append(ValidationError(path: path, message: "Skal være \(value)"))
                }
            case "enum":
                if let allowed = value as? [Any], !allowed.contains(where: { isEqual(instance, $0) }) {
                    errors.append(ValidationError(
                        path: path,
                        message: "'\(instance)' er ikke en tilladt værdi"
                    ))
                }
            case "required":
                checkRequired(instance, value, path, &errors)
            case "properties":
                checkProperties(instance, value, schema, path, &errors)
            case "additionalProperties":
                checkAdditionalProperties(instance, value, schema, path, &errors)
            case "items":
                checkItems(instance, value, path, &errors)
            case "minItems", "maxItems":
                checkItemCount(instance, keyword, value, path, &errors)
            case "minLength":
                if let text = instance as? String, let minimum = value as? Int, text.count < minimum {
                    errors.append(ValidationError(path: path, message: "Skal være mindst \(minimum) tegn"))
                }
            case "pattern":
                checkPattern(instance, value, path, &errors)
            case "minimum", "maximum", "exclusiveMaximum":
                checkBound(instance, keyword, value, path, &errors)
            case "oneOf":
                checkOneOf(instance, value, path, &errors)
            case "allOf":
                if let schemas = value as? [[String: Any]] {
                    for subschema in schemas {
                        validate(instance, against: subschema, at: path, into: &errors)
                    }
                }
            case "if":
                checkConditional(instance, schema, path, &errors)
            case "then", "else":
                continue  // håndteret sammen med "if"
            case "format":
                checkFormat(instance, value, path, &errors)
            default:
                // Bevidst højlydt. Et ukendt nøgleord betyder, at skemaet
                // udtrykker en regel, validatoren ikke håndhæver.
                errors.append(ValidationError(
                    path: path,
                    message: "Validatoren kender ikke nøgleordet '\(keyword)' — udvid den før skemaet"
                ))
            }
        }
    }

    // MARK: - Nøgleordene

    private func checkType(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        let allowed: [String] =
            if let single = value as? String { [single] }
            else if let many = value as? [String] { many }
            else { [] }

        guard !allowed.isEmpty else { return }
        guard !allowed.contains(where: { matches(instance, type: $0) }) else { return }

        errors.append(ValidationError(
            path: path,
            message: "Forventede \(allowed.joined(separator: " eller ")), fik \(describe(instance))"
        ))
    }

    private func checkRequired(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        guard let object = instance as? [String: Any], let keys = value as? [String] else { return }
        for key in keys where object[key] == nil {
            errors.append(ValidationError(path: path, message: "Mangler obligatorisk felt '\(key)'"))
        }
    }

    private func checkProperties(
        _ instance: Any, _ value: Any, _ schema: [String: Any],
        _ path: String, _ errors: inout [ValidationError]
    ) {
        guard let object = instance as? [String: Any],
              let properties = value as? [String: [String: Any]] else { return }
        for (key, subschema) in properties {
            guard let child = object[key] else { continue }
            validate(child, against: subschema, at: join(path, key), into: &errors)
        }
    }

    private func checkAdditionalProperties(
        _ instance: Any, _ value: Any, _ schema: [String: Any],
        _ path: String, _ errors: inout [ValidationError]
    ) {
        guard let object = instance as? [String: Any],
              let allowed = value as? Bool, allowed == false else { return }
        let declared = Set((schema["properties"] as? [String: Any])?.keys ?? [:].keys)
        for key in object.keys where !declared.contains(key) {
            errors.append(ValidationError(path: path, message: "Ukendt felt '\(key)'"))
        }
    }

    private func checkItems(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        guard let array = instance as? [Any], let subschema = value as? [String: Any] else { return }
        for (index, element) in array.enumerated() {
            validate(element, against: subschema, at: "\(path)[\(index)]", into: &errors)
        }
    }

    private func checkItemCount(
        _ instance: Any, _ keyword: String, _ value: Any,
        _ path: String, _ errors: inout [ValidationError]
    ) {
        guard let array = instance as? [Any], let bound = value as? Int else { return }
        if keyword == "minItems", array.count < bound {
            errors.append(ValidationError(path: path, message: "Skal have mindst \(bound) elementer, har \(array.count)"))
        }
        if keyword == "maxItems", array.count > bound {
            errors.append(ValidationError(path: path, message: "Må højst have \(bound) elementer, har \(array.count)"))
        }
    }

    private func checkPattern(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        guard let text = instance as? String, let pattern = value as? String else { return }
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            errors.append(ValidationError(path: path, message: "Ugyldigt mønster i skemaet: \(pattern)"))
            return
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        if regex.firstMatch(in: text, range: range) == nil {
            errors.append(ValidationError(path: path, message: "'\(text)' matcher ikke mønsteret \(pattern)"))
        }
    }

    private func checkBound(
        _ instance: Any, _ keyword: String, _ value: Any,
        _ path: String, _ errors: inout [ValidationError]
    ) {
        guard let number = numeric(instance), let bound = numeric(value) else { return }
        switch keyword {
        case "minimum" where number < bound:
            errors.append(ValidationError(path: path, message: "Skal være mindst \(bound)"))
        case "maximum" where number > bound:
            errors.append(ValidationError(path: path, message: "Må højst være \(bound)"))
        case "exclusiveMaximum" where number >= bound:
            errors.append(ValidationError(path: path, message: "Skal være mindre end \(bound)"))
        default:
            break
        }
    }

    private func checkOneOf(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        guard let schemas = value as? [[String: Any]] else { return }
        let matches = schemas.filter { subschema in
            var scratch: [ValidationError] = []
            validate(instance, against: subschema, at: path, into: &scratch)
            return scratch.isEmpty
        }
        if matches.count != 1 {
            errors.append(ValidationError(
                path: path,
                message: "Skulle matche præcis én af \(schemas.count) former, matchede \(matches.count)"
            ))
        }
    }

    private func checkConditional(
        _ instance: Any, _ schema: [String: Any],
        _ path: String, _ errors: inout [ValidationError]
    ) {
        guard let condition = schema["if"] as? [String: Any] else { return }
        var scratch: [ValidationError] = []
        validate(instance, against: condition, at: path, into: &scratch)

        let branch = scratch.isEmpty ? "then" : "else"
        if let subschema = schema[branch] as? [String: Any] {
            validate(instance, against: subschema, at: path, into: &errors)
        }
    }

    private func checkFormat(_ instance: Any, _ value: Any, _ path: String, _ errors: inout [ValidationError]) {
        guard let text = instance as? String, let format = value as? String else { return }
        switch format {
        case "date":
            let pattern = /^\d{4}-\d{2}-\d{2}$/
            if text.wholeMatch(of: pattern) == nil {
                errors.append(ValidationError(path: path, message: "'\(text)' er ikke en dato på formen ÅÅÅÅ-MM-DD"))
            }
        case "uri":
            if URL(string: text) == nil || !text.contains(":") {
                errors.append(ValidationError(path: path, message: "'\(text)' er ikke en gyldig URI"))
            }
        default:
            break  // Ukendte formater er annotationer i draft 2020-12.
        }
    }

    // MARK: - Hjælpere

    private func resolve(_ reference: String) -> [String: Any]? {
        guard reference.hasPrefix("#/") else { return nil }
        var node: Any = root
        for component in reference.dropFirst(2).split(separator: "/") {
            guard let object = node as? [String: Any],
                  let next = object[String(component)] else { return nil }
            node = next
        }
        return node as? [String: Any]
    }

    private func matches(_ instance: Any, type: String) -> Bool {
        switch type {
        case "null": instance is NSNull
        case "boolean": isBoolean(instance)
        case "string": instance is String
        case "array": instance is [Any]
        case "object": instance is [String: Any]
        case "integer": !isBoolean(instance) && (numeric(instance).map { $0 == $0.rounded() } ?? false)
        case "number": !isBoolean(instance) && numeric(instance) != nil
        default: false
        }
    }

    /// `JSONSerialization` giver booleans som `NSNumber`. Uden dette skel ville
    /// `true` bestå en `integer`-kontrol.
    private func isBoolean(_ instance: Any) -> Bool {
        guard let number = instance as? NSNumber else { return false }
        return CFGetTypeID(number) == CFBooleanGetTypeID()
    }

    private func numeric(_ instance: Any) -> Double? {
        guard let number = instance as? NSNumber, !isBoolean(instance) else { return nil }
        return number.doubleValue
    }

    private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        if let a = lhs as? String, let b = rhs as? String { return a == b }
        if let a = numeric(lhs), let b = numeric(rhs) { return a == b }
        if isBoolean(lhs), isBoolean(rhs) {
            return (lhs as? NSNumber)?.boolValue == (rhs as? NSNumber)?.boolValue
        }
        if lhs is NSNull, rhs is NSNull { return true }
        return false
    }

    private func describe(_ instance: Any) -> String {
        switch instance {
        case is NSNull: "null"
        case let value where isBoolean(value): "boolean"
        case is String: "string"
        case is [Any]: "array"
        case is [String: Any]: "object"
        case is NSNumber: "number"
        default: "ukendt"
        }
    }

    private func join(_ path: String, _ key: String) -> String {
        path.isEmpty ? key : "\(path).\(key)"
    }
}
