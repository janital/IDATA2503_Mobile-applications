import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project/models/project.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/styles/curve_clipper.dart';
import 'package:project/widgets/appbar_button.dart';
import 'package:project/widgets/project_pop_up_menu.dart';
import 'package:project/widgets/user_list_item.dart';

/// Scaffold/screen displaying a preview of the project with
/// description and collaborators.
class ProjectPreviewScreen extends StatelessWidget {
  static const routeName = "/project-preview";

  /// Creates an instance of [ProjectPreviewScreen].
  const ProjectPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Project project = ModalRoute.of(context)!.settings.arguments as Project;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: AppBarButton(
          icon: PhosphorIcons.caretLeftLight,
          handler: () => Navigator.of(context).pop(),
          tooltip: "Go back",
          color: Colors.white,
        ),
        actions: <Widget>[
          ProjectPopUpMenu(
            project: project,
            currentRouteName: "/project-preview",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                height: 420,
                width: double.infinity,
                color: const Color.fromRGBO(92, 0, 241, 1),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 60),
                    Image.asset(
                      project.imageUrl,
                      height: 270,
                    ),
                    Text(
                      project.title.toLowerCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
              ),
              child: Text(
                project.description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    "collaborators",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  UserListItem(
                    handler: () => Navigator.of(context)
                        .pushNamed(ProfileScreen.routeName),
                    name: "Jane Cooper",
                    imageUrl: "assets/images/jane_cooper.png",
                    isOwner: true,
                  ),
                  UserListItem(
                    handler: () => Navigator.of(context)
                        .pushNamed(ProfileScreen.routeName),
                    name: "Leslie Alexander",
                    imageUrl: "assets/images/leslie_alexander.png",
                  ),
                  UserListItem(
                    handler: () => Navigator.of(context)
                        .pushNamed(ProfileScreen.routeName),
                    name: "Guy Hawkins",
                    imageUrl: "assets/images/guy_hawkins.png",
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  const Text(
                    "collaborators",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    project.lastUpdated != null &&
                            project.lastUpdated!.isNotEmpty
                        ? Jiffy("31/10/2022", "dd/MM/yyyy")
                            .format("EEEE, MMMM do yyyy")
                            .toLowerCase()
                        : "never updated",
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}