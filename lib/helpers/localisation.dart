import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/app_translations.dart';

extension Localisation on String {

  String localise(){
      return AppTranslations.get(this);
    }

}