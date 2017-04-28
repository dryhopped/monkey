import 'package:test/test.dart';
import 'helpers.dart';

void main() {

    test('test interpret integer expression', () {

        testInterpretInteger('5', 5);
        testInterpretInteger('10', 10);

    });

    test('test interpret boolean expression', () {

        testInterpretBoolean('true', true);
        testInterpretBoolean('false', false);

    });

}