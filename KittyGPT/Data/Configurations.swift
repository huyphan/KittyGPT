import Foundation

enum Backend: String {
    case openai = "openai"
    case bedrock_claude_instance_v1 = "bedrock-claude-instant-v1"
    case bedrock_claude_v2 = "bedrock-claude-v2"
    case bedrock_claude_v3_haiku = "bedrock-claude-v3-haiku"
    case bedrock_claude_v3_sonnet = "bedrock-claude-v3-sonnet"
}

enum AWSCredsMode: String {
    case profile = "profile"
    case hardcoded = "hardcoded"
}


class Configurations {
    static var awsCredsMode: AWSCredsMode {
      set {
          UserDefaults.standard.set(newValue.rawValue, forKey: "awsCredsMode")
      }
      get {
          return AWSCredsMode(rawValue: UserDefaults.standard.string(forKey: "awsCredsMode") ?? AWSCredsMode.profile.rawValue)!
      }
    }

    static var backend: Backend {
      set {
          UserDefaults.standard.set(newValue.rawValue, forKey: "backend")
      }
      get {
          return Backend(rawValue: UserDefaults.standard.string(forKey: "backend") ?? Backend.openai.rawValue)!
      }
    }

    static var awsAccessKey: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "awsAccessKey")
      }
      get {
          return UserDefaults.standard.string(forKey: "awsAccessKey") ?? ""
      }
    }

    static var awsSecretKey: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "awsSecretKey")
      }
      get {
          return UserDefaults.standard.string(forKey: "awsSecretKey") ?? ""
      }
    }

    static var awsSessionToken: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "awsSessionToken")
      }
      get {
          return UserDefaults.standard.string(forKey: "awsSessionToken") ?? ""
      }
    }
    
    static var awsRegion: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "awsRegion")
      }
      get {
          return UserDefaults.standard.string(forKey: "awsRegion") ?? ""
      }
    }

    static var awsProfile: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "awsProfile")
      }
      get {
          return UserDefaults.standard.string(forKey: "awsProfile") ?? "default"
      }
    }

    static var maxReturnedTokens: Int {
      set {
          UserDefaults.standard.set(newValue, forKey: "maxReturnedTokens")
      }
      get {
          let currentMaxReturnedTokens = UserDefaults.standard.integer(forKey: "maxReturnedTokens")
          if (currentMaxReturnedTokens <= 0) {
              return 256
          }
          return currentMaxReturnedTokens
      }
    }
}
