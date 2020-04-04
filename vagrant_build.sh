#! /bin/bash


_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo $_HOME_
cd $_HOME_

mkdir -p ./artefacts/
# mkdir -p ./workspace/
mkdir -p ./data/

cp -av do_it___external.sh ./artefacts/runme.sh
chmod a+x ./artefacts/runme.sh

cp -av build_tbw.sh ./artefacts/build_tbw.sh
chmod a+x ./artefacts/build_tbw.sh

cp -av encrypt_persistent.sh ./artefacts/encrypt_persistent.sh
chmod a+x ./artefacts/encrypt_persistent.sh

cp -av enter_screen_name.sh ./artefacts/enter_screen_name.sh
chmod a+x ./artefacts/enter_screen_name.sh

vagrant destroy -f
vagrant up

