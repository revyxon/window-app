# Deep Silent Device Audit & Fingerprinting (Zero-Permission)

This document outlines the absolute maximum technical metadata extractable from a mobile device (Android/iOS) using Flutter and Native Platform Channels **without triggering any runtime permission popups**.

---

## 1. Device Identity Constants (Build Layer)
These constants are defined at the factory level and are the primary way to categorize a device.

| Constant | Description | Android Path (`android.os.Build`) |
| :--- | :--- | :--- |
| **MANUFACTURER** | Hardware manufacturer. | `Build.MANUFACTURER` (e.g., "samsung") |
| **BRAND** | Consumer branding. | `Build.BRAND` (e.g., "google") |
| **MODEL** | The end-user-visible name. | `Build.MODEL` (e.g., "Pixel 6") |
| **PRODUCT** | The overall product name. | `Build.PRODUCT` (e.g., "raven") |
| **DEVICE** | The internal industrial design name. | `Build.DEVICE` (e.g., "raven") |
| **BOARD** | The name of the underlying board. | `Build.BOARD` (e.g., "gs101") |
| **HARDWARE** | The name of the hardware (SOC). | `Build.HARDWARE` (e.g., "raven") |
| **BOOTLOADER** | System bootloader version number. | `Build.BOOTLOADER` |
| **DISPLAY** | Build ID string meant for display. | `Build.DISPLAY` |
| **ID** | Changelist number or internal label. | `Build.ID` |
| **TAGS** | Comma-separated tags (e.g., "release-keys"). | `Build.TAGS` |
| **TYPE** | Type of build (e.g., "user" or "eng"). | `Build.TYPE` |
| **USER** | User who generated the build. | `Build.USER` |
| **HOST** | Host machine that built the OS. | `Build.HOST` |

---

## 2. Hardware DNA (The "Silcon DNA")
Deep hardware metrics that determine performance and capabilities.

### 2.1 CPU & GPU Deep Dive
*   **ABI List:** All supported architectures (`arm64-v8a`, `armeabi-v7a`).
*   **GPU Extensions:** Full list of OpenGL ES extensions (reveals specific driver versions).
*   **Vulkan Support:** Whether the device supports the Vulkan Graphics API.
*   **L1/L2 Cache Proxy:** Can be estimated via execution timing (No permission).
*   **Processor Clock:** While the current speed is often hidden, the `Build.SUPPORTED_ABIS` list tells you the architecture depth.

### 2.2 Memory & Storage Hierarchy
*   **RAM Type Proxy:** Total RAM + System Speed can identify LPDDR4 vs LPDDR5 batches.
*   **Swap/ZRAM:** Detection of compressed memory usage.
*   **Disk Partitioning:** Checking available space on `/data`, `/cache`, and `/system` (silently).

---

## 3. Operating System & Security Audit (The Stealth Check)
Checking for tampering, emulators, and security posture.

*   **Security Patch Level:** Exact date (e.g., `2024-01-01`).
*   **Baseband Version:** Modem firmware version (identifies specific radio hardware).
*   **Verified Boot State:** Whether the device has a locked or unlocked bootloader (via `getprop ro.boot.verifiedbootstate`).
*   **SELinux Status:** Permissive vs Enforcing (Zero-permission check).
*   **Installed System Apps:** Checking for the presence of apps like `com.noshufou.android.su` or `com.thirdparty.blocker`.

---

## 4. Environment & Contextual Data
How the user is currently using the device.

*   **System Uptime:** Time since last boot (`SystemClock.elapsedRealtime()`).
*   **Last Reboot Reason:** (e.g., `userrequested`, `kernel_panic`).
*   **Battery Cycle Proxy:** Battery level + Voltage + Temperature (High temperature during AC charging identifies fast-charging hardware).
*   **System Languages:** Complete list of all languages configured (not just the active one).
*   **Accessibility Features:** Pata lagao if `TalkBack`, `Magnification`, or `Select to Speak` are active.

---

## 5. Network Interface Audit (Passive)
Detecting the networking environment without calling `ACCESS_WIFI_STATE`.

