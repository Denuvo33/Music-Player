import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static notifInit() async {
    //  await AwesomeNotifications().removeChannel('channel_key');
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
            enableLights: false,
            channelGroupKey: 'basic_cg',
            channelKey: 'channel_key4',
            enableVibration: false,
            importance: NotificationImportance.Default,
            criticalAlerts: false,
            playSound: false,
            defaultPrivacy: NotificationPrivacy.Public,
            locked: true,
            channelName: 'channel_name4',
            channelDescription: 'Notification channel for basic tests',
          )
        ],
        debug: true);
  }

  static showNotif({required String title, required String body}) {
    AwesomeNotifications().createNotification(
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
              key: 'back',
              label: 'back',
              autoDismissible: false,
              icon: 'asset://assets/images/next.png')
        ],
        content: NotificationContent(
          id: 10,
          channelKey: 'channel_key4', //Same as above in initilize,
          title: title,
          actionType: ActionType.Default, locked: true,
          body: body,
          fullScreenIntent: true,
          autoDismissible: false,
          //   displayOnBackground: true,
          // displayOnForeground: true,
          criticalAlert: false,
          //  category: NotificationCategory.Progress),
        ));
  }
}
