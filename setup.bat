@echo off
setlocal
cd /d "%~dp0"

rem 换行符必须是 CRLF。LF-only 的 .bat 会让 cmd 在括号块里解析 %%~F 时崩溃。
rem 靠 .gitattributes 保证 checkout 出来是 CRLF，参见分支根的 .gitattributes。

set "ROOT_CERT=XChen446_Root_CA.crt"
set "CA_CERT=CN-Kipfel_Organization_Common_CA_2026.pem"
set "README=README.md"
set "TARGET=%~1"

title CN-Kipfel 代码签名证书安装

rem ---------- 前置检查 ----------
if not exist "%ROOT_CERT%" goto :missing_root
if not exist "%CA_CERT%" goto :missing_ca
if not exist "%README%" goto :missing_readme
goto :show_readme

:missing_root
echo.
echo   [错误] 找不到 %ROOT_CERT%
goto :missing_hint

:missing_ca
echo.
echo   [错误] 找不到 %CA_CERT%
goto :missing_hint

:missing_readme
echo.
echo   [错误] 找不到 %README%
goto :missing_hint

:missing_hint
echo   请把 setup.bat、README.md 与两个证书文件放在同一目录后重试。
echo.
pause
exit /b 1

rem ---------- 展示 README 并等回车 ----------
:show_readme
cls
call :print_readme

echo.
echo ============================================================
echo   按【回车】= 同意并继续安装
echo   Ctrl+C 或关窗口 = 取消，不做任何改动
echo ============================================================
echo.
set "ANSWER="
set /p "ANSWER=  > "
echo.

rem ---------- 安装 ----------
echo [1/2] 安装根证书 ^-^> 受信任的根证书颁发机构 ...
certutil -addstore -user Root "%ROOT_CERT%" >nul 2>&1
if errorlevel 1 goto :fail_root
echo       完成。

echo [2/2] 安装中间证书 ^-^> 中间证书颁发机构 ...
certutil -addstore -user CA "%CA_CERT%" >nul 2>&1
if errorlevel 1 goto :fail_ca
echo       完成。
echo.

rem ---------- 可选验证 ----------
if defined TARGET goto :verify_target
call :verify_any
goto :finish

:verify_target
if not exist "%TARGET%" goto :target_missing
call :verify "%TARGET%"
goto :finish

:target_missing
echo [提示] 传入的文件不存在：%TARGET%
goto :finish

:finish
echo.
echo ============================================================
echo   完成。现在可以关闭本窗口。
echo ============================================================
echo.
pause
exit /b 0

:fail_root
echo.
echo   [失败] 根证书未安装成功。
echo   常见原因：确认框被点了「否」，或文件损坏。
echo   可手动执行：certutil -addstore -user Root "%ROOT_CERT%"
echo.
pause
exit /b 1

:fail_ca
echo.
echo   [失败] 中间证书未安装成功。
echo   可手动执行：certutil -addstore -user CA "%CA_CERT%"
echo.
pause
exit /b 1

rem ---------- 子过程 ----------
:print_readme
rem 用 more 而不是 type：more 会按行分页显示长文本，并等待按键翻页；
rem 这里只是把 README 完整打出来，所以用 type 保持一次性输出。
type "%README%"
goto :eof

:verify_any
set "FOUND="
for %%F in ("*.exe") do if not defined FOUND set "FOUND=%%~fF"
if not defined FOUND goto :no_exe
call :verify "%FOUND%"
goto :eof

:no_exe
echo [提示] 当前目录没有 exe，跳过签名验证。
echo        以后想验证，把安装包拖到 setup.bat 上即可。
goto :eof

:verify
if not exist "%~1" goto :eof
echo 验证签名：%~nx1
powershell -NoProfile -Command "$s = Get-AuthenticodeSignature -LiteralPath '%~f1'; Write-Host ('  Status : ' + $s.Status); if ($s.SignerCertificate) { Write-Host ('  Signer : ' + $s.SignerCertificate.Subject) }; if ($s.Status -eq 'Valid') { Write-Host '  结果   : 签名有效' } else { Write-Host '  结果   : 未通过（证书未生效或文件被改动）' }"
goto :eof