*   **Active Interface Count:** Number of active IP interfaces.
*   **Interface Names:** `wlan0`, `rmnet_data0`, `tun0` (identifies Wifi vs Mobile vs VPN).
*   **DNS Servers:** Currently configured DNS (e.g., `8.8.8.8`).
*   **HTTP Proxy Status:** If the user is routing traffic through a manual proxy.

---

## 6. The "Master-Audit" Fingerprint Logic
Combine these into a single **Super-Hash** for 99.999% identification.

### **Calculation Table**
| Weight | Component Data | Rationale |
| :--- | :--- | :--- |
| **High** | `Build.ID` + `Build.TIME` | Identifies the exact OS build instance. |
| **High** | `Android_ID` | Stable per-user-key identifier. |
| **Medium** | `Build.HARDWARE` + `Build.BOARD` | Identifies the physical SOC version. |
| **Medium** | `Total_RAM` + `Screen_Metric` | Differentiates between identical models with different specs. |
| **Low** | `Build.BOOTLOADER` | Identifies firmware-level updates. |

### **Recommended Code Implementation (Conceptual)**
```dart
String generateSuperFingerprint() {
  var data = "${Build.MANUFACTURER}|${Build.MODEL}|${Build.HARDWARE}|" +
             "${Build.ID}|${Build.DISPLAY}|${Build.TIME}|" +
             "${Screen.width}x${Screen.height}|${Memory.totalRAM}|" +
             "${AndroidID}";
  return sha256(data.toLowerCase().trim());
}
```

---

### 7. Deep Metadata List (Full Table)

| Field | Example Value | Category |
| :--- | :--- | :--- |
| `Build.VERSION.RELEASE` | `14` | OS Version |
| `Build.VERSION.SDK_INT` | `34` | API Level |
| `Build.VERSION.CODENAME` | `REL` | Build Maturity |
| `Build.FINGERPRINT` | `google/pixel...` | Unique OS Build |
| `Build.TIME` | `168...)` | Build Timestamp |
| `Build.TAGS` | `release-keys` | Signing Keys |
| `Build.BOOTLOADER` | `mw8998-002.00` | Firmware Version |
| `Build.RADIO` | `g8150-00030...` | Modem Version |
| `Display.RefreshRate` | `120.0` | Display Specs |
| `Display.DPI` | `440` | Screen Density |
| `Language.List` | `[hi_IN, en_US]` | User Culture |
| `Storage.Total` | `128000 MB` | Storage Specs |
| `GPU.Extensions` | `GL_OES_EGL_image...` | Driver DNA |
| `System.Feature` | `android.hardware.nfc` | Hardware Cap |
| `Network.MTU` | `1500` | Packet Logic |
| `Vulkan.Extensions` | `VK_KHR_surface...` | Graphics DNA |
| `Audio.Latency` | `10ms` (Proxy) | Audio Engine |

### 8. The "Invisible" Security Markers
These settings reveal if the user is a developer or using a tampered device:
*   **ADB Enabled:** Status of `Settings.Global.ADB_ENABLED`.
*   **Verification Mode:** `Settings.Global.PACKAGE_VERIFIER_ENABLE`.
*   **Install Non-Market Apps:** `Settings.Secure.INSTALL_NON_MARKET_APPS`.
*   **Mock Location:** `Settings.Secure.ALLOW_MOCK_LOCATION`.

### 9. Extreme Native Harvesting (Android Shell)
Using `getprop` and `/proc` (No permission needed) reveals internal manufacturing secrets:
*   **`ro.serialno` Proxy:** While serial is blocked, `ro.boot.serialno` can sometimes be read via shell.
*   **`ro.hardware.chipname`:** The exact marketing name of the SOC.
*   **`/proc/cpuinfo`:** Raw hardware data including "BogoMIPS" and "CPU implementer" (Highly unique identifier).
*   **`/proc/meminfo`:** Raw RAM details including "Dirty" and "Writeback" memory habits.

> [!IMPORTANT]
> This manual represents the **MAX-LEVEL** of silent data collection possible. By combining these metrics, you don't just identify a device—you identify a specific **unit** out of millions of identical models.
