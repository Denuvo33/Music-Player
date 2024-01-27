import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/model/player_controller.dart';

class NotificationService {
  var controller = Get.find<PlayerController>();

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
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static showNotif({required String title, required String body}) {
    AwesomeNotifications().createNotification(
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
              key: 'back',
              label: 'Back',
              autoDismissible: false,
              actionType: ActionType.SilentAction,
              color: Colors.deepPurple
              // icon: 'asset://assets/images/next.png')
              ),
          NotificationActionButton(
              key: 'pause',
              label: 'Pause',
              autoDismissible: false,
              actionType: ActionType.SilentAction,
              color: Colors.deepPurple
              // icon: 'asset://assets/images/next.png')
              ),
          NotificationActionButton(
              key: 'next',
              label: 'Next',
              autoDismissible: false,
              actionType: ActionType.SilentAction,
              color: Colors.deepPurple
              // icon: 'asset://assets/images/next.png')
              )
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
          //category: NotificationCategory.me)
        ));
  }
}
