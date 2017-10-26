#!/bin/bash
#Créer un Vagrantfile: vagrant init
#Puis nano du Vagrantfile et modifier les lignes suivantes:
#- config.vm.box = "xenial.box"
#- #config.vm.network "private_network", ip: "192.168.33.10" qui est à décommenter
#- #config.vm.synced_folder "../data", "/vagrant_data" à faire devenir -> config.vm.synced_folder "data", "/var/www/html" et à décommenter
#Démarrer sa Vagrant: vagrant up
#Se connecter en SSH sur sa Vagrant: vagrant ssh

#Fonction de création et /ou d'écriture dans Vagrantfile
writeVagrantfile(){
  echo "# -*- mode: ruby -*-
  Vagrant.configure('2') do |config|
  config.vm.box = '$box'
  config.vm.network 'private_network', ip: '192.168.33.10'
  config.vm.synced_folder '$chemin', '$cheminServ'
  config.vm.provider 'virtualbox' do |vb|
  vb.memory = '1024'
  end
  end" > Vagrantfile;
}

#====================================================================
# Verification installation vagrant et virtualbox
#====================================================================

installVirtualbox(){
  echo '';
  echo '===============================================================================';
  echo "Verification de la présence de virtualbox.                                  "
  echo "Virtualbox sera automatiquement installé s'il ne l'est pas déja             ";
  echo '';
  if [[ -z $(which virtualbox) ]]; then
    echo "INSTALLATION DE VIRTUALBOX";
    sudo apt-get install virtualbox-5.1;
  else
    echo "Virtualbox est déja installé";
  fi
  echo '===============================================================================';
  echo "";
}


installVagrant(){
  echo '';
  echo '===============================================================================';
  echo "Verification de la présence de vagrant.                                     "
  echo "Vagrant sera automatiquement installé s'il ne l'est pas déja                ";
  echo '';
  if [[ -z $(which vagrant) ]]; then
    echo "INSTALLATION DE VAGRANT";
    sudo apt-get install vagrant;
  else
    echo "Vagrant est déja installé";
  fi
  echo '===============================================================================';
  echo '';
  echo '';
}

menuPrincipal(){
  echo ""
  echo "1. Intaller Virtualbox"
  echo "2. Intaller Vagrant"
  echo "3. Gerer ses Vagrants"
  echo "";
}

menuGestionVagrant(){
  echo ""
  echo "1. Installer une vagrant"
  echo "2. Afficher les vagrants"
  echo "3. Supprimer une vagrant"
  echo "4. Retour au menu principal"
  echo "";
}


menuPrincipal
while read -p "Que faire ? " VAR; do
  case $VAR in
    1) installVirtualbox;;
    2) installVagrant;;

    3) menuGestionVagrant;
       while read -p "Que faire ? " var;do
         case $var in

           1) #=======================================================================
              # Check pour Installation de VB et Vagrant et création d'une vagrant
              # Demande si volonté de la lancer
              #=======================================================================
              installVirtualbox;
              installVagrant;
              echo '';
             echo "1. ubuntu/xenial64";
             echo "2. primalskill/ubuntu-trusty64";
             echo "3. Autre box"
             read -p "Indiquer le nom de l'OS de la box . (par défaut : ubuntu/xenial64) " CHOIX;
             case $CHOIX in
               1) box="ubuntu/xenial64" ;;
               2) box="primalskill/ubuntu-trusty64";;
               3) box="$CHOIX";;
               *) box="ubuntu/xenial64" ;; # Choix par défaut
             esac;
             echo '';
             read -p "Chemin de votre dossier syncronisé en local (par défaut 'data') Il sera automatiquement créé s'il n'éxiste pas: " chemin;
             read -p "Chemin de votre dossier syncronisé sur le serveur (par défaut '/var/www/html/'): " cheminServ;
             #on teste si les variables sont vides, si oui on leur donne une valeur par défaut
             if [ -z "$chemin" ] ; then
               chemin="data";
             fi
             if [ -z "$cheminServ" ]; then
               cheminServ="/var/www/html";
             fi

             #Si le dossier de syncro n'éxiste pas sur notre ordi on le creer
             if [ ! -d "$chemin" ]; then
               mkdir "$chemin";
             fi

             #Test de l'éxistance de VagrantFile
             if [ -f "Vagrantfile" ] && [ -s "Vagrantfile" ]
              then
                # Si il existe on prévient et on propose de l'overwrite
                 echo "Vagrantfile existe déja et n'est pas vide.";
                 while read -p "Voulez vous écrire par dessus ce fichier ? O/N : " rep;do
                     case $rep in
                       O) # Si on veut l'overwrite on écrit dans le fichier et on sort de la boucle
                          echo 'Overwrite du Vagrantfile';
                          writeVagrantfile;
                          break ;;
                         N) # Si on ne veux pas l'overwrite on sort de la boucle et on utilisera l'éxistant
                          break ;;
                     esac;
                 done;
             else
               # Sinon le Vgfile n'existe pas on le créé
                echo "Création du Vagrantfile";
                 writeVagrantfile;
             fi

             while read -p "Voulez vous lancer la vagrant ? O/N : " rep; do
               case $rep in
                 O) # Si on veut l'overwrite on écrit dans le fichier et on sort de la boucle
                     vagrant up
                     vagrant ssh
                     break ;;
                 N) # Si on ne veux pas l'overwrite on sort de la boucle et on utilisera l'éxistant
                    break ;;
                esac;
              done;;

           2) #=======================================================================
              # Afficher les vagrants en cours d'éxécution
              #=======================================================================

              echo '';
              vagrant global-status ;;
           3) #=======================================================================
              # Afficher les vagrants en cours d'éxécution puis demande lequel doit etre kill
              #=======================================================================
              echo '';
              vagrant global-status
              read -p "Donner l'ID de la vagrant kill ? (defaut Enter pour passer) " id;
              if [[ ! -z "$id" ]]; then
                vagrant destroy "$id";
              else
                echo "Abort the kill";
              fi ;;
            4) menuPrincipal
              break ;;

          esac;
          menuGestionVagrant;
       done;

  esac;
done;
