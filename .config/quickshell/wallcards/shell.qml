import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: root

  property bool livePreview: false
  property string fontFamily: "Monaspace Krypton"

  property bool loading: true
  property int filteredCount: filteredItems.length
  property int pendingProcesses: 0
  property string filter: "images"
  property string loadingMessage
  property var filteredItems: []

  function isVideo(fileName) {
    var ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    return ["mp4", "mkv", "webm", "avi", "mov"].indexOf(ext) !== -1;
  }

  function isImage(fileName) {
    var ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    return ["png", "jpg", "jpeg"].indexOf(ext) !== -1;
  }

  function rebuildFilteredItems() {
    var items = [];
    for (var i = 0; i < folderModel.count; i++) {
      var fn = folderModel.get(i, "fileName");
      var fp = folderModel.get(i, "filePath");

      if (filter === "all" || (filter === "images" && isImage(fn)) || (filter === "videos" && isVideo(fn)))
        items.push({
          "fileName": fn,
          "filePath": fp
        });
    }
    filteredItems = items;
    if (cardStack.currentIndex >= filteredCount)
      cardStack.currentIndex = 0;
  }

  function getFileName(idx) {
    if (filteredItems.length === 0)
      return "";
    return filteredItems[idx].fileName;
  }

  function getFilePath(idx) {
    if (filteredItems.length === 0)
      return "";
    return filteredItems[idx].filePath;
  }

  function thumbnailName(fileName) {
    return isVideo(fileName) ? fileName.substring(0, fileName.lastIndexOf(".")) + ".jpg" : fileName;
  }

  function createThumbnails() {
    var proc = processComponent.createObject(null, {
      "command": ["mkdir", "-p", config.cache_dir]
    });
    proc.running = true;

    for (var i = 0; i < folderModel.count; i++) {
      (function (idx) {
          var filePath = folderModel.get(idx, "filePath");
          var fileName = folderModel.get(idx, "fileName");
          var thumbName = thumbnailName(fileName);
          var thumbnail = config.cache_dir + "/" + thumbName;

          var cmd;
          if (isVideo(fileName))
            cmd = "[ -f '" + thumbnail + "' ] || ffmpeg -y -i '" + filePath + "' -ss 00:00:01 -vframes 1 -vf scale=-1:500 '" + thumbnail + "' </dev/null 2>/dev/null";
          else
            cmd = "[ -f '" + thumbnail + "' ] || magick '" + filePath + "' -thumbnail x500 '" + thumbnail + "'";

          root.pendingProcesses++;
          var proc = processComponent.createObject(null, {
            "command": ["bash", "-c", cmd]
          });

          proc.exited.connect(function () {
            root.pendingProcesses--;

            if (root.pendingProcesses === 0)
              root.loading = false;
            else
              root.loadingMessage = `Generating thumbnails… ${root.pendingProcesses} remaining`;

            proc.destroy();
          });

          proc.running = true;
        })(i);
    }
  }

  function applyCard(filePath: string, quit) {
    root.loading = true;
    root.loadingMessage = "Applying wallpaper…";
    root.pendingProcesses++;

    var fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
    var proc;

    if (isVideo(fileName))
      proc = processComponent.createObject(null, {
        "command": ["bash", "-c", "pkill -x mpvpaper 2>/dev/null || true; " + "sleep 0.2; " + "for m in $(hyprctl monitors | awk '/^Monitor /{print $2}'); do " + "  setsid -f mpvpaper -p -f -o '--loop-file=inf' \"$m\" '" + filePath + "' >/dev/null 2>&1 & " + "done"]
      });
    else
      proc = processComponent.createObject(null, {
        "command": ["qs", "-c", "noctalia-shell", "ipc", "call", "wallpaper", "set", filePath, "all"]
      });

    proc.exited.connect(function () {
      root.pendingProcesses--;
      root.loading = root.pendingProcesses != 0;

      if (quit)
        Qt.quit();
    });

    proc.running = true;
  }

  aboveWindows: true
  color: "transparent"
  exclusionMode: "Ignore"
  exclusiveZone: 0
  implicitHeight: Screen.height
  implicitWidth: Screen.width
  onFilterChanged: rebuildFilteredItems()
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.layer: WlrLayer.Overlay

  FileView {
    path: Quickshell.shellPath("config.json")
    watchChanges: true
    onFileChanged: {}

    JsonAdapter {
      id: config

      property string cache_dir
      property int card_height
      property int card_spacing
      property int card_strip_width
      property int card_radius
      property int cards_shown
      property var file_filter
      property var shear_factor
      property var top_bar_height
      property var top_bar_radius
      property string wallpaper_dir
    }
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/noctalia/colors.json"
    watchChanges: true
    onFileChanged: {
      reload();
    }

    JsonAdapter {
      id: colors

      property string mPrimary
      property string mOnPrimary
      property string mSecondary
      property string mOnSecondary
      property string mTertiary
      property string mOnTertiary
      property string mError
      property string mOnError
      property string mSurface
      property string mOnSurface
      property string mSurfaceVariant
      property string mOnSurfaceVariant
      property string mOutline
      property string mShadow
      property string mHover
      property string mOnHover
    }
  }

  FolderListModel {
    id: folderModel

    folder: Qt.resolvedUrl("file://" + config.wallpaper_dir)
    showDirs: false
    nameFilters: config.file_filter || []
    sortField: FolderListModel.Name
    onStatusChanged: {
      if (status === FolderListModel.Ready) {
        createThumbnails();
        rebuildFilteredItems();

        var rnd = Math.floor(Math.random() * root.filteredCount);
        cardStack.currentIndex = rnd;
        cardStack.runningIndex = rnd;
        cardStack.animRunning = rnd;
      }
    }
  }

  Component {
    id: processComponent

    Process {}
  }

  // ── Fullscreen dim background ──
  Rectangle {
    property real dimOpacity: 0

    anchors.fill: parent
    color: colors.mOnSurface
    opacity: dimOpacity
    Component.onCompleted: {
      dimOpacity = 0.0;
    }

    Behavior on opacity {
      NumberAnimation {
        duration: 1000
        easing.type: Easing.OutCubic
      }
    }
  }

  // ── Loading indicator ──
  Rectangle {
    id: loadingIndicator

    anchors.top: contentArea.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    z: 200
    visible: root.loading
    width: loadingRow.width + 24
    height: loadingRow.height + 12
    radius: 8
    color: Qt.alpha(colors.mSurface, 0.9)

    Row {
      id: loadingRow

      anchors.centerIn: parent
      spacing: 10

      Item {
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
          model: 3

          Rectangle {
            property real angle: index * (2 * Math.PI / 3)

            width: 4
            height: 4
            radius: 2
            color: colors.mPrimary
            x: 6 + 5 * Math.cos(angle + spinAnimation.value)
            y: 6 + 5 * Math.sin(angle + spinAnimation.value)

            NumberAnimation on opacity {
              from: 0.3
              to: 1
              duration: 600
              loops: Animation.Infinite
              running: root.loading
            }
          }
        }

        NumberAnimation {
          id: spinAnimation

          property real value: 0

          target: spinAnimation
          property: "value"
          from: 0
          to: 2 * Math.PI
          duration: 1200
          loops: Animation.Infinite
          running: root.loading
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.loadingMessage
        color: colors.mOnSurface
        font.family: root.fontFamily
        font.pixelSize: 16
      }
    }
  }

  // ── Content area ──
  Item {
    id: contentArea

    anchors.horizontalCenter: parent.horizontalCenter
    y: (parent.height - config.card_height) / 2
    width: Screen.width
    height: config.card_height

    // ── Top bar ──
    Rectangle {
      id: infoBar

      property int sideCount: Math.floor(config.cards_shown / 2) - 1
      property real centerWidth: contentArea.width / 3
      property real centerX: centerWidth + config.card_height * config.shear_factor * -0.1
      property real stripWidth: config.card_strip_width
      property real stripGap: config.card_spacing
      property real leftEdge: centerX - stripGap - sideCount * stripWidth - (sideCount - 1) * stripGap
      property real rightEdge: centerX + centerWidth + stripGap + (sideCount - 1) * (stripWidth + stripGap) + stripWidth

      anchors.top: parent.top
      color: colors.mSurface
      opacity: 0.85
      x: leftEdge
      width: rightEdge - leftEdge
      height: config.top_bar_height
      radius: config.top_bar_radius || 10

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: `${cardStack.currentIndex + 1} / ${root.filteredCount}`
        color: colors.mPrimary
        font.family: root.fontFamily
        font.pixelSize: 13
        font.bold: true
        font.letterSpacing: 0.5
      }

      Row {
        id: filterRow

        anchors.centerIn: parent
        spacing: 4
        z: 1

        Repeater {
          model: [
            {
              "key": "all",
              "label": "All [A]",
              "col": colors.mPrimary
            },
            {
              "key": "images",
              "label": "IMG [I]",
              "col": colors.mSecondary
            },
            {
              "key": "videos",
              "label": "VID [V]",
              "col": colors.mTertiary
            }
          ]

          Rectangle {
            required property var modelData
            property bool active: root.filter === modelData.key

            width: filterLabel.implicitWidth + 16
            height: 22
            radius: 4
            color: active ? Qt.alpha(modelData.col, 0.15) : "transparent"
            border.width: 1
            border.color: active ? modelData.col : colors.mOutline

            Text {
              id: filterLabel
              anchors.centerIn: parent
              text: modelData.label
              color: active ? modelData.col : colors.mOnSurfaceVariant
              font.family: root.fontFamily
              font.pixelSize: 10
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.filter = modelData.key
            }

            Behavior on color {
              ColorAnimation {
                duration: 200
              }
            }
            Behavior on border.color {
              ColorAnimation {
                duration: 200
              }
            }
          }
        }
      }

      Rectangle {
        id: randomButton

        anchors.right: previewToggle.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: randomLabel.implicitWidth + 16
        height: 22
        radius: 4
        z: 1
        color: colors.mSurfaceVariant
        border.width: 1
        border.color: colors.mOutline

        Text {
          id: randomLabel
          anchors.centerIn: parent
          text: "Rnd [R]"
          color: colors.mOnSurfaceVariant
          font.family: root.fontFamily
          font.pixelSize: 10
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: cardStack.randomJump()
        }
      }

      Rectangle {
        id: previewToggle

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: previewRow.width + 16
        height: 22
        radius: 4
        z: 1
        color: root.livePreview ? Qt.alpha(colors.mTertiary, 0.15) : colors.mSurfaceVariant
        border.width: 1
        border.color: root.livePreview ? colors.mTertiary : colors.mOutline

        Row {
          id: previewRow
          anchors.centerIn: parent
          spacing: 6

          Rectangle {
            width: 8
            height: 8
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: root.livePreview ? colors.mPrimary : colors.mOnSurfaceVariant

            Behavior on color {
              ColorAnimation {
                duration: 200
              }
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Live"
            color: root.livePreview ? colors.mTertiary : colors.mOnSurfaceVariant
            font.family: root.fontFamily
            font.pixelSize: 11

            Behavior on color {
              ColorAnimation {
                duration: 200
              }
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "[P]"
            color: colors.mOnSurfaceVariant
            font.family: root.fontFamily
            font.pixelSize: 9
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.livePreview = !root.livePreview
        }

        Behavior on color {
          ColorAnimation {
            duration: 200
          }
        }

        Behavior on border.color {
          ColorAnimation {
            duration: 200
          }
        }
      }

      transform: Shear {
        xFactor: config.shear_factor || -0.25
      }
    }

    // ── Cards ──
    Item {
      id: cardStack

      property int currentIndex: 0
      property int visibleCount: config.cards_shown
      property int halfVisible: Math.floor(visibleCount / 2)

      property real cardHeight: config.card_height / 1.25 - config.top_bar_height
      property real centerWidth: contentArea.width / 3
      property real stripWidth: config.card_strip_width
      property real stripGap: config.card_spacing
      property real centerX: width / 2 - centerWidth / 2

      property real runningIndex: 0
      property real animRunning: 0

      function wrappedIndex(idx) {
        return ((idx % root.filteredCount) + root.filteredCount) % root.filteredCount;
      }

      function slotToX(slot) {
        if (slot >= 0 && slot <= 1)
          return centerX * (1 - slot) + (centerX + centerWidth + stripGap) * slot;
        if (slot >= -1 && slot < 0)
          return centerX * (1 + slot) + (centerX - stripGap - stripWidth) * -slot;
        if (slot > 1) {
          var firstRight = centerX + centerWidth + stripGap;
          return firstRight + (slot - 1) * (stripWidth + stripGap);
        }
        if (slot < -1) {
          var firstLeft = centerX - stripGap - stripWidth;
          return firstLeft + (slot + 1) * (stripWidth + stripGap);
        }
        return 0;
      }

      function slotToWidth(slot) {
        var t = Math.min(Math.abs(slot), 1);
        return centerWidth + (stripWidth - centerWidth) * t;
      }

      function randomJump() {
        var rnd = Math.floor(Math.random() * root.filteredCount);
        if (rnd === currentIndex)
          rnd = (rnd + 1) % root.filteredCount;
        navigateTo(rnd);
      }

      function navigateTo(idx) {
        var newIdx = wrappedIndex(idx);
        var diff = 0;
        if (root.filteredCount > 0) {
          diff = newIdx - currentIndex;
          var half = root.filteredCount / 2;
          if (diff > half)
            diff -= root.filteredCount;
          else if (diff < -half)
            diff += root.filteredCount;
        }
        runningIndex += diff;
        animRunning = runningIndex;
        currentIndex = newIdx;

        if (root.livePreview)
          applyCard(root.getFilePath(currentIndex), false);
      }

      anchors.fill: parent
      anchors.top: infoBar.bottom
      anchors.topMargin: 50
      focus: true

      Keys.onPressed: function (event) {
        if (event.isAutoRepeat) {
          event.accepted = true;
          return;
        }

        var quit = false;
        var apply = false;

        if (event.key === Qt.Key_K || event.key === Qt.Key_Left)
          navigateTo(currentIndex - 1);
        else if (event.key === Qt.Key_J || event.key === Qt.Key_Right)
          navigateTo(currentIndex + 1);
        else if (event.key === Qt.Key_H)
          navigateTo(currentIndex - 7);
        else if (event.key === Qt.Key_L)
          navigateTo(currentIndex + 7);
        else if (event.key === Qt.Key_P)
          root.livePreview = !root.livePreview;
        else if (event.key === Qt.Key_A)
          root.filter = "all";
        else if (event.key === Qt.Key_I)
          root.filter = "images";
        else if (event.key === Qt.Key_V)
          root.filter = "videos";
        else if (event.key === Qt.Key_R)
          cardStack.randomJump();
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
          apply = true;
          quit = true;
        } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q)
          quit = true;

        event.accepted = true;

        if (quit && !apply)
          Qt.quit();
        if (apply)
          applyCard(root.getFilePath(currentIndex), quit);
      }

      Repeater {
        id: cardRepeater

        model: root.filteredCount > 0 ? cardStack.visibleCount : 0

        delegate: Item {
          id: cardDelegate

          property int offset: index - cardStack.halfVisible
          property real fractionalSlot: offset + (cardStack.runningIndex - cardStack.animRunning)
          property int modelIndex: cardStack.wrappedIndex(Math.round(cardStack.runningIndex) + offset)
          property string currentFileName: root.getFileName(modelIndex)
          property bool isVideoFile: root.isVideo(currentFileName)
          property bool isCenter: offset === 0

          property string targetSource: root.filteredCount > 0 ? `file://${config.cache_dir}/${root.thumbnailName(currentFileName)}` : ""

          onTargetSourceChanged: {
            if (img.source.toString() !== "" && img.source.toString() !== targetSource) {
              imgOld.source = img.source;
              imgOld.opacity = 1;
              crossfade.restart();
            }
            img.source = targetSource;
          }

          visible: (x + width) > 0 && x < cardStack.width
          width: cardStack.slotToWidth(fractionalSlot)
          height: cardStack.cardHeight
          x: cardStack.slotToX(fractionalSlot)
          y: 0
          z: isCenter ? 100 : cardStack.visibleCount - Math.abs(offset)

          opacity: Math.max(0, Math.min(1, cardStack.halfVisible - Math.abs(fractionalSlot)))

          Item {
            id: imageFrame

            anchors.fill: parent
            clip: true

            Item {
              id: imgComposite

              width: cardStack.centerWidth
              height: imageFrame.height
              x: (imageFrame.width - cardStack.centerWidth) / 2
              visible: false

              // TODO: There must be a better solution.
              Image {
                id: imgOld

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: true
                smooth: true
                asynchronous: true
                sourceSize.width: cardStack.centerWidth
                sourceSize.height: parent.height
              }

              Image {
                id: img

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: true
                smooth: true
                asynchronous: true
                sourceSize.width: cardStack.centerWidth
                sourceSize.height: parent.height
              }
            }

            NumberAnimation {
              id: crossfade

              target: imgOld
              property: "opacity"
              from: 1
              to: 0
              duration: 300
              easing.type: Easing.OutCubic
            }

            Rectangle {
              id: mask

              anchors.fill: parent
              radius: config.card_radius
              visible: false
            }

            OpacityMask {
              anchors.fill: parent
              maskSource: mask

              source: ShaderEffectSource {
                sourceItem: imgComposite
                sourceRect: Qt.rect(-imgComposite.x, 0, imageFrame.width, imageFrame.height)
              }
            }

            // ── Video preview ──
            Loader {
              id: videoLoader

              property string videoPath: isCenter && cardDelegate.isVideoFile ? root.getFilePath(cardDelegate.modelIndex) : ""

              anchors.fill: parent
              active: isCenter && cardDelegate.isVideoFile && cardDelegate.currentFileName !== ""
              z: 5
              onVideoPathChanged: {
                if (active) {
                  active = false;
                  active = Qt.binding(function () {
                    return isCenter && cardDelegate.isVideoFile && cardDelegate.currentFileName !== "";
                  });
                }
              }

              sourceComponent: Component {
                Item {
                  id: videoContainer

                  anchors.fill: parent
                  layer.enabled: true

                  MediaPlayer {
                    id: mediaPlayer

                    source: "file://" + videoLoader.videoPath
                    videoOutput: videoOutput
                    loops: MediaPlayer.Infinite
                    Component.onCompleted: play()

                    audioOutput: AudioOutput {
                      volume: 0
                    }
                  }

                  VideoOutput {
                    id: videoOutput

                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                  }

                  layer.effect: OpacityMask {
                    maskSource: Rectangle {
                      width: videoContainer.width
                      height: videoContainer.height
                      radius: config.card_radius
                    }
                  }
                }
              }
            }

            Rectangle {
              id: border

              property int trackedModel: cardDelegate.modelIndex

              anchors.fill: parent
              radius: config.card_radius
              color: "transparent"
              border.width: isCenter ? 2 : 1
              border.color: isCenter ? colors.mOutline : colors.mSurface
              z: 20
              opacity: 1
              onTrackedModelChanged: {
                if (isCenter)
                  borderFadeIn.restart();
              }

              NumberAnimation {
                id: borderFadeIn

                target: border
                property: "opacity"
                from: 0
                to: 1
                duration: 1000
                easing.type: Easing.OutCubic
              }
            }

            // File type badge
            Rectangle {
              id: typeBadge

              anchors.top: parent.top
              anchors.right: parent.right
              anchors.topMargin: 8
              anchors.rightMargin: 8
              z: 10
              visible: cardDelegate.currentFileName !== ""
              width: badgeRow.width + 16
              height: badgeRow.height + 8
              radius: 6
              color: cardDelegate.isVideoFile ? colors.mSurface : colors.mSurfaceVariant

              Row {
                id: badgeRow

                anchors.centerIn: parent
                spacing: 5

                Text {
                  id: typeIcon

                  anchors.verticalCenter: parent.verticalCenter
                  text: cardDelegate.isVideoFile ? "\ue04b" : "\ue3f4"
                  color: cardDelegate.isVideoFile ? colors.mOnSurface : colors.mOnSurfaceVariant
                  font.family: "Material Symbols Outlined"
                  font.pixelSize: 12
                }

                Text {
                  id: typeLabel

                  anchors.verticalCenter: parent.verticalCenter
                  text: cardDelegate.currentFileName.substring(cardDelegate.currentFileName.lastIndexOf(".") + 1).toUpperCase()
                  color: cardDelegate.isVideoFile ? colors.mPrimary : colors.mSecondary
                  font.family: root.fontFamily
                  font.pixelSize: 12
                  font.bold: true
                  font.letterSpacing: 0.5
                }
              }
            }

            transform: Shear {
              xFactor: config.shear_factor || -0.25
            }
          }

          // Filename label
          Rectangle {
            id: nameBackground

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 8
            anchors.leftMargin: 8
            z: 10
            visible: isCenter
            width: Math.min(nameLabel.implicitWidth + 24, parent.width - 40)
            height: nameLabel.implicitHeight + 10
            radius: 8
            color: cardDelegate.isVideoFile ? colors.mSurface : colors.mSurfaceVariant

            Text {
              id: nameLabel

              anchors.centerIn: parent
              width: parent.width
              text: cardDelegate.currentFileName.substring(0, cardDelegate.currentFileName.lastIndexOf("."))
              color: cardDelegate.isVideoFile ? colors.mOnSurface : colors.mOnSurfaceVariant
              font.family: root.fontFamily
              font.pixelSize: 12
              elide: Text.ElideMiddle
              horizontalAlignment: Text.AlignHCenter
            }

            transform: Shear {
              xFactor: config.shear_factor || -0.25
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: isCenter ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
              if (isCenter)
                applyCard(root.getFilePath(cardDelegate.modelIndex), true);
            }
            onWheel: function (wheel) {
              if (wheel.angleDelta.y > 0)
                cardStack.navigateTo(cardStack.currentIndex - 1);
              else if (wheel.angleDelta.y < 0)
                cardStack.navigateTo(cardStack.currentIndex + 1);
            }
          }
        }
      }

      Behavior on animRunning {
        NumberAnimation {
          duration: 1000
          easing.type: Easing.OutBack
          easing.overshoot: 1
        }
      }
    }
  }
}
