import encodings
import os
import strformat
import unicode

import dialogs
import nimx / [ window, layout, button, popup_button, text_field ]

const TOOL_NAME = "changeExtension"
const SEMANTIC_VERSION = "0.0.1"


proc onChooseDir(field: TextField) =
  let dirPath =
    when defined(windows):
      dialogs.chooseDir(nil, "./").convert("UTF-8", "shift_jis")
    else:
      dialogs.chooseDir(nil, "./")
  echo strformat.fmt("{dirPath}")
  if unicode.validateUtf8(dirPath) >= 0:
    echo strformat.fmt("Invalid UTF-8 strings: {dirPath}")
    return

  field.text = dirPath


proc onExecute(field: TextField, ext: string, newExt: string) =
  echo strformat.fmt("Execute {TOOL_NAME} - v{SEMANTIC_VERSION}")
  echo strformat.fmt("Base dir: {field.text}")
  echo strformat.fmt("{ext} -> {newExt}")

  let pattern = strformat.fmt("{field.text}{os.DirSep}*.{ext}")
  echo pattern

  for filePath in os.walkFiles(pattern):
    let newFilePath = os.changeFileExt(filePath, newExt)
    try:
      os.moveFile(filePath, newFilePath)
      echo strformat.fmt("Changed extension: {filePath} -> {newFilePath}")
    except OSError:
      echo strformat.fmt("Failed to rename: {filePath} -> {newFilePath}")
  echo "Done.\n"


proc startApp() =
  let window = newWindow(newRect(50, 50, 700, 150))
  window.title=strformat.fmt("{TOOL_NAME} - v{SEMANTIC_VERSION}")
  window.makeLayout:
    - Label as label:
      left == super.left
      top == super.top + 2
      width == 80
      height == 20
      text: "Target dir"

    - TextField as textField:
      left == prev.right + 2
      top == prev.top
      width == 300
      height == 20
    
    - PopupButton as extensions:
      left == prev.right + 2
      top == prev.top
      width == 50
      height == 20
      items: ["jfif", "txt"]
    
    - PopupButton as newExtensions:
      left == prev.right + 2
      top == prev.top
      width == 50
      height == 20
      items: ["jpg", "json", "csv"]

    - Button as chooseDirButton:
      left == prev.right + 2
      top == prev.top
      width == 100
      height == 20
      title: "Browse"
      onAction: onChooseDir(textField)

    - Button as executeButton:
      left == prev.right + 2
      top == prev.top
      width == 100
      height == 20
      title: "Execute"
      onAction: onExecute(textField, extensions.selectedItem(), newExtensions.selectedItem())


runApplication:
  startApp()
