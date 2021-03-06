$path=Split-Path -parent $MyInvocation.MyCommand.Definition

#+-----------------------------------------------------------------------------+
#|
#|Author:  Deepak Vishwakarma and Pawankumar Dubey
#|
#|Email:   pawanadubey@gmail.com
#|
#|Purpose: Creating Users in active directory and sending email with password
#|
#|Date: 13th April, 2017
#|
#|Version: 1        						 
#|
#+-----------------------------------------------------------------------------+


#Send Mail
function sendMailToAll{
    [cmdletbinding()]
    Param (
    $To,
    $Cc,
    $CR,
    $username,
    $domain

   )
   Process{
        $sub="CR# "+$CR+": User Creation"
        $body="Hello $fname, `n `n Greetings! `n Your username is created in domain: $domain . `n Please use following user account for login: $domain\$username . `n  `n `n You will receive password in a seperate mail. `n`n `n `n This is system generated mail, please do not reply to this mail.`n In case of any concern please contact Domain Admin."
        Send-MailMessage -From "ActiveDirectoryUserCreationTool <ActiveDirectoryUserCreationTool@aduct.com>" -To $To -Cc $Cc -Subject $sub -Body $body -Priority High -SmtpServer "10.32.0.4"
   }
}

function sendMailPassword{
    [cmdletbinding()]
    Param (
    $To,
    $CR,
    $File

   )
   Process{
        $sub="RE: CR# "+$CR+": User Creation"
        $body="Hello $fname, `n `n Greetings! `n Please find attached password for user account created. `n `n This is system generated mail, please do not reply to this mail.`n In case of any concern please contact Domain Admin."
        Send-MailMessage -From "ActiveDirectoryUserCreationTool <ActiveDirectoryUserCreationTool@aduct.com>" -To $To -Subject $sub -Body $body -Attachments $File -Priority High -SmtpServer "10.32.0.4"
   }
}


#Password

function generatePassword(){
 
    $passwordNum=Get-Random -Minimum 1 -Maximum 9
    $passwordSpecialChar=[char[]](Get-Random -Minimum 35 -Maximum 38)
    $passwordUpperChar=[char[]](Get-Random -Minimum 65 -Maximum 90)

    $randomLength=Get-Random -Minimum 6 -Maximum 12

    for($i=1;$i -le $randomLength; $i++){
        $passwordArrayChar=$passwordArrayChar + [char[]](Get-Random -Minimum 97 -Maximum 122)
    }
    foreach($char in $passwordArrayChar)
    {
        $passwordChars=$passwordChars+$char
    }
    
    $password=[string]$passwordNum+[string]$passwordSpecialChar+[string]$passwordUpperChar+[string]$passwordChars

    return $password
}


function generateImage($password){

$passwordFilePath = "$HOME\Access.png"
$bmp = new-object System.Drawing.Bitmap 250,65
$font = new-object System.Drawing.Font Consolas,20
$brushBg = [System.Drawing.Brushes]::White
$brushFg = [System.Drawing.Brushes]::Red
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.FillRectangle($brushBg,0,0,$bmp.Width,$bmp.Height)
$graphics.DrawString($password,$font,$brushFg,10,10)
$graphics.Dispose()
$bmp.Save($passwordFilePath)
return $passwordFilePath 
   
}

$randomePassword=generatePassword
generateImage($randomePassword)




#AD User Creation
function createADUser{
    [cmdletbinding()]
    Param ( 
    $FirstName, 
    $Surname,
    $userName,
    $AccountPassword,
    $EmployeeID,
    $Email,
    $Description
   )
   Process{
   
        $Name=$FirstName+" "+$Surname
        $securePassword=ConvertTo-SecureString $AccountPassword –asplaintext –force 
	$domain=(Get-ADDomain).Forest
        New-ADUser -Name $Name -GivenName $FirstName -Surname $Surname -DisplayName $Name -AccountPassword $securePassword -SamAccountName $userName -EmployeeID $EmployeeID -PasswordNeverExpires $false -Enabled $true -UserPrincipalName $userName@$domain -EmailAddress $Email -Description $Description

        if(Get-ADUser -Filter { SamAccountName -eq $userName }){
            return $true
        }
        else{
            return $false
        }
   }
}



#Required Libraries
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

function validation{
[cmdletbinding()]
    Param (
    $value
   )
   Process{
    if($value -eq ""){
        return $false
    }
    else{
        return $true
    }
  }
}

#MAD Form
$madForm = New-Object System.Windows.Forms.Form
$madForm.Text = "MAD"
$madForm.MaximizeBox=$false
$madForm.FormBorderStyle = 'Fixed3D'
$madForm.Size = New-Object System.Drawing.Size(450,450)
$madForm.StartPosition = "CenterScreen"


#First Name Properties
$fnameLabel = New-Object System.Windows.Forms.Label
$fnameLabel.Text="FirstName*"
$fnameLabel.Location = New-Object System.Drawing.Size(10,10)  
$madForm.Controls.Add($fnameLabel)

$fnameTextBox = New-Object System.Windows.Forms.TextBox 
$fnameTextBox.Location = New-Object System.Drawing.Size(150,10) 
$fnameTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($fnameTextBox) 


#Last Name
$lnameLabel = New-Object System.Windows.Forms.Label
$lnameLabel.Text="LastName*"
$lnameLabel.Location = New-Object System.Drawing.Size(10,40) 
$madForm.Controls.Add($lnameLabel)

$lnameTextBox = New-Object System.Windows.Forms.TextBox 
$lnameTextBox.Location = New-Object System.Drawing.Size(150,40) 
$lnameTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($lnameTextBox) 


#User Name
$unameLabel = New-Object System.Windows.Forms.Label
$unameLabel.Text="UserName*"
$unameLabel.Location = New-Object System.Drawing.Size(10,70) 
$madForm.Controls.Add($unameLabel)

$unameTextBox = New-Object System.Windows.Forms.TextBox 
$unameTextBox.Location = New-Object System.Drawing.Size(150,70) 
$unameTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($unameTextBox) 

#Employee Id
$empLabel = New-Object System.Windows.Forms.Label
$empLabel.Text="Employee Id*"
$empLabel.Location = New-Object System.Drawing.Size(10,100) 
$madForm.Controls.Add($empLabel)

$empTextBox = New-Object System.Windows.Forms.TextBox 
$empTextBox.Location = New-Object System.Drawing.Size(150,100) 
$empTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($empTextBox) 


#Email
$emailLabel = New-Object System.Windows.Forms.Label
$emailLabel.Text="Email Id*"
$emailLabel.Location = New-Object System.Drawing.Size(10,130) 
$madForm.Controls.Add($emailLabel)

$emailTextBox = New-Object System.Windows.Forms.TextBox 
$emailTextBox.Location = New-Object System.Drawing.Size(150,130) 
$emailTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($emailTextBox) 

#Description
$crLabel = New-Object System.Windows.Forms.Label
$crLabel.Text="Description*"
$crLabel.Location = New-Object System.Drawing.Size(10,160) 
$madForm.Controls.Add($crLabel)

$crTextBox = New-Object System.Windows.Forms.TextBox 
$crTextBox.Location = New-Object System.Drawing.Size(150,160) 
$crTextBox.Size = New-Object System.Drawing.Size(260,500) 
$madForm.Controls.Add($crTextBox) 


#Submit Button
$SubButton = New-Object System.Windows.Forms.Button
$SubButton.Location = New-Object System.Drawing.Size(150,250)
$SubButton.Size = New-Object System.Drawing.Size(75,23)
$SubButton.Text = "Create User"
$SubButton.Add_Click(
                        {
                                $fname=$fnameTextBox.Text;
                                $lname=$lnameTextBox.Text;
                                $uname=$unameTextBox.Text;
                                $eid=$empTextBox.Text;
                                $email=$emailTextBox.Text;
                                $cr=$crTextBox.Text;
                                $Error.Clear()
                                if((validation -value $fname) -and (validation -value $lname) -and (validation -value $uname) -and (validation -value $eid) -and (validation -value $email) -and (validation -value $cr) ){
                                    Write-Host "True"
                                    $password =generatePassword
                                    $passFile=generateImage -password $password
                                    createADUser -FirstName $fname -Surname $lname -userName $uname -AccountPassword $password -EmployeeID $eid -Email $email -Description $cr
                                    if($Error){
                                        $notificationLabel.Text=$Error
                                    }
                                    else{
                                        $emailCC = @('User1inCC@aduct.com','User2inCC@aduct.com')
                                        $domainname=(Get-ADDomain).Forest
                                        sendMailPassword -To $email -CR $cr -File $passFile
                                        sendMailToAll -To $email -Cc $emailCC  -CR $cr -username $uname -domain $domainname
                                        $notificationLabel.Text ="User created and E-mail with the credential has been sent to the users."
                                        $notificationLabel.ForeColor="Green"
                                        $notificationLabel.Font="Comic Sans MS,12"
                                        $SubButton.Visible=$false
                                    }

                                }
                                else{
                                    $notificationLabel.Text = "Please fill up all the text fields."
                                    $notificationLabel.ForeColor="Red"
                                    $notificationLabel.Font="Comic Sans MS,15"

                                }
                                Remove-Item -Path $passFile
                                
                          }
                      )
$madForm.Controls.Add($SubButton)


#Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(250,250)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Quit"
$CancelButton.Add_Click({$madForm.Close()})
$madForm.Controls.Add($CancelButton)


#Notification
$notificationLabel = New-Object System.Windows.Forms.Label
$notificationLabel.Location = New-Object System.Drawing.Size(10,320)
$notificationLabel.size=New-Object System.Drawing.Size(400,400)
$madForm.Controls.Add($notificationLabel)


#Displaying Form
[void] $madForm.ShowDialog()
