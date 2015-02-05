# Controle le nombre exacte de parametre (dans notre exemple 1
# Controle si c'est l'uid 0 qui lance la macro
# Controle si le fichier existe bien

if   (! [ $# -eq "1" -a $UID -eq "0" -a -f "$1" ]) 
 then
 clear
 echo -e "Attention, il doit y avoir 3 conditions au lancement du script\n"
 echo -e "le nombre de parametre doit etre egal a 1\n"
 echo -e "seul root peut lancer le script\n"
 echo -e "le nom de fichier en parametre doit etre present"
  else

# Controle s'il y a bien 4 champs par ligne
# transforme les majuscules en minuscules
# verifie si les champs uid et gid sont numeriques et superieur ou egal 500


   awk 'NF==4' $1 | tr 'A-Z' 'a-z' | awk '$3 $4 ~ /^[0-9][0-9]*$/ && $3 >=500 && $4 >=500' | (while read NOM PRENOM NUMUID NUMGID
do 
   CONNEXION=$PRENOM.$NOM 

# Controle si le login est superieur a 32 caracteres
# Controle si le nom de login est deja utilise
# Controle si le numero uid a deja ete utilise

   if ( [ ${#CONNEXION} -gt 32 ]>>/dev/null 2>&1 || grep -w ^$CONNEXION /etc/passwd>>/dev/null 2>&1 || (cut -d: -f3 /etc/passwd | grep -w $NUMUID >> /dev/null 2>&1) )
    then   
          echo -e "$NOM $PRENOM $NUMUID $NUMGID" >> /tmp/refuse
     else

# Controle si le GID existe
# Controle si le nom de groupe est deja utilise dans le cas ou il faut le creer
          CREATE=0
          if (( ! grep -w $NUMGID /etc/group >>/dev/null 2>&1 ) && ( grep -w ^$NOM /etc/group >>/dev/null 2>&1 ))
             then 
                echo -e "le GID n'existe pas mais le nom du groupe $NOM existe deja"
                CREATE=1
              else
                groupadd -g $NUMGID $NOM >>/dev/null 2>&1
          fi
          if [ $CREATE -eq "0" ]
            then
                 useradd -u $NUMUID -g $NUMGID $CONNEXION 
          fi
   fi
done)
fi
