Add-Type -AssemblyName System.Drawing

function Generate-NardanaIcon {
    param(
        [int]$Size,
        [string]$OutputPath
    )

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $g.Clear([System.Drawing.Color]::Transparent)

    $padding = [math]::Round($Size * 0.04)
    $innerSize = $Size - (2 * $padding)
    $cornerRadius = [math]::Round($Size * 0.22)

    # 1. Background Rounded Squircle with Deep Blue Gradient
    $rect = New-Object System.Drawing.Rectangle($padding, $padding, $innerSize, $innerSize)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.ColorTranslator]::FromHtml("#16457A"),
        [System.Drawing.ColorTranslator]::FromHtml("#0C233E"),
        135.0
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $cornerRadius * 2
    $arc = New-Object System.Drawing.Rectangle($padding, $padding, $diameter, $diameter)

    # Top left arc
    $path.AddArc($arc, 180, 90)
    # Top right arc
    $arc.X = $rect.Right - $diameter
    $path.AddArc($arc, 270, 90)
    # Bottom right arc
    $arc.Y = $rect.Bottom - $diameter
    $path.AddArc($arc, 0, 90)
    # Bottom left arc
    $arc.X = $rect.Left
    $path.AddArc($arc, 90, 90)
    $path.CloseFigure()

    $g.FillPath($brush, $path)

    # 2. Golden Accent Ring
    $goldPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml("#F3B83F"), [math]::Max(2, [math]::Round($Size * 0.025)))
    $g.DrawPath($goldPen, $path)

    # Center coordinates
    $cx = $Size / 2.0
    $cy = $Size / 2.0

    # 3. Community House / Digital Arch Silhouette
    # Base scale
    $scale = $Size / 100.0

    # Digital Community Node / Signal Circles (Green #16A36A)
    $greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#16A36A"))
    $greenPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml("#16A36A"), [math]::Max(1.5, 2.5 * $scale))

    # Outer transmission waves above roof
    $waveRect1 = New-Object System.Drawing.RectangleF(($cx - 18 * $scale), ($cy - 38 * $scale), (36 * $scale), (36 * $scale))
    $g.DrawArc($greenPen, $waveRect1, 210, 120)

    $waveRect2 = New-Object System.Drawing.RectangleF(($cx - 26 * $scale), ($cy - 44 * $scale), (52 * $scale), (52 * $scale))
    $goldWavePen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml("#F3B83F"), [math]::Max(1.2, 2.0 * $scale))
    $g.DrawArc($goldWavePen, $waveRect2, 215, 110)

    # Central glowing digital beacon node
    $beaconSize = 8 * $scale
    $g.FillEllipse($greenBrush, ($cx - $beaconSize / 2), ($cy - 23 * $scale - $beaconSize / 2), $beaconSize, $beaconSize)

    # 4. White Community Temple / Village Home Roof
    $whitePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, [math]::Max(2.5, 4.5 * $scale))
    $whitePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Roof Points
    $roofPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $roofTop = New-Object System.Drawing.PointF($cx, ($cy - 16 * $scale))
    $roofLeft = New-Object System.Drawing.PointF(($cx - 28 * $scale), ($cy + 6 * $scale))
    $roofRight = New-Object System.Drawing.PointF(($cx + 28 * $scale), ($cy + 6 * $scale))
    $g.DrawLine($whitePen, $roofLeft, $roofTop)
    $g.DrawLine($whitePen, $roofTop, $roofRight)

    # House Body (White)
    $bodyRect = New-Object System.Drawing.RectangleF(($cx - 21 * $scale), ($cy + 6 * $scale), (42 * $scale), (26 * $scale))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillRectangle($whiteBrush, $bodyRect)

    # 5. Welcoming Village Gateway Arch (Deep Blue Cutout in center)
    $archBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#123B67"))
    $archRect = New-Object System.Drawing.RectangleF(($cx - 9 * $scale), ($cy + 14 * $scale), (18 * $scale), (18 * $scale))
    $archPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $archPath.AddArc($archRect.X, $archRect.Y, $archRect.Width, $archRect.Width, 180, 180)
    $archPath.AddLine(($archRect.Right), ($archRect.Y + $archRect.Height), ($archRect.Left), ($archRect.Y + $archRect.Height))
    $archPath.CloseFigure()
    $g.FillPath($archBrush, $archPath)

    # Golden Pillar Accent on arch
    $goldAccentPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml("#F3B83F"), [math]::Max(1.0, 1.8 * $scale))
    $g.DrawLine($goldAccentPen, ($cx - 9 * $scale), ($cy + 22 * $scale), ($cx - 9 * $scale), ($cy + 32 * $scale))
    $g.DrawLine($goldAccentPen, ($cx + 9 * $scale), ($cy + 22 * $scale), ($cx + 9 * $scale), ($cy + 32 * $scale))

    # Clean up and save
    $dir = [System.IO.Path]::GetDirectoryName($OutputPath)
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose()
    $brush.Dispose()
    $goldPen.Dispose()
    $greenBrush.Dispose()
    $greenPen.Dispose()
    $goldWavePen.Dispose()
    $whitePen.Dispose()
    $whiteBrush.Dispose()
    $archBrush.Dispose()
    $archPath.Dispose()
    $path.Dispose()
    $roofPath.Dispose()
    $bmp.Dispose()

    Write-Host "Generated: $OutputPath ($Size x $Size)"
}

# Generate all mipmap resolutions for Android
$baseRes = "c:\ide\nardana connect\apps\mobile\android\app\src\main\res"
Generate-NardanaIcon -Size 48  -OutputPath "$baseRes\mipmap-mdpi\ic_launcher.png"
Generate-NardanaIcon -Size 72  -OutputPath "$baseRes\mipmap-hdpi\ic_launcher.png"
Generate-NardanaIcon -Size 96  -OutputPath "$baseRes\mipmap-xhdpi\ic_launcher.png"
Generate-NardanaIcon -Size 144 -OutputPath "$baseRes\mipmap-xxhdpi\ic_launcher.png"
Generate-NardanaIcon -Size 192 -OutputPath "$baseRes\mipmap-xxxhdpi\ic_launcher.png"

# Generate Master 512x512 High-Res Icons
Generate-NardanaIcon -Size 512 -OutputPath "c:\ide\nardana connect\assets\branding\app_icon_512.png"
Generate-NardanaIcon -Size 512 -OutputPath "c:\ide\nardana connect\apps\mobile\assets\images\app_logo.png"
Generate-NardanaIcon -Size 512 -OutputPath "c:\ide\nardana connect\apps\admin\public\app-logo.png"
