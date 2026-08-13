# WeChat Android Versions

收集并保存微信 Android 官方安装包的历史版本。

- [在线浏览及下载](https://rodert.github.io/wechat-android-versions/)
- [Releases](https://github.com/Rodert/wechat-android-versions/releases)
- [Windows 微信历史版本](https://github.com/Rodert/wechat-win-versions)
- [macOS 微信历史版本](https://github.com/Rodert/wechat-mac-versions)

## 如何下载

1. 打开本仓库的 [Releases 页面](https://github.com/Rodert/wechat-android-versions/releases)，或访问在线版本列表。
2. 按发布日期找到所需版本。
3. 下载对应架构的 `.apk` 文件：`arm64` 适用于绝大多数近年的设备；32 位包适用于较早设备。
4. 可选下载同一版本的 `.sha256` 文件，验证安装包完整性。

## 自动归档

GitHub Actions 每天从微信官网读取 Android 下载配置，下载可用的官方 APK，计算 SHA-256，并在安装包发生变化时创建 GitHub Release。`releases.json` 是供 GitHub Pages 使用的 Release 缓存。

安装包均来自微信官网，本项目只做版本索引和归档。请根据设备架构选择安装包，安装历史版本前请自行备份重要数据。

## 目录结构

```text
├── .github/workflows/archive.yml  # 每日归档与索引刷新
├── scripts/archive-android.sh     # 下载、校验和发布脚本
├── index.html                     # GitHub Pages 版本列表
├── releases.json                  # Release 缓存
└── README.md
```

各版本更新日志请参考微信官网。[问题或侵权反馈](https://github.com/Rodert/wechat-android-versions/issues)请通过 Issue 提交。
