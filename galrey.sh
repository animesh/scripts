ls ../galreyimages/ > ./galrey.ls
dog -b ./galrey.ls > galrey.nms
sed -e 's/.png//' galrey.nms > galrey.fn
join -o 1.2,2.2 galrey.nms galrey.fn > galrey.memo
galrey

