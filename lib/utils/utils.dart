import 'dart:math';
import 'package:units_converter/models/property.dart';
import 'package:units_converter/properties/amount_of_substance.dart';
import 'package:units_converter/properties/length.dart';
import 'package:units_converter/properties/area.dart';
import 'package:units_converter/properties/molar_mass.dart';
import 'package:units_converter/properties/molar_volume.dart';
import 'package:units_converter/properties/reciprocal_of_molar_mass.dart';
import 'package:units_converter/properties/volume.dart';
import 'package:units_converter/properties/time.dart';
import 'package:units_converter/properties/temperature.dart';
import 'package:units_converter/properties/speed.dart';
import 'package:units_converter/properties/si_prefixes.dart';
import 'package:units_converter/properties/mass.dart';
import 'package:units_converter/properties/pressure.dart';
import 'package:units_converter/properties/energy.dart';
import 'package:units_converter/properties/angle.dart';
import 'package:units_converter/properties/power.dart';
import 'package:units_converter/properties/force.dart';
import 'package:units_converter/properties/torque.dart';
import 'package:units_converter/properties/fuel_consumption.dart';
import 'package:units_converter/properties/digital_data.dart';
import 'package:units_converter/properties/shoe_size.dart';
import 'package:units_converter/properties/density.dart';

Property? getPropertyFromEnum(dynamic propertyEnum) {
  switch (propertyEnum.runtimeType) {
    case AMOUNT_OF_SUBSTANCE:
      return AmountOfSubstance();
    case ANGLE:
      return Angle();
    case AREA:
      return Area();
    case DENSITY:
      return Density();
    case DIGITAL_DATA:
      return DigitalData();
    case ENERGY:
      return Energy();
    case FORCE:
      return Force();
    case FUEL_CONSUMPTION:
      return FuelConsumption();
    case LENGTH:
      return Length();
    case MASS:
      return Mass();
    case MOLAR_MASS:
      return MolarMass();
    case MOLAR_VOLUME:
      return MolarVolume();
    case POWER:
      return Power();
    case PRESSURE:
      return Pressure();
    case RECIPROCAL_OF_MOLAR_MASS:
      return ReciprocalOfMolarMass();
    case SHOE_SIZE:
      return ShoeSize();
    case SI_PREFIXES:
      return SIPrefixes();
    case SPEED:
      return Speed();
    case TEMPERATURE:
      return Temperature();
    case TIME:
      return Time();
    case TORQUE:
      return Torque();
    case VOLUME:
      return Volume();
    default:
      {
        assert(false, "${propertyEnum.runtimeType} is not a valid enum type");
        return null;
      }
  }
}

