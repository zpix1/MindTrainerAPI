#include <iostream>
#include <string>

#include "json.hpp"
using json = nlohmann::json;
using namespace std;

// Все сложно с типами, но думаю разберетесь
// Доки по nlohmann::json где-то есть, но в принципе все понятно:

int main(int argc, char* argv[]){
    // Распарсить строку в объект
    auto data = json::parse(argv[1]);
    // data["mode"].get<string>() - отдай по ключу mode значение типа string
    if (data["mode"].get<string>() == "generate"){
        int maxval = stoi(data["config"]["maxval1"].get<string>());
        srand(stoi(data["seed"].get<string>()));
        int a = rand() % maxval;
        int b = rand() % maxval;
        string ans = to_string(a) + " + " + to_string(b) + " = ?";
        json result;
        result["question"] = to_string(a) + " + " + to_string(b) + " = ?";
        result["answer"] = to_string(a+b);
        cout << result.dump();
    }  else {
        int user_answer = stoi(data["user_answer"].get<string>());
        int answer = stoi(data["answer"].get<string>());
        user_answer == answer ? cout <<  "true" : cout <<  "false";
        cout << endl;
    }
}