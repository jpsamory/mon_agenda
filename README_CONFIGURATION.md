# Mon Agenda — Configuration finale

## 1. Créer le projet Flutter

Dans un terminal (VS Code), à l'endroit où tu veux ton projet :

```bash
flutter create mon_agenda
cd mon_agenda
```

Puis **remplace** le dossier `lib/` généré par celui que je t'ai fourni, et remplace aussi `pubspec.yaml`.

Ensuite :
```bash
flutter pub get
```

## 2. Activer le français pour les dates (intl)

Dans `main.dart`, avant `runApp`, ajoute l'initialisation de la locale française :

```dart
import 'package:intl/date_symbol_data_local.dart';
// ...
await initializeDateFormatting('fr_FR', null);
```
(à ajouter juste après `WidgetsFlutterBinding.ensureInitialized();`)

## 3. Configuration Android (notifications)

Dans `android/app/src/main/AndroidManifest.xml`, ajoute ces permissions juste avant `<application>` :

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

## 4. Configuration iOS (notifications) — sera fait au moment du build via GitHub Actions

Dans `ios/Runner/AppDelegate.swift`, s'assurer que `UNUserNotificationCenter` a un delegate (généralement déjà géré par le plugin `flutter_local_notifications`, rien à faire de plus).

## 5. Tester en local sur Windows

```bash
flutter run -d chrome     # test rapide dans le navigateur
flutter run -d android    # si tu as un émulateur Android ou un téléphone Android en USB
```

## 6. Build iOS final (une fois l'app terminée)

C'est l'étape où on aura besoin de GitHub Actions (macOS runner) — je t'écris le fichier `.github/workflows/build_ios.yml` quand tu seras prêt à publier sur ton iPhone.
