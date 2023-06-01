# ChatGPTStreamAPI
This ChatGPTStreamAPI Demo app is very simple and easy to understand. 
This ChatGPTStreamAPI demo 

![video](/Media/ChatGPTStreamAPI.gif)


# Technical details

- Project Name  ==> ChatGPTStreamAPI
- Language      ==> Swift
- Architecture  ==> MVC
- Minimum os    ==> 16.2


# Description
The demo uses ChatGPTSwift package, which uses chat gpt stream api.
The server will stream chunks of data until complete, the method AsyncThrowingStream which you can loop using For-Loop like so:

Task {
    do {
        let stream = try await api.sendMessageStream(text: "What is ChatGPT?")
        for try await line in stream {
            print(line)
        }
    } catch {
        print(error.localizedDescription)
    }
}

# Table of Contents

- Chat UI - This will allow user to search for text result


# UI controls 

- Tableview
- TextField
- Alert
- Button

# Documentation 
Chat GPT - https://platform.openai.com/docs/api-reference/chat/create

#Framework
- ChatGPTSwift
