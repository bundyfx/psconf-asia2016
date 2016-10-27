break
#size and presentation mode

Start-VM ContainerHost


Invoke-Command -VMName ContainerHost -Credential ($Creds = Get-Credential administrator) -ScriptBlock {
(gip).Ipv4Address.Ipaddress[0]
} -OutVariable IP

$env:DOCKER_HOST = "tcp://$IP`:2375"

git clone -b demo https://github.com/bundyfx/nodejs-ps-conf.git -q C:\psconf\nodejs
sl C:\psconf\nodejs

docker build . -t books

docker run -p 5000:5000 -d books

start microsoft-edge:http://$IP`:5000

docker rm -f (docker ps -aq)

code .\src\views\index.ejs
#<h1>Flynn's Recommendations

docker build . -t books:dev

docker run -p 5000:5000 -d books:dev

start microsoft-edge:http://$IP`:5000

docker inspect (docker ps -aq) | ConvertFrom-Json

1..3 | %{docker run -d microsoft/nanoserver}

docker search microsoft

# Docker for Windows
$env:DOCKER_HOST = $null

start microsoft-edge:https://github.com/Netflix/vizceral-example

git clone https://github.com/Netflix/vizceral-example -q

#build 

docker run -p 41911:8080 -d example

start microsoft-edge:http://localhost:41911


