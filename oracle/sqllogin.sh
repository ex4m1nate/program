#!/sbin/sh

echo "select number!!"
echo " 1.BYNIKO "
echo " 2.BYNPUB "
echo " 3.FREIKO "
echo " 4.FREPUB "
echo " 5.QKNPUB "
echo " 6.QYNIKO "
echo " 7.QYNPUB "

read key

case "$key" in

        1) export ORACLE_SID=BYNIKO ;;
        2) export ORACLE_SID=BYNPUB ;;
        3) export ORACLE_SID=FREIKO ;;
        4) export ORACLE_SID=FREPUB ;;
        5) export ORACLE_SID=QKNPUB ;;
        6) export ORACLE_SID=QYNIKO ;;
        7) export ORACLE_SID=QYNPUB ;;


        *) echo "Not select number!!"
           exit ;;
esac

sqlplus / as sysdba @ora_login.sql

exit
