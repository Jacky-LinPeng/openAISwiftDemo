//
//  AppDelegate.swift
//  OpenAIDemo
//
//  Created by mac on 2023/11/5.
//

import UIKit
import OpenAISwift
enum APIResult {
   case success(String)
   case failure(Error)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // 1、开梯子！！！，不然无法访问接口
    // 2、openai后台获取Key：https://platform.openai.com/account/api-keys
    private static let authToken = "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"
    let openAPI = OpenAISwift(config: .makeDefaultOpenAI(apiKey: authToken))
    
    func sendRequest(query: String, completion: @escaping (APIResult) -> ()) {
        print("reqeuest")
        testSendMsg(query: query) { res in
            print(res)
        }
        // 在异步上下文中调用 fetchDataFromServer
        async {
            do {
                await test(query: query)
            } catch {
                // 处理错误
            }
        }
    }
    
    func testSendMsg(query: String,completion: @escaping (APIResult) -> ()) {
        openAPI.sendCompletion(with: query, maxTokens: 20) { result in

            switch result {
            case .success(let openApi):

                guard let response = openApi.choices else {
                    print("=====")
                    return
                }

                var returnString: String = ""

                DispatchQueue.main.async {
                    for choice in response {
                        print("===="+choice.text)
                        returnString.append(choice.text)
                    }
                    completion(.success(returnString))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
        
       
    }
    
    func test(query: String) async {
        do {
            let chat: [ChatMessage] = [
                ChatMessage(role: .assistant, content: "You are a helpful assistant."),
//                ChatMessage(role: .user, content: "Who won the world series in 2020?"),
//                ChatMessage(role: .assistant, content: "The Los Angeles Dodgers won the World Series in 2020."),
//                ChatMessage(role: .user, content: "my name is JK"),
                ChatMessage(role: .user, content: query)
            ]
                        
            let result = try await openAPI.sendChat(with: chat,model: .chat(.chatgpt), user: "sss", choices: 1,maxTokens: 100)
            print(result)
            guard let response = result.choices else {
                print("1=====")
                return
            }
//
//            var returnString: String = "=====>"
            DispatchQueue.main.async {
                for choice in response {
//                    print("1===="+choice.text)
                    if let a = choice.message.content {
                        print("1===="+a)
//                        returnString.append(a)
                    }
                }
//                completion(.success(returnString))
            }
            
            
        } catch let error {
            // ...
            print("err====="+error.localizedDescription)
        }
        
    }
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let query = "我问你，我叫什么名字"
            self.sendRequest(query: query) { result in
    //            print(result)
            }
        }
        
        let query = "我的名字叫林里，请记住我名字"
        sendRequest(query: query) { result in
//            print(result)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

