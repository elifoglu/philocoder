sudo git pull
sudo rm -rf build
sudo elm-app build
cd build
sudo cp index.html 404.html
ps aux | grep http-server | awk '{print $2}' | head -n -1 | sudo xargs -n1 kill -9
sudo nohup http-server -s -p 80 &
echo "don't forget to add analytics code to index.html!"