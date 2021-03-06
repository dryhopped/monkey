import 'dart:io';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/parser/parser.dart';
import 'package:monkey/object/object.dart';
import 'package:monkey/interpreter/interpreter.dart';

const MONKEY_FACE = r"""             __,__
    .--.  .-"     "-.  .--.
   / .. \/  .-. .-.  \/ .. \
  | |  '|  /   Y   \  |'  | |
  | \   \  \ 0 | 0 /  /   / |
   \ '- ,\.-""" +
     '"""""""' +
     """-./, -' /
    ''-' /_   ^ ^   _\\ '-''
        |  \\._   _./  |
        \\   \\ '~' /   /
         '._ '-=-' _.'
            '-----'""";

void start() {

    const String prompt = '>> ';

    while (true) {

        stdout.write(prompt);

        String inputText = stdin.readLineSync();
        if (inputText == null) {
            return;
        }

        Parser parser = new Parser(new Lexer(inputText));
        Program program = parser.parseProgram();
        if (parser.errors.isNotEmpty) {
            printParserErrors(parser.errors);
            continue;
        }

        MonkeyObject result = interpret(program);
        if (result != null) print(result.inspect());

    }

}

void printParserErrors(List<String> errors) {

    print(MONKEY_FACE);
    print('Woops! We ran into some monkey business here!');
    print(' parser errors:');

    errors.forEach((error) {
        print('\t$error');
    });

}

void main() {

    print('Hello! This is the Monkey Programming Language!');
    print('Feel free to type in commands.');

    start();

}