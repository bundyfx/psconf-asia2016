Start-Transcript -Path C:\log.txt
netsh advfirewall firewall add rule name="TCP-Port" dir=in action=allow protocol=TCP localport=8000
$env:Path += ";C:\Python\Python35;C:\Python\Python35\Scripts\"
setx PATH $env:Path /M
python -m pip install --upgrade pip
python -m pip install django
python C:\myapp\manage.py runserver 0.0.0.0:8000
Stop-Transcript
