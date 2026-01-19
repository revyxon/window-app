import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_enums.dart';

// Re-export enums for convenience
export '../../utils/app_enums.dart' show IconPack, AppIconType, FontFamily;

/// Icon mappings for all 3 packs
class _IconMappings {
  static const Map<AppIconType, IconData> material = {
    AppIconType.home: Icons.square_foot_rounded,
    AppIconType.enquiry: Icons.assignment_rounded,
    AppIconType.agreement: Icons.handshake_rounded,
    AppIconType.settings: Icons.settings_rounded,
    AppIconType.add: Icons.add_rounded,
    AppIconType.edit: Icons.edit_rounded,
    AppIconType.delete: Icons.delete_rounded,
    AppIconType.share: Icons.share_rounded,
    AppIconType.print: Icons.print_rounded,
    AppIconType.sync: Icons.sync_rounded,
    AppIconType.search: Icons.search_rounded,
    AppIconType.close: Icons.close_rounded,
    AppIconType.back: Icons.arrow_back_rounded,
    AppIconType.more: Icons.more_vert_rounded,
    AppIconType.check: Icons.check_rounded,
    AppIconType.customer: Icons.person_rounded,
    AppIconType.window: Icons.window_rounded,
    AppIconType.measurement: Icons.straighten_rounded,
    AppIconType.calculator: Icons.calculate_rounded,
    AppIconType.calendar: Icons.calendar_today_rounded,
    AppIconType.location: Icons.location_on_rounded,
    AppIconType.phone: Icons.phone_rounded,
    AppIconType.notification: Icons.notifications_rounded,
    AppIconType.theme: Icons.dark_mode_rounded,
    AppIconType.palette: Icons.palette_rounded,
    AppIconType.textSize: Icons.text_fields_rounded,
    AppIconType.font: Icons.font_download_rounded,
    AppIconType.icons: Icons.apps_rounded,
    AppIconType.database: Icons.storage_rounded,
    AppIconType.upload: Icons.cloud_upload_rounded,
    AppIconType.download: Icons.cloud_download_rounded,
    AppIconType.info: Icons.info_rounded,
    AppIconType.code: Icons.code_rounded,
    AppIconType.device: Icons.smartphone_rounded,
    AppIconType.warning: Icons.warning_rounded,
    AppIconType.error: Icons.error_rounded,
    AppIconType.success: Icons.check_circle_rounded,
    AppIconType.folder: Icons.folder_rounded,
    AppIconType.file: Icons.insert_drive_file_rounded,
    AppIconType.sparkle: Icons.auto_awesome_rounded,
  };

  static const Map<AppIconType, IconData> fluent = {
    AppIconType.home: FluentIcons.ruler_24_filled,
    AppIconType.enquiry: FluentIcons.document_24_filled,
    AppIconType.agreement: FluentIcons.handshake_24_filled,
    AppIconType.settings: FluentIcons.settings_24_filled,
    AppIconType.add: FluentIcons.add_24_filled,
    AppIconType.edit: FluentIcons.edit_24_filled,
    AppIconType.delete: FluentIcons.delete_24_filled,
    AppIconType.share: FluentIcons.share_24_filled,
    AppIconType.print: FluentIcons.print_24_filled,
    AppIconType.sync: FluentIcons.arrow_sync_24_filled,
    AppIconType.search: FluentIcons.search_24_filled,
    AppIconType.close: FluentIcons.dismiss_24_filled,
    AppIconType.back: FluentIcons.arrow_left_24_filled,
    AppIconType.more: FluentIcons.more_vertical_24_filled,
    AppIconType.check: FluentIcons.checkmark_24_filled,
    AppIconType.customer: FluentIcons.person_24_filled,
    AppIconType.window: FluentIcons.window_24_filled,
    AppIconType.measurement: FluentIcons.ruler_24_filled,
    AppIconType.calculator: FluentIcons.calculator_24_filled,
    AppIconType.calendar: FluentIcons.calendar_24_filled,
    AppIconType.location: FluentIcons.location_24_filled,
    AppIconType.phone: FluentIcons.call_24_filled,
    AppIconType.notification: FluentIcons.alert_24_filled,
    AppIconType.theme: FluentIcons.dark_theme_24_filled,
    AppIconType.palette: FluentIcons.color_24_filled,
    AppIconType.textSize: FluentIcons.text_font_size_24_filled,
    AppIconType.font: FluentIcons.text_font_24_filled,
    AppIconType.icons: FluentIcons.apps_24_filled,
    AppIconType.database: FluentIcons.database_24_filled,
    AppIconType.upload: FluentIcons.arrow_upload_24_filled,
    AppIconType.download: FluentIcons.arrow_download_24_filled,
    AppIconType.info: FluentIcons.info_24_filled,
    AppIconType.code: FluentIcons.code_24_filled,
    AppIconType.device: FluentIcons.phone_24_filled,
    AppIconType.warning: FluentIcons.warning_24_filled,
    AppIconType.error: FluentIcons.error_circle_24_filled,
    AppIconType.success: FluentIcons.checkmark_circle_24_filled,
    AppIconType.folder: FluentIcons.folder_24_filled,
    AppIconType.file: FluentIcons.document_24_filled,
    AppIconType.sparkle: FluentIcons.sparkle_24_filled,
  };

