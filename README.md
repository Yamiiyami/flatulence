# flatulence

`flatulence` is a Qt Quick desktop app prototype for local-network file sharing.

Based on the current codebase, the app focuses on:
- Discovering peers on the same LAN via UDP broadcast (`NetworkManagerTest`)
- Selecting one or more files in the UI (file picker or drag-and-drop)
- Sending file offers to selected devices
- Accepting incoming offers, opening a TCP receive port, and transferring files
- Showing transfer progress and recent requests in the QML interface

> Current status: active prototype. Some classes are named `*Test` but are used directly by the app, and a few methods are still placeholders.

## Requirements

From `CMakeLists.txt`:
- CMake **3.16+**
- C++ compiler supported by your Qt toolchain
- Qt **6.10+** (`qt_standard_project_setup(REQUIRES 6.10)`)
- Qt6 Quick module (`find_package(Qt6 REQUIRED COMPONENTS Quick)`)

## Build and run

From repository root:

```bash
cd /home/runner/work/flatulence/flatulence
cmake -S . -B build
cmake --build build
./build/appflatulence
```

Notes:
- The CMake target/executable name is `appflatulence`.
- Received files are written to the OS download directory (`QStandardPaths::DownloadLocation`) by the receiver code.

## Basic workflow (current UI)

1. App starts and scans LAN peers automatically.
2. Click **"Quét thiết bị"** to scan again.
3. Select files by:
   - Clicking **"thêm file từ máy này"**, or
   - Dragging files into the drop area.
4. Select recipient devices from the left list.
5. Click **"Gửi Files"** to send file offers.
6. On the receiving side, accept a request (**"accept"**) to start listening and transfer.
7. Track progress in **"Tiến trình gửi file"**.

## Project structure

- `/home/runner/work/flatulence/flatulence/CMakeLists.txt` - build configuration and QML module setup
- `/home/runner/work/flatulence/flatulence/main.cpp` - app entry point and QML engine startup
- `/home/runner/work/flatulence/flatulence/Main.qml` - main UI and transfer workflow orchestration
- `/home/runner/work/flatulence/flatulence/NetworkManagerTest.*` - UDP peer discovery + file-offer signaling
- `/home/runner/work/flatulence/flatulence/TranferSenderTest.*` - outgoing TCP file transfer logic
- `/home/runner/work/flatulence/flatulence/TransferReceiverTest.*` + `ConnectionHandler.*` - incoming TCP receive handling
- `/home/runner/work/flatulence/flatulence/FileHelper.*` - file metadata extraction for QML models
- `/home/runner/work/flatulence/flatulence/AppSplitView.qml`, `ScrollContainer.qml` - reusable UI components
- `/home/runner/work/flatulence/flatulence/assets/images/` - UI assets

## Development/testing notes

- The repository currently contains no standalone automated test target in `CMakeLists.txt`.
- Several legacy/alternate classes (`NetworkManager`, `TransferSender`, `TransferReceiver`, `Listener`) exist in the tree but are not included in the active QML module sources in `CMakeLists.txt`.
