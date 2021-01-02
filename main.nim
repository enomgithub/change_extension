import encodings
import os
from strformat import fmt
import unicode

import dialogs
import nimx / [ button, layout, popup_button, text_field, window ]

const TOOL_NAME = "changeExtension"
const SEMANTIC_VERSION = "0.0.2"


proc onChooseDir(field: TextField) =
  let initPath =
    if field.text != "" and os.dirExists(field.text):
      field.text
    else:
      "./"
  echo fmt("initPath: {initPath}")
  let dirPath =
    when defined(windows):
      dialogs.chooseDir(nil, initPath).convert("UTF-8", "shift_jis")
    else:
      dialogs.chooseDir(nil, initPath)
  echo fmt("{dirPath}")
  if unicode.validateUtf8(dirPath) >= 0:
    echo fmt("Invalid UTF-8 strings: {dirPath}")
    return

  field.text = dirPath


proc onMakeDir(pathField: TextField, newDirField: TextField) =
  if newDirField.text == "":
    echo fmt("Empty dir name.")
    return
  let newDirPath = os.joinPath(pathField.text, newDirField.text)
  if os.dirExists(newDirPath):
    echo fmt("Dir {newDirPath} is already exists.")
    return
  try:
    os.createDir(newDirPath)
    echo fmt("Created {newDirPath}")
  except OSError:
    echo fmt("Failed to make dir {newDirPath}.")


proc onExecute(field: TextField, ext: string, newExt: string) =
  echo fmt("Execute {TOOL_NAME} - v{SEMANTIC_VERSION}")
  echo fmt("Base dir: {field.text}")
  echo fmt("{ext} -> {newExt}")

  let pattern = fmt("{field.text}{os.DirSep}*.{ext}")
  echo pattern

  for filePath in os.walkFiles(pattern):
    let newFilePath = os.changeFileExt(filePath, newExt)
    try:
      os.moveFile(filePath, newFilePath)
      echo fmt("Changed extension: {filePath} -> {newFilePath}")
    except OSError:
      echo fmt("Failed to rename: {filePath} -> {newFilePath}")
  echo "Done.\n"


proc startApp() =
  let window = newWindow(newRect(50, 50, 900, 100))
  window.title=fmt("{TOOL_NAME} - v{SEMANTIC_VERSION}")
  window.makeLayout:
    - Label as label:
      left == super.left
      top == super.top + 2
      width == 80
      height == 20
      text: "Target dir"

    - TextField as pathTextField:
      left == prev.right + 2
      top == prev.top
      width == 400
      height == 20
    
    - TextField as newDirTextField:
      left == prev.right + 2
      top == prev.top
      width == 60
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
      onAction: onChooseDir(pathTextField)
    
    - Button as makeDirButton:
      left == prev.right + 2
      top == prev.top
      width == 100
      height == 20
      title: "Make Dir"
      onAction: onMakeDir(pathTextField, newDirTextField)

    - Button as executeButton:
      left == prev.right + 2
      top == prev.top
      width == 100
      height == 20
      title: "Change Ext"
      onAction: onExecute(pathTextField, extensions.selectedItem(), newExtensions.selectedItem())


runApplication:
  startApp()