  static const Map<AppIconType, IconData> cupertino = {
    AppIconType.home: CupertinoIcons.square_grid_2x2_fill,
    AppIconType.enquiry: CupertinoIcons.doc_text_fill,
    AppIconType.agreement: CupertinoIcons.hand_raised_fill,
    AppIconType.settings: CupertinoIcons.gear_alt_fill,
    AppIconType.add: CupertinoIcons.plus,
    AppIconType.edit: CupertinoIcons.pencil,
    AppIconType.delete: CupertinoIcons.trash_fill,
    AppIconType.share: CupertinoIcons.share,
    AppIconType.print: CupertinoIcons.printer_fill,
    AppIconType.sync: CupertinoIcons.arrow_2_circlepath,
    AppIconType.search: CupertinoIcons.search,
    AppIconType.close: CupertinoIcons.xmark,
    AppIconType.back: CupertinoIcons.back,
    AppIconType.more: CupertinoIcons.ellipsis_vertical,
    AppIconType.check: CupertinoIcons.checkmark,
    AppIconType.customer: CupertinoIcons.person_fill,
    AppIconType.window: CupertinoIcons.rectangle_split_3x1_fill,
    AppIconType.measurement: CupertinoIcons.resize,
    AppIconType.calculator: CupertinoIcons.plus_slash_minus,
    AppIconType.calendar: CupertinoIcons.calendar,
    AppIconType.location: CupertinoIcons.location_fill,
    AppIconType.phone: CupertinoIcons.phone_fill,
    AppIconType.notification: CupertinoIcons.bell_fill,
    AppIconType.theme: CupertinoIcons.moon_fill,
    AppIconType.palette: CupertinoIcons.paintbrush_fill,
    AppIconType.textSize: CupertinoIcons.textformat_size,
    AppIconType.font: CupertinoIcons.textformat,
    AppIconType.icons: CupertinoIcons.square_grid_2x2,
    AppIconType.database: CupertinoIcons.tray_2_fill,
    AppIconType.upload: CupertinoIcons.cloud_upload_fill,
    AppIconType.download: CupertinoIcons.cloud_download_fill,
    AppIconType.info: CupertinoIcons.info_circle_fill,
    AppIconType.code: CupertinoIcons.chevron_left_slash_chevron_right,
    AppIconType.device: CupertinoIcons.device_phone_portrait,
    AppIconType.warning: CupertinoIcons.exclamationmark_triangle_fill,
    AppIconType.error: CupertinoIcons.xmark_circle_fill,
    AppIconType.success: CupertinoIcons.checkmark_circle_fill,
    AppIconType.folder: CupertinoIcons.folder_fill,
    AppIconType.file: CupertinoIcons.doc_fill,
    AppIconType.sparkle: CupertinoIcons.sparkles,
  };

  static IconData get(AppIconType type, IconPack pack) {
    switch (pack) {
      case IconPack.material:
        return material[type] ?? Icons.help_outline;
      case IconPack.fluent:
        return fluent[type] ?? FluentIcons.question_24_regular;
      case IconPack.cupertino:
        return cupertino[type] ?? CupertinoIcons.question;
    }
  }
}

/// Universal App Icon Widget
class AppIcon extends StatelessWidget {
  final AppIconType type;
  final double? size;
  final Color? color;
  final IconPack? overridePack;

  const AppIcon(
    this.type, {
    super.key,
    this.size,
    this.color,
    this.overridePack,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pack = overridePack ?? settings.iconPack;
    final iconData = _IconMappings.get(type, pack);

    return Icon(iconData, size: size, color: color);
  }
}
