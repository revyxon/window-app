/// App Enums
///
/// Central location for all app-wide enums to avoid circular dependencies.

/// Icon Pack Types - for switching between Material, Fluent, and Cupertino icons
enum IconPack { material, fluent, cupertino }

/// Font families available in the app
enum FontFamily {
  inter,
  roboto,
  poppins,
  nunito,
  lato,
  openSans,
  montserrat,
  raleway,
  sourceSans,
  ubuntu,
}

/// All icon types used in the app
enum AppIconType {
  // Navigation
  home,
  enquiry,
  agreement,
  settings,

  // Actions
  add,
  edit,
  delete,
  share,
  print,
  sync,
  search,
  close,
  back,
  more,
  check,

  // Content
  customer,
  window,
  measurement,
  calculator,
  calendar,
  location,
  phone,
  notification,

  // Settings
  theme,
  palette,
  textSize,
  font,
  icons,
  database,
  upload,
  download,
  info,
  code,
  device,

  // Misc
  warning,
  error,
  success,
  folder,
  file,
  sparkle,
}
