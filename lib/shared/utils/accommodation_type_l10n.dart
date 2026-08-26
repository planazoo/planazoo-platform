import 'package:unp_calendario/l10n/app_localizations.dart';

/// Valores persistidos en Firestore (español legacy).
const List<String> accommodationTypeDbValues = [
  'Hotel',
  'Apartamento',
  'Hostal',
  'Casa',
  'Resort',
  'Camping',
  'Crucero',
  'Otro',
];

String localizedAccommodationType(AppLocalizations loc, String dbValue) {
  switch (dbValue) {
    case 'Hotel':
      return loc.accommodationTypeHotel;
    case 'Apartamento':
      return loc.accommodationTypeApartment;
    case 'Hostal':
      return loc.accommodationTypeHostel;
    case 'Casa':
      return loc.accommodationTypeHouse;
    case 'Resort':
      return loc.accommodationTypeResort;
    case 'Camping':
      return loc.accommodationTypeCamping;
    case 'Crucero':
      return loc.accommodationTypeCruise;
    case 'Otro':
      return loc.accommodationTypeOther;
    default:
      return dbValue;
  }
}
