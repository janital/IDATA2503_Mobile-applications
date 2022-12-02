import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project/models/group.dart';
import 'package:project/models/user.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/chat_provder.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/screens/chat_screen.dart';
import 'package:project/screens/collaborators_screen.dart';
import 'package:project/styles/theme.dart';
import 'package:project/widgets/appbar_button.dart';
import 'package:project/widgets/loading_spinner.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String currentUser = ref.watch(authProvider).currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
        actions: [_newMessageButton(ref, context, currentUser)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _notificationsSection(context),
              const SizedBox(height: 32.0),
              _messagesSection(ref, context, currentUser),
            ],
          ),
        ),
      ),
    );
  }

  /// [AppBarButton] for creating a new message.
  AppBarButton _newMessageButton(
      WidgetRef ref, BuildContext context, String currentUser) {
    return AppBarButton(
      handler: () => _newMessage(ref, context, currentUser),
      tooltip: "create new message",
      icon: PhosphorIcons.pencilSimpleLineLight,
    );
  }

  /// Returns the notification section, displaying a title and a list of recent
  /// notifications.
  Flexible _notificationsSection(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "notifications",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          _notificationsList(),
        ],
      ),
    );
  }

  /// Returns a [ListView] of recent notifications.
  ListView _notificationsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) => _notificationsListItem(context),
    );
  }

  /// Returns a list item for notifications.
  Padding _notificationsListItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        "notification message",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  /// Returns the messages section, displaying a title and list of message groups
  /// the current user is participating in.
  Flexible _messagesSection(
    WidgetRef ref,
    BuildContext context,
    String currentUser,
  ) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "messages",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          _messagesList(ref, currentUser),
        ],
      ),
    );
  }

  /// Returns a list of message groups the user is participating in.
  Flexible _messagesList(WidgetRef ref, String currentUser) {
    return Flexible(
      fit: FlexFit.loose,
      child: StreamBuilder<List<Group?>>(
        stream: ref.watch(chatProvider).getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Group?> groups = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length,
              itemBuilder: (context, index) =>
                  _messageListItem(ref, groups[index]!, currentUser),
            );
          }
          return const LoadingSpinner();
        },
      ),
    );
  }

  /// Returns a list item for message groups.
  StreamBuilder<User?> _messageListItem(
    WidgetRef ref,
    Group group,
    String currentUser,
  ) {
    return StreamBuilder<User?>(
      stream: ref.watch(userProvider).getUser(
          group.members.firstWhere((element) => element != currentUser)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return GestureDetector(
            onTap: () => _openChat(context, group.groupId),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _messageImage(user),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _messageName(user, context),
                            _lastMessageSentAt(group, context)
                          ],
                        ),
                        const SizedBox(
                          height: 6.0,
                        ),
                        _recentMessage(group)
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return const LoadingSpinner();
      },
    );
  }

  /// The most recent message sent in the given group.
  Text _recentMessage(Group group) {
    return Text(
      group.recentMessage.isEmpty ? "no messages" : group.recentMessage,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// The date the last message was sent.
  Text _lastMessageSentAt(Group group, BuildContext context) {
    return Text(
      Jiffy(group.lastUpdated).fromNow(),
      style: Theme.of(context).textTheme.caption,
    );
  }

  /// The name of the user messaging with.
  Expanded _messageName(User user, BuildContext context) {
    return Expanded(
      child: Text(
        user.username,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  /// The image of the user messaging with.
  CircleAvatar _messageImage(User user) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(user.imageUrl!),
      backgroundColor: Colors.black,
    );
  }

  /// Returns styled solve it for title.
  Row _appBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "solve",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          "it",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Themes.primaryColor.shade50,
          ),
        )
      ],
    );
  }

  /// Creates a new group if group does not already exists, or opens the existing
  /// group for chatting.
  void _newMessage(WidgetRef ref, BuildContext context, String currentUser) {
    List<String> members = [];
    members.add(ref.watch(authProvider).currentUser!.uid);
    Navigator.of(context).pushNamed(CollaboratorsScreen.routeName, arguments: [
      members,
      CollaboratorsSearchType.collaborators,
      "",
    ]).then((value) {
      if (members.isNotEmpty) {
        // Does group exist
        ref.watch(chatProvider).getGroups().first.then((groups) {
          for (Group group in groups) {
            for (String member in members) {
              if (group.members.contains(member) && member != currentUser) {
                _openChat(context, group.groupId);
                return;
              }
            }
          }
          ref.read(chatProvider).saveGroup(Group(members: members)).then(
                (value) => _openChat(context, value.groupId),
              );
          return;
        });
      }
    });
  }

  /// Opens the [ChatScreen] for the chat's of the given [groupId].
  Future _openChat(BuildContext context, String groupId) {
    return Navigator.of(context).pushNamed(
      ChatScreen.routeName,
      arguments: groupId,
    );
  }
}