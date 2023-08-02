import 'dart:async';

import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/services/local_authentication_service.dart';
import 'package:ente_auth/services/user_service.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/account/sessions_page.dart';
import 'package:ente_auth/ui/components/captioned_text_widget.dart';
import 'package:ente_auth/ui/components/expandable_menu_item_widget.dart';
import 'package:ente_auth/ui/components/menu_item_widget.dart';
import 'package:ente_auth/ui/components/toggle_switch_widget.dart';
import 'package:ente_auth/ui/settings/common_settings.dart';
import 'package:ente_auth/utils/toast_util.dart';
import 'package:flutter/material.dart';

class SecuritySectionWidget extends StatefulWidget {
  const SecuritySectionWidget({Key? key}) : super(key: key);

  @override
  State<SecuritySectionWidget> createState() => _SecuritySectionWidgetState();
}

class _SecuritySectionWidgetState extends State<SecuritySectionWidget> {
  final _config = Configuration.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ExpandableMenuItemWidget(
      title: l10n.security,
      selectionOptionsWidget: _getSectionOptions(context),
      leadingIcon: Icons.local_police_outlined,
    );
  }

  Widget _getSectionOptions(BuildContext context) {
    final bool canDisableMFA = UserService.instance.canDisableEmailMFA();

    final l10n = context.l10n;
    final List<Widget> children = [];
    children.addAll([
      MenuItemWidget(
        captionedTextWidget: CaptionedTextWidget(
          title: l10n.lockscreen,
        ),
        trailingWidget: ToggleSwitchWidget(
          value: () => _config.shouldShowLockScreen(),
          onChanged: () async {
            final hasAuthenticated = await LocalAuthenticationService.instance
                .requestLocalAuthForLockScreen(
              context,
              !_config.shouldShowLockScreen(),
              context.l10n.authToChangeLockscreenSetting,
              context.l10n.lockScreenEnablePreSteps,
            );
            if (hasAuthenticated) {
              setState(() {});
            }
          },
        ),
      ),
      if(canDisableMFA)
        sectionOptionSpacing,
      if(canDisableMFA)
        MenuItemWidget(
          captionedTextWidget: const CaptionedTextWidget(
            title: "Email MFA",
          ),
          trailingWidget: ToggleSwitchWidget(
            value: () => UserService.instance.hasEmailMFAEnabled(),
            onChanged: () async {
              final hasAuthenticated = await LocalAuthenticationService
                  .instance
                  .requestLocalAuthentication(
                context,
                "Authenticate to change your email MFA setting",
              );
              final isEmailMFAEnabled =
              UserService.instance.hasEmailMFAEnabled();
              if (hasAuthenticated) {
                await updateEmailMFA(!isEmailMFAEnabled);
                if(mounted){
                  setState(() {});
                }
              }
            },
          ),
        ),
      sectionOptionSpacing,
      MenuItemWidget(
        captionedTextWidget: CaptionedTextWidget(
          title: context.l10n.viewActiveSessions,
        ),
        pressedColor: getEnteColorScheme(context).fillFaint,
        trailingIcon: Icons.chevron_right_outlined,
        trailingIconIsMuted: true,
        onTap: () async {
          final hasAuthenticated = await LocalAuthenticationService.instance
              .requestLocalAuthentication(
            context,
            context.l10n.authToViewYourActiveSessions,
          );
          if (hasAuthenticated) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const SessionsPage();
                },
              ),
            );
          }
        },
      ),
      sectionOptionSpacing,
    ]);
    return Column(
      children: children,
    );
  }

  Future<void> updateEmailMFA(bool isEnabled) async {
    try {
      await UserService.instance.updateEmailMFA(isEnabled);
    } catch (e) {
     showToast(context, "Error updating email MFA");
    }
  }
}
