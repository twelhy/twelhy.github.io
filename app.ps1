Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Терезе
$form = New-Object System.Windows.Forms.Form
$form.Text = "IP Manager"
$form.Size = New-Object System.Drawing.Size(350,300)
$form.StartPosition = "CenterScreen"

# Интерфейс аты
$interface = "Ethernet 2"

# IP көрсету жолағы
$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "Ағымдағы IP: белгісіз"
$labelIP.Location = New-Object System.Drawing.Point(20,20)
$labelIP.Size = New-Object System.Drawing.Size(300,30)
$form.Controls.Add($labelIP)

# IP оқу функциясы
function Update-IP {
    $ip = (Get-NetIPAddress -InterfaceAlias $interface -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
    if (!$ip) { $ip = "IP табылмады" }
    $labelIP.Text = "Ағымдағы IP: $ip"
}

# --- 📌 Соңғы октетті енгізу терезесі ---
function Show-IPInputBox {
    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.Text = "IP соңғы санын енгізу"
    $inputForm.Size = New-Object System.Drawing.Size(260,160)
    $inputForm.StartPosition = "CenterParent"

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "192.168.1.X  (X = 0–255)"
    $lbl.Location = New-Object System.Drawing.Point(20,20)
    $lbl.Size = New-Object System.Drawing.Size(200,20)
    $inputForm.Controls.Add($lbl)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location = New-Object System.Drawing.Point(20,50)
    $txt.Size = New-Object System.Drawing.Size(200,20)
    $inputForm.Controls.Add($txt)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Қолдану"
    $btnOK.Location = New-Object System.Drawing.Point(70,80)
    $btnOK.Add_Click({
        if ($txt.Text -match '^\d+$' -and [int]$txt.Text -ge 0 -and [int]$txt.Text -le 255) {
            $script:lastOctet = $txt.Text
            $inputForm.Close()
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("0-255 аралығында сан енгіз.")
        }
    })
    $inputForm.Controls.Add($btnOK)

    $inputForm.ShowDialog() | Out-Null
}

# --- 📌 Статикалық қою кнопкасы ---
$btnStatic = New-Object System.Windows.Forms.Button
$btnStatic.Text = "Статикалық IP қою"
$btnStatic.Location = New-Object System.Drawing.Point(20,70)
$btnStatic.Size = New-Object System.Drawing.Size(280,40)

$btnStatic.Add_Click({
    Show-IPInputBox

    if ($script:lastOctet) {
        $ip = "192.168.1.$lastOctet"
        Start-Process powershell -Verb RunAs -ArgumentList "
            netsh interface ip set address name='$interface' static $ip 255.255.255.0 192.168.1.1
        "
        Start-Sleep -Seconds 1
        Update-IP
    }
})

$form.Controls.Add($btnStatic)

# DHCP кнопкасы
$btnDHCP = New-Object System.Windows.Forms.Button
$btnDHCP.Text = "DHCP қосу"
$btnDHCP.Location = New-Object System.Drawing.Point(20,130)
$btnDHCP.Size = New-Object System.Drawing.Size(280,40)

$btnDHCP.Add_Click({
    Start-Process powershell -Verb RunAs -ArgumentList "
        netsh interface ip set address name='$interface' dhcp
    "
    Start-Sleep -Seconds 1
    Update-IP
})

$form.Controls.Add($btnDHCP)

# IP жаңарту кнопкасы
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "IP жаңарту"
$btnRefresh.Location = New-Object System.Drawing.Point(20,190)
$btnRefresh.Size = New-Object System.Drawing.Size(280,40)

$btnRefresh.Add_Click({
    Update-IP
})

$form.Controls.Add($btnRefresh)

# Терезе ашылғанда IP көрсету
Update-IP

# GUI қосу
$form.ShowDialog() | Out-Null
$form.DialogResult = [System.Windows.Forms.DialogResult]::OK
