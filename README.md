# CN-Kipfel 代码签名证书 —— 安装说明

本文件由 `setup.bat` / `setup.sh` 读取并展示。

## 一、这是什么

CN-Kipfel 自建了一条代码签名证书链，用来给本组织发布的 Windows 安装包签名。
Windows 并不预置这条链，所以在没装证书的机器上双击安装包会显示：

```
未知发布者 / Unknown publisher
```

这不是安装包有问题，而是系统缺少证书。安装一次，之后本组织发布的各个版本和
各个项目都能正常显示签名者。

## 二、脚本会做什么

1. 把根证书 `XChen446_Root_CA.crt` 装进 **受信任的根证书颁发机构**
2. 把中间证书 `CN-Kipfel_Organization_Common_CA_2026.pem` 装进 **中间证书颁发机构**

范围仅限当前用户：

- 不需要管理员权限
- 不改动系统级证书存储
- 不影响其他软件
- 不联网，不写入其他位置

安装过程中 Windows 会弹一次确认框，那是系统对「写入受信任根」的保护，点「是」即可。

## 三、你需要知道的风险

把一张根证书装进「受信任的根」，等于承认这张 CA 为任何域名和程序签发的证书。
所以只应该安装来源可信的根证书。

请确认证书包来自本组织官方仓库：

```
https://github.com/VRChatCN-Kipfel/.github/tree/certificates
```

从群文件、网盘、第三方镜像拿到的同名文件，请不要安装。想核对真伪，可与
NOTICE.md 里给出的算法比对文件指纹。

## 四、装完怎么验证

不需要 Windows SDK，PowerShell 自带：

```powershell
Get-AuthenticodeSignature .\<安装包文件名>.exe | Format-List
```

`Status` 显示 `Valid` 就说明链已成立，`SignerCertificate` 会显示本组织的签名证书。

## 五、以后怎么卸载

Win+R 输入 `certmgr.msc`，然后：

- 受信任的根证书颁发机构 → 证书 → 删除「XChen446 Root CA」
- 中间证书颁发机构 → 证书 → 删除「CN-Kipfel Organization Common CA 2026」

删除后系统恢复原状。

## 六、不想装证书也可以

直接运行安装包同样能装，只是每次都会看到「未知发布者」提示，需要自己确认文件
确实来自本组织的发布页。
