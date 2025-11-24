docker build -t ubuntu18.04-xfce-novnc:latest .

docker run -d -p 5901:5901 -p 6080:6080 --name test-vnc   -v vnc-home-data:/home/vncuser ubuntu18.04-xfce-novnc:latest     

localhost:6080

YOUR_VNC_PASSWORD