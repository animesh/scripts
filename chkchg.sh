#https://unix.stackexchange.com/a/249238
while true
do
       touch  ./lastwatch
       sleep 10
       find $HOME/PD/HF -name "*.raw" -cnewer ./lastwatch -exec bash mqrun.sh {} \;
done

