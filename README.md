# racardi
Racardi. Rains Discoiunt cards simple wallet

## Порядок сборки

1. Установить Flutter SDK (см. [environment] в `pubspec.yaml`, требуется Dart >=3.0.0 <4.0.0) и убедиться, что `flutter doctor` не выдаёт критических ошибок.
2. Установить зависимости проекта:
   ```
   flutter pub get
   ```
3. Сгенерировать локализацию и код Hive-адаптеров (build_runner):
   ```
   flutter gen-l10n
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. (Опционально) Пересоздать иконки и splash-экран при их изменении:
   ```
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```
5. Собрать приложение под нужную платформу:
   ```
   flutter build apk        # Android
   flutter build ios        # iOS (требуется macOS и Xcode)
   flutter build windows    # Windows
   flutter build linux      # Linux
   flutter build web        # Web
   ```
6. Для локального запуска в режиме разработки:
   ```
   flutter run
   ```
