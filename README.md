# 每日小事 · PocketDay

一个面向 iOS 18 的 SwiftUI 示例。添加日常事项、勾选完成状态或向左滑动删除。首页实时显示进度，清单保存在设备本地。

## 在 Xcode 中运行

使用 Xcode 16.4 或更高版本打开 `PocketDay.xcodeproj`，选择 `PocketDay` scheme 和 iOS 18 模拟器，然后按 `⌘R`。

## GitHub Actions 构建

推送到 `main`、打开拉取请求或在 Actions 中手动运行 **iOS 18 Build**。工作流使用 GitHub 托管的 macOS 15 和 Xcode 16.4，构建 Release 版本，检查最低系统版本为 iOS 18.0，并在 iOS 18.5 的 iPhone 16 模拟器上安装和启动。

在成功的运行中下载 **PocketDay-iOS-Simulator**，解压取得 `PocketDay.app`。打开兼容的 iOS 模拟器后，从包含该应用的目录执行：

```sh
xcrun simctl install booted PocketDay.app
xcrun simctl launch booted com.example.pocketday
```

**PocketDay-iOS-Unsigned** 产物包含 arm64 真机版 `PocketDay-iOS-Unsigned.ipa`。请使用自己的签名和描述文件重新签名后安装。

工作流使用 GitHub 提供的临时 `GITHUB_TOKEN` 读取仓库。首次创建仓库和推送可以通过本机 1Password CLI 将保存的 GitHub PAT 注入 GitHub CLI 的 `GH_TOKEN`。GitHub PAT 需有权创建目标仓库、推送内容和更新工作流。

```powershell
$env:GH_TOKEN = 'op://你的保险库/GitHub PAT/credential'
try {
    op run -- gh repo create pocketday-swiftui-ios18 --private --source . --remote origin --push
} finally {
    Remove-Item Env:GH_TOKEN
}
```
