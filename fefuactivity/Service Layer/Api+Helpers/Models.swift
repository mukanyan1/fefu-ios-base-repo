import Foundation

struct UserRegBody: Encodable {
    let login: String
    let password: String
    let name: String
    let gender: Int
}

struct UserLoginBody: Encodable {
    let login: String
    let password: String
}

struct ApiError: Decodable {
    let errors: Dictionary<String, [String]>
}

struct LoginErrors: Decodable {
    let login: [String]
}

struct Gender: Decodable {
    let code: Int
    let name: String
}

struct UserModel: Decodable, Identifiable {
    let id: Int
    let name: String
    let login: String
    let gender: Gender
}

struct AuthUserModel: Decodable {
    let token: String
    let user: UserModel
}
