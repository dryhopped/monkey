import 'dart:io';

import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/token/token.dart';

void start() {

    const String prompt = ">> ";

    while (true) {

        stdout.write(prompt);

        String inputText = stdin.readLineSync();
        if (inputText == null) {
            return;
        }

        Lexer lexer = new Lexer(inputText);
        for (Token token = lexer.nextToken(); token.type != Token.Eof; token = lexer.nextToken()) {

            if (token.type == Token.Illegal) {
                break;
            }

            print(token);

        }

    }

}

void main() {

    print("Hello! This is the Monkey Programming Language!");
    print("Feel free to type in commands.");

    start();

}