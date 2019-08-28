$packageName = 'chrome'
$fileType = 'msi'
$fileLocation = "http://10.0.2.11/choco/Chrome/GoogleChromeEnterpriseBundle64/Installers/GoogleChromeStandaloneEnterprise64.msi"
#$fileLocation = "http://10.0.2.11/packages/chrome/GoogleChromeStandaloneEnterprise64.msi"
#$fileLocation = "http://10.0.2.11/choco/Chrome/GoogleChromeEnterpriseBundle64/Installers/GoogleChromeStandaloneEnterprise64.msi"
$silentArgs = '/qn'

Install-ChocolateyPackage $packageName $fileType $silentArgs $fileLocation