/// Given a double value it returns its rapresentation as a string with few
/// tweaks: [significantFigures] is the number of significant figures to keep,
/// [removeTrailingZeros] say if non important zeros should be removed.
/// E.g. 1.000000 --> 1
String valueToString(
  double value,
  int significantFigures,
  bool removeTrailingZeros,
  bool useScientificNotation,
) {
  //Round to a fixed number of significant figures
  String stringValue;
  if (useScientificNotation) {
    stringValue = value.toStringAsPrecision(significantFigures);
  } else {
    stringValue = value.toStringAsFixed(significantFigures);
  }

  /**
   * [stringValue] can be in multiple form:
   *  - x     (an integer)
   *  - x.y   (a decimal)
   *  - xez   (integer with an exponential part)
   *  - x.yez (decimal with an exponential part)
   */

  List<String> splittedNumbers = stringValue.split('.');
  String integerPart = splittedNumbers[0];
  String? decimalPart, exponentialPart;

  // x.y and x.yez
  if (splittedNumbers.length == 2) {
    splittedNumbers = splittedNumbers[1].split('e');
    decimalPart = splittedNumbers[0];

    // x.yez
    if (splittedNumbers.length == 2) {
      exponentialPart = splittedNumbers[1];
    }
  }
  // x and xez
  else {
    splittedNumbers = splittedNumbers[0].split('e');

    // xez
    if (splittedNumbers.length == 2) {
      integerPart = splittedNumbers[0];
      exponentialPart = splittedNumbers[1];
    }
  }

  //if the user want to remove the trailing zeros
  if (removeTrailingZeros && decimalPart != null) {
    //remove trailing zeros (just fractional part)
    int firstZeroIndex = decimalPart.length;
    for (; firstZeroIndex > 0; firstZeroIndex--) {
      String charAtIndex =
          decimalPart.substring(firstZeroIndex - 1, firstZeroIndex);
      if (charAtIndex != '0') break;
    }
    decimalPart = decimalPart.substring(0, firstZeroIndex);
    if (decimalPart == "") {
      decimalPart = null;
    }
  }

  if (!useScientificNotation && exponentialPart != null) {
    // It means that the absolute value of [value] is greater or equal than 1e21
    // (see the documentation of .toStringAsFixed() method)

    /**
     *  There are 2 cases:
     *  - x.ye+z
     *  - xe+z
     */
    int exponentialNumber = int.parse(exponentialPart);
    // x.ye+z
    if (decimalPart != null) {
      if (decimalPart.length < exponentialNumber) {
        decimalPart = decimalPart +
            ''.padRight(exponentialNumber - decimalPart.length, '0');
      }
      integerPart = integerPart + decimalPart.substring(0, exponentialNumber);
      decimalPart = decimalPart.substring(exponentialNumber);
      if (decimalPart == '') decimalPart = null;
    }
    // xe+z
    else {
      integerPart = integerPart + ''.padRight(exponentialNumber, '0');
    }
    exponentialPart = null;
  }

  //Recompose the string
  String finalString = integerPart;
  if (decimalPart != null) {
    finalString = '$finalString.$decimalPart';
  }
  if (exponentialPart != null) {
    finalString = '${finalString}e$exponentialPart';
  }
  return finalString;
}

/// Convert [stringDec], the String representation of a decimal value (e.g.
/// "10"), to another base depending of the value of [base] (E.g. 16 for
/// hexadecimal, 2 for binary, etc.).
String decToBase(String stringDec, int base) {
  var regExp = getBaseRegExp(10);
  if (!regExp.hasMatch(stringDec)) return '';

  var myString = '';
  String restoString;
  int resto;
  var dec = int.parse(stringDec);
  while (dec > 0) {
    resto = (dec % base);
    restoString = resto.toString();
    if (resto >= 10) {
      restoString = String.fromCharCode(resto + 55);
    }
    myString = restoString + myString; //aggiungo in testa
    dec = dec ~/ base;
  }
  return myString;
}

/// Convert [toBeConverted], the String representation of a value with a certain
/// [base] (E.g. 16 for hexadecimal, 2 for binary, etc.), to another String
/// expressed with the decimal base.
String baseToDec(String toBeConverted, int base) {
  toBeConverted = toBeConverted.toUpperCase();

  var regExp = getBaseRegExp(base);

  if (!regExp.hasMatch(toBeConverted)) return '';

  int conversion = 0;
  int len = toBeConverted.length;
  for (int i = 0; i < len; i++) {
    int unitCode = toBeConverted.codeUnitAt(i);
    if (unitCode >= 65 && unitCode <= 70) {
      // from A to F
      conversion =
          conversion + (unitCode - 55) * pow(base, len - i - 1).toInt();
    } else if (unitCode >= 48 && unitCode <= 57) {
      // from 0 to 9
      conversion =
          conversion + (unitCode - 48) * pow(base, len - i - 1).toInt();
    }
  }
  return conversion.toString();
}

/// Returns a regular expression that could match a certain String expressed
/// with a certain [base].
RegExp getBaseRegExp(int base) {
  assert([2, 8, 10, 16].contains(base), 'Base not supported');
  switch (base) {
    case 2:
      return RegExp(r'^[0-1]+$');
    case 8:
      return RegExp(r'^[0-7]+$');
    case 16:
      return RegExp(r'^[0-9A-Fa-f]+$');
    case 10:
    default:
      return RegExp(r'^[0-9]+$');
  }
}
