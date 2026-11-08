# NOTICE —— 证书链元数据与维护说明

本文件面向**维护者与需要手工核对的人**。普通用户安装证书只需双击 `setup.bat`，
运行时会展示 `README.md`，不需要读这里。

## 分支性质

这是一个**无父提交的孤儿分支**，与 `main`（组织 profile）没有共同历史，不参与任何
构建，也不承载代码。它只做一件事：给本组织的签名证书链提供一个稳定的下载地址。

**不要把它合并进 `main`。**

## 文件清单

| 文件 | 说明 |
|---|---|
| `CN-Kipfel_Organization_Common_CA_2026.pem` | 中间 CA，签发可执行文件签名证书 |
| `XChen446_Root_CA.crt` | 根 CA，仅作为信任锚验证中间 CA |
| `README.md` | 用户安装说明，**由脚本读取并展示**，不是给维护者看的 |
| `setup.bat` | Windows 安装脚本，写入当前用户证书存储 |
| `setup.sh` | MSYS/MinGW/Cygwin 下的等价脚本；其他平台只输出说明，不改动系统 |
| `NOTICE.md` | 本文件 |

## 证书详情

### XChen446_Root_CA.crt

```
Subject     : CN=XChen446 Root CA, O=XChen446, C=CN
Description : 根 CA 证书，一般仅用于验证中间 CA，不直接签发证书
Validity    : 至 9999-12-31
```

### CN-Kipfel_Organization_Common_CA_2026.pem

```
Subject     : CN=CN-Kipfel Organization Common CA 2026
              OU=VRChat 中文 Kipfel 厅, O=VRChat 中文 Kipfel 厅, C=CN
Issuer      : CN=XChen446 Second Metaverse CA 2026
Validity    : 至 2076-10-26
```

两个文件都**只含公钥证书**（只有 `-----BEGIN CERTIFICATE-----`），不含私钥。

## 证书链

```
XChen446 Root CA
└─ XChen446 Second Metaverse CA 2026
   └─ CN-Kipfel Organization Common CA 2026
      └─ CN-Kipfel Forked vrcx'about short CA
         └─ Forked about VRCX-0 short Code Signing   ← 实际签名证书
```

签名证书本身（含私钥）**不在本分支，也不在任何仓库**，只存在于组织的签名环境
与 CI secret 中。本分支只提供验证所需的公钥中间件。

## 核对指纹

```powershell
Get-FileHash XChen446_Root_CA.crt, CN-Kipfel_Organization_Common_CA_2026.pem -Algorithm SHA256
```

```bash
sha256sum XChen446_Root_CA.crt CN-Kipfel_Organization_Common_CA_2026.pem
```

通过比对 git 历史中该文件的 blob 校验更可靠：

```bash
git ls-tree certificates -- CN-Kipfel_Organization_Common_CA_2026.pem
git cat-file blob <blob-sha> | sha256sum
```

## 设计约定

1. **README 与脚本分离。** 脚本用 `type` / `cat` 读取 `README.md` 再展示，不把
   正文内嵌进脚本。这样改措辞只动一个文件，也不会因为 cmd 的字符编码问题把中文
   搞坏。
2. **同意提示由脚本负责，不写在 README 里。** README 只讲「这是什么、会做什么、
   有什么风险」；`按回车 = 同意` 这句话是脚本在读完 README 之后自己输出的，两者
   各管一段，避免同一句话出现两次。
3. **README 用标准 Markdown 写。** 它在 GitHub 网页上也会被渲染，所以不要用
   `=====` / `-----` 这类 ASCII 分隔线——那在 Markdown 里会变成标题或分割线，
   渲染出来是乱的。要强调用标题层级、引用块、代码围栏。
4. **轮换时追加，不删除旧文件。** 已发布的安装包依赖旧链才能验证通过。
5. **不存放私钥。** 任何时候都不应该把 `.pfx`、`.key` 之类提交进来。
6. **只写当前用户证书存储**（`-user`），不申请管理员权限，不碰系统级存储。

## 与发布方的关系

本组织各项目的 release notes 可能链接本分支的证书包。之所以放在组织级仓库而不是
某个具体项目仓库：

- 这张 CA 是**组织级**资产，签发给组织内多个项目的安装包
- 项目的重建、迁移、归档都不影响这里的链接
- 证书生命周期与任何代码版本都无关
