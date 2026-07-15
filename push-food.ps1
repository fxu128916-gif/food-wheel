<#
.SYNOPSIS
  美食大转盘 - 一键推送 data.json 到 GitHub
.DESCRIPTION
  下载 admin.html 生成的 data.json 后，放到 food-wheel 目录，运行此脚本即可推送。
  使用方法：
    1. 打开 https://fxu128916-gif.github.io/food-wheel/admin.html
    2. 编辑美食 → 下载 data.json
    3. 将 data.json 放在此脚本同目录下（或 C:\Users\PC\.easyclaw\workspace\outputs\food-wheel\）
    4. 运行此脚本
#>

$FoodWheelDir = "C:\Users\PC\.easyclaw\workspace\outputs\food-wheel"
$DownloadDir = "$env:USERPROFILE\Downloads"

Write-Host "🍜 美食大转盘 - 自动推送 data.json" -ForegroundColor Yellow

# 查找最新下载的 data.json
$downloaded = Get-ChildItem -Path $DownloadDir -Filter "data.json" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $downloaded) {
    Write-Host "❌ 找不到下载的 data.json，请先在 admin.html 下载！" -ForegroundColor Red
    exit 1
}

$srcPath = $downloaded.FullName
$destPath = Join-Path $FoodWheelDir "data.json"

Write-Host "📥 找到: $srcPath" -ForegroundColor Green
Write-Host "📤 复制到: $destPath" -ForegroundColor Green

# 读取 JSON 验证
try {
    $content = Get-Content $srcPath -Raw
    $foods = $content | ConvertFrom-Json
    Write-Host "✅ JSON 有效，包含 $($foods.Count) 项美食：" -ForegroundColor Green
    $foods | ForEach-Object { Write-Host "  $($_.emoji) $($_.name)" }
} catch {
    Write-Host "❌ JSON 格式无效！" -ForegroundColor Red
    exit 1
}

# 复制文件
Copy-Item -Path $srcPath -Destination $destPath -Force

# Git 操作
Set-Location $FoodWheelDir

Write-Host ""
Write-Host "📝 提交并推送..." -ForegroundColor Yellow
git add data.json

$message = "🍜 更新美食清单 ($($foods.Count)项) - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git commit -m $message

Write-Host "🚀 推送到 GitHub..." -ForegroundColor Yellow
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 推送成功！1-2分钟后生效：" -ForegroundColor Green
    Write-Host "   https://fxu128916-gif.github.io/food-wheel/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 当前美食清单（$($foods.Count) 项）：" -ForegroundColor Yellow
    $foods | ForEach-Object { Write-Host "  $($_.emoji) $($_.name)" }
} else {
    Write-Host "❌ 推送失败，请检查网络/Git配置" -ForegroundColor Red
}
