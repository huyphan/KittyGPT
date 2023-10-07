import Foundation

enum Backend: String {
    case openai = "openai"
    case bedrock_claude_instance_1 = "bedrock-claude-instant-v1"
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
          return AWSCredsMode(rawValue: UserDefaults.standard.string(forKey: "awsCredsMode")!) ?? AWSCredsMode.profile
      }
    }

    static var backend: Backend {
      set {
          UserDefaults.standard.set(newValue.rawValue, forKey: "backend")
      }
      get {
          return Backend(rawValue: UserDefaults.standard.string(forKey: "backend")!) ?? Backend.openai
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
          return UserDefaults.standard.string(forKey: "awsProfile") ?? ""
      }
    }
    
    static var openAIApiKey: String {
      set {
          UserDefaults.standard.set(newValue, forKey: "openAIApiKey")
      }
      get {
          return UserDefaults.standard.string(forKey: "openAIApiKey") ?? ""
      }
    }
    
    static let maxReturnedToken = 256
}
