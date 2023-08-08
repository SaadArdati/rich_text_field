import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_field/utils.dart';

// Import or include the file where the findAsymmetry function is defined

void main() {
  test('findAsymmetry ***test***', () {
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB
    }) result = findAsymmetry('***', '***');

    expect(result.asymA, const TextSelection.collapsed(offset: -1));
    expect(result.asymB, const TextSelection.collapsed(offset: -1));
  });

  test('findAsymmetry *__test___', () {
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB
    }) result = findAsymmetry('*__', '___');

    expect(result.asymA, const TextSelection(baseOffset: 0, extentOffset: 1));
    expect(result.asymB, const TextSelection(baseOffset: 2, extentOffset: 3));
  });

  test('findAsymmetry __*test*__*', () {
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB
    }) result = findAsymmetry('__*', '*__*');

    expect(result.asymA, const TextSelection.collapsed(offset: -1));
    expect(result.asymB, const TextSelection(baseOffset: 3, extentOffset: 4));
  });

  test('findAsymmetry *****test***', () {
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB
    }) result = findAsymmetry('*****', '***');

    expect(result.asymA, const TextSelection(baseOffset: 0, extentOffset: 2));
    expect(result.asymB, const TextSelection.collapsed(offset: -1));
  });

  test('findAsymmetry ***test*****', () {
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB
    }) result = findAsymmetry('***', '*****');

    expect(result.asymA, const TextSelection.collapsed(offset: -1));
    expect(result.asymB, const TextSelection(baseOffset: 3, extentOffset: 5));
  });
}
