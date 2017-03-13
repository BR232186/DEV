@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
color 07
SET LIGNEUP=������������������������������������������������������������������������ͻ
SET LIGNEDOWN=������������������������������������������������������������������������ͼ
SET LIGNEMIDDLE=������������������������������������������������������������������������͹

SET VERSION=16
SET REVISION=1
SET CASTEM_REP=C:\Cast3M\PCW_16

REM Enregistrement de l'heure initiale
SET STARTDATE0=%DATE%
SET STARTTIME0=%TIME%

REM Detection si WIN32 ou WIN64-bits ou si BIT est defini
IF "%BIT%"=="64" (

  SET MINGWPATH="%CASTEM_REP%\MinGW\x86_64-5.3.0-posix-sjlj-rt_v4-rev0\mingw64\bin"
  GOTO SUITE
) ELSE IF "%BIT%"=="32" (

  SET MINGWPATH="%CASTEM_REP%\MinGW\x32-4.6.3-posix-dwarf-rev2\mingw\bin"
  GOTO SUITE)

IF DEFINED ProgramFiles(x86) (
  SET BIT=64

  SET MINGWPATH="%CASTEM_REP%\MinGW\x86_64-5.3.0-posix-sjlj-rt_v4-rev0\mingw64\bin"
) ELSE (
  SET BIT=32

  SET MINGWPATH="%CASTEM_REP%\MinGW\x32-4.6.3-posix-dwarf-rev2\mingw\bin")

REM Balise de suite pour tenir compte de la definition de BIT
:SUITE


REM retrait des doubles cotes de part et d'autre de la variable MINGWPATH
SET MINGWPATH=%MINGWPATH:~1,-1%

REM Definition du chemin pour aller trouver les librairies dynamiques (.dll)
SET PATH=%MINGWPATH%;%PATH%;%CASTEM_REP%\lib%BIT%

REM Definition des chemins pour les fichiers ERREUR, MASTER et PROC
SET CASTEM_ERREUR=%CASTEM_REP%\data\GIBI.ERREUR
SET CASTEM_NOTICE=%CASTEM_REP%\data\GIBI.MASTER
SET CASTEM_PROC=%CASTEM_REP%\data\GIBI.PROC
SET DIRLIC=%CASTEM_REP%\licence
REM Le nom du binaire depend du type de licence
IF EXIST "%DIRLIC%" (
  SET castX=bin_Cast3M_Win_INDUS_%BIT%_%VERSION%.exe
  SET TYPELICENCE=                        Licence INDUSTRIELLE                           �
) ELSE (
  SET castX=bin_Cast3M_Win_DEVEL_%BIT%_%VERSION%.exe
  SET TYPELICENCE=                   Licence EDUCATION - RECHERCHE                       �)

SET castX_Local=cast_%BIT%_%VERSION%.exe

REM NTRK : Nombre de blocs de debordement
REM LTRK : Taille des blocs du fichier de debordement
REM ESOPE : (Optionnel) Memoire Virtuelle reservee au lancement de Cast3M en MOTS (1 MOT = 4 octets en 32-bits et 8 octets en 64-bits)
SET ESOPE_PARAM=NTRK=500000,LTRK=1
IF EXIST "%TMP%" (
  SET ESOPE_TEMP=%TMP%
) ELSE (
  SET ESOPE_TEMP=C:/tmp)
SET MIF_PATH=%CASTEM_REP%\header

REM Suppression des fichiers issus d'une precedente utilisation de castem%VERSION%
IF EXIST fort.3  DEL fort.3
IF EXIST fort.25 DEL fort.25
IF EXIST fort.97 DEL fort.97


REM Initialisations :
SET PAUSEFIN=
SET TEST=
SET DEBUG=
SET AIDE=
SET HELP=
SET NomF=
SET NomF2=
REM Les espaces apres %USERNAME% et %CD% sont importants
SET UTILISATEUR=%USERNAME%                                                      �
SET REPERTOIRE_COURANT=%CD%                                                      �

REM Lecture des Arguments d'entree
:DEBUT_LECTURE
SET ArgNAME1=%~1
SET ArgNAME2=%2

REM affichage de l'aide en Francais
IF "%ArgNAME1%"=="--aide" (
  SET AIDE=VRAI
  SHIFT
)

REM affichage de l'aide en Anglais
IF "%ArgNAME1%"=="--help" (
  SET HELP=VRAI
  SHIFT
)

REM lancement avec l'icone : pause a la fin du script pour ne pas perdre le contenu de la fenetre
IF "%ArgNAME1%"=="--pause" (
  SET PAUSEFIN=VRAI
  color 07
  SHIFT
  GOTO DEBUT_LECTURE
)

REM lancement avec l'icone : pause a la fin du script pour ne pas perdre le contenu de la fenetre
IF "%ArgNAME1%"=="-test" (
  SET TEST=VRAI
  SHIFT
  GOTO DEBUT_LECTURE
)

REM activation du mode DEBUG
IF  "%ArgNAME1%"=="-d" (
  IF EXIST "%MINGWPATH%\gdb.exe" (
    SET DEBUG=%MINGWPATH%\gdb.exe
    SHIFT
    GOTO DEBUT_LECTURE
  ) ELSE (
    ECHO.
    ECHO   Vous devez installer la version DEVELOPPEUR de Cast3M pour utiliser
    ECHO   cette option
    GOTO mess_fin)
  SHIFT
  GOTO DEBUT_LECTURE
)

REM Reglage de la memoire physique maximale reservee pour Cast3M 
REM (Par defaut 80% de la memoire physique totale)
IF  "%ArgNAME1%"=="-MEM" (
  IF "%ArgNAME2%"=="" (
    ECHO.
    ECHO Il manque la quantite de memoire a reserver en Go apres l'option -MEM
    GOTO mess_fin
  ) ELSE (
    SET /A Val=%ArgNAME2%* 1024  * 1024 * 8 / %BIT% * 1024
    SET ESOPE_PARAM=%ESOPE_PARAM%,ESOPE=!Val!
    ECHO !ESOPE_PARAM!
    SHIFT
    SHIFT
    GOTO DEBUT_LECTURE )
)

REM Faire UTILPROC et UTILNOTI
IF  "%ArgNAME1%"=="-u" (
  CALL "%CASTEM_REP%\bin\cast_UTIL%VERSION%"
  SHIFT
)

REM Nom complet        donne en argument
SET NomF=%~1
SET NomFDGIBI=
REM Nom sans extension donne en argument
SET NomF2=%~n1
SET NomF2text=%NomF2%.dgibi                                                �
REM Repertoire du jeu de donnees (Drive Letter\Chemin sans Drive Letter)
SET NomF3=%~d1%~p1
SET NomF3text=%NomF3%                                                      �

REM Travail sur le fichier d'entree (existence etc...)
IF EXIST "%NomF%.dgibi" (
  SET NomFDGIBI=%NomF%.dgibi
  CALL :size_file %NomF%
) ELSE IF EXIST "%NomF%" (
  SET NomFDGIBI=%NomF%
  CALL :size_file %NomF%
) ELSE (
  SET NomF2=Castem_20%VERSION%_Defaut)
SET CASTEM_PROJET=%NomFDGIBI%
SET NomF2text=%NomFDGIBI%                                                       �

REM Les espaces apres octets sont importants
SET size=%size% octets                                              �

REM Fin de la lecture des arguments
:FIN_LECTURE

IF NOT DEFINED TEST GOTO :APRES_TEST

REM Lancement de la base des Cas-Tests si on passe ici
ECHO.
IF "%REPERTOIRE_COURANT%"=="%CASTEM_REP%" (
  ECHO Impossible de lancer la base des cas-tests dans le repertoire d'installation
  GOTO :EOF
)

REM Preparation des repertoires de travail
IF EXIST dgibi  RD /S /Q dgibi
IF EXIST divers RD /S /Q divers
MKDIR dgibi
MKDIR divers
COPY "%CASTEM_REP%\dgibi\*"  dgibi >nul
COPY "%CASTEM_REP%\divers\*" divers>nul
IF EXIST %castX_Local% COPY %castX_Local% dgibi>nul
IF EXIST UTILPROC      COPY UTILPROC      dgibi>nul
IF EXIST UTILNOTI      COPY UTILNOTI      dgibi>nul
CD dgibi

REM Calcul du nombre de dgibi
SET /A dgibicompt=0
FOR %%i IN (*.dgibi) DO SET /A dgibicompt+=1

REM Lancement des Cas-Tests
SET /A dgibinum=1
SET /A dgibierr=0
IF !dgibicompt! GTR 0 (
  FOR %%j IN (*.dgibi) DO (
    SET NomF=%%j
    SET NomF2=!NomF:~0,-6!
    ECHO !NomF!
    ECHO  Cas-tests reussis : !dgibinum!/!dgibicompt!
    ECHO FIN; | castem%VERSION% !NomF! > !NomF2!.res 2>&1

    REM Verifie la presence de la chaine de caractere "ARRET DU PROGRAMME GIBI NIVEAU D'ERREUR:   0" : Si elle est absente, le cas-tests a echoue
    SET /A ERROR_CASTEM=0
    for /f "delims=" %%i in ('find /C "ARRET DU PROGRAMME GIBI NIVEAU D'ERREUR:   0" !NomF2!.res ^| find /C /I "!NomF2!.res: 0"') DO SET /A ERROR_CASTEM=%%i

    IF !ERROR_CASTEM!==0 (
      SET /A dgibinum+=1
    ) ELSE (
      SET /A dgibierr+=1
      MOVE /Y !NomF2!.res !NomF2!.err>nul 2>&1
      REM ATTENTION : les espaces dans NomF3 sont importants pour la presentation
      SET NomF3=!NomF!                                                                 �
      ECHO � !NomF3:~0,71!�>>ZZZ_ERROR.log)
    IF !dgibierr! GTR 0 ECHO  Cas-tests echoues : !dgibierr!/!dgibicompt!
    ECHO.
  )

  REM Affichage final apres l'execution
  ECHO %LIGNEUP%
  IF !dgibierr!==0 (
    ECHO �               LES CAS-TESTS ONT ETE EXECUTES AVEC SUCCES               �
  ) ELSE (
    SET NBR_ERROR=!dgibierr!   �
    ECHO �                LES !NBR_ERROR:~0,4! CAS-TESTS SUIVANTS ONT ECHOUES                 �
    ECHO %LIGNEMIDDLE%
    TYPE ZZZ_ERROR.log
    ECHO %LIGNEMIDDLE%
    ECHO �               Consultez les fichiers .err correspondants               �)

  ECHO %LIGNEDOWN%) ELSE (
  ECHO.
  ECHO Aucun fichier .dgibi dans ce repertoire
  ECHO.)
  GOTO :EOF

:APRES_TEST

IF DEFINED AIDE (
REM Affiche l'aide en Francais
  ECHO.
  ECHO %LIGNEUP%
  ECHO �NOM                                                                     �
  ECHO �    castem%VERSION% : Logiciel de calcul par Element Finis                     �
  ECHO �    Site web : http://www-cast3m.cea.fr/                                �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �VERSION                                                                 �
  ECHO �    Version du Script : %VERSION%.%REVISION%                                            �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �SYNTAXE                                                                 �
  ECHO �    castem%VERSION% [OPTION]... [LISTE_FICHIERS]...                            �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �DESCRIPTION                                                             �
  ECHO �     --aide   : Affiche le manuel de cette commande en Francais         �
  ECHO �     --help   : Affiche le manuel de cette commande en Anglais          �
  ECHO �     -test    : execute la base des cas-tests de Cast3M                 �
  ECHO �     -u       : Contruit UTILPROC et UTILNOTI                           �
  ECHO �     -d       : Lance Cast3M avec gdb [Version developpeur]             �
  ECHO �     -MEM xxx : Permet d'allouer la memoire physique maximale           �
  ECHO �                utilisable pas Cast3M. "xxx" est un chiffre en Go       � 
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �EXEMPLES                                                                �
  ECHO �     castem%VERSION%                                                           �
  ECHO �          Lance Cast3M sans jeu de donnee : Mode Interactif             �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% fichier                                                   �
  ECHO �          Lance le jeu de donnee 'fichier'                              �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% -d fichier                                                �
  ECHO �          Lance le jeu de donnee 'fichier' dans l'environnement         �
  ECHO �          gdb                                                           �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% -u fichier                                                �
  ECHO �          Construit UTILPROC et UTILNOTI avec les fichiers .procedur    �
  ECHO �          et .notice du repertoire courant et lance le jeu de donnee    �
  ECHO �          'fichier'                                                     �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �AUTEUR                                                                  �
  ECHO �    Script ecrit par Clement BERTHINIER                                 �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �VOIR AUSSI                                                              �
  ECHO �    Aide du Script 'compilcast%VERSION%' : 'compilcast%VERSION% --aide'               �
  ECHO �    Aide du Script 'essaicast%VERSION%'  : 'essaicast%VERSION%  --aide'               �
  ECHO �    [Version developpeur de Cast3M seulement]                           �
  ECHO �                                                                        �
  ECHO %LIGNEDOWN%
  GOTO :EOF
)
IF DEFINED HELP (
REM Affiche l'aide en Anglais
  ECHO.
  ECHO %LIGNEUP%
  ECHO �NOM                                                                     �
  ECHO �    castem%VERSION% : Finite Element solver Software                           �
  ECHO �    Site web : http://www-cast3m.cea.fr/                                �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �VERSION                                                                 �
  ECHO �    Script Version    : %VERSION%.%REVISION%                                            �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �SYNTAX                                                                  �
  ECHO �    castem%VERSION% [OPTION]... [FILES_LIST]...                                �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �DESCRIPTION                                                             �
  ECHO �     --aide   : Print the manual of this script in French               �
  ECHO �     --help   : Print the manual of this script in English              �
  ECHO �     -test    : run the Cast3M testing files                            �
  ECHO �     -u       : Build UTILPROC and UTILNOTI                             �
  ECHO �     -d       : Execute Cast3M with gdb [Developpeur Version]           �
  ECHO �     -MEM xxx : Allows to allocate the maximum physical memory to       �
  ECHO �                Cast3M execution. "xxx" is a real number in Go          � 
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �EXAMPLES                                                                �
  ECHO �     castem%VERSION%                                                           �
  ECHO �          Execute Cast3M without any input file : Interactive mode      �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% file                                                      �
  ECHO �          Execute Cast3M with the input file 'file'                     �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% -d file                                                   �
  ECHO �          Execute Cast3M with the input file 'file'                     �
  ECHO �          in the gdb environment                                        �
  ECHO �                                                                        �
  ECHO �     castem%VERSION% -u file                                                   �
  ECHO �          Build UTILPROC and UTILPROC with the files .procedur  and     �
  ECHO �          .notice of the current directory and execute the input file   �
  ECHO �          'file'                                                        �
  ECHO �                                                                        �
  ECHO �      castem%VERSION% -test                                                    �
  ECHO �           Runs all test cases                                          �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �AUTHOR                                                                  �
  ECHO �    Script written by Clement BERTHINIER                                �
  ECHO �                                                                        �
  ECHO %LIGNEMIDDLE%
  ECHO �SEE ALSO                                                                �
  ECHO �    Manual for 'compilcast%VERSION%' : 'compilcast%VERSION% --help'                   �
  ECHO �    Manual for 'essaicast%VERSION%'  : 'essaicast%VERSION%  --help'                   �
  ECHO �    [Developper version of Cast3M only]                                 �
  ECHO �                                                                        �
  ECHO %LIGNEDOWN%
  GOTO :EOF
)

ECHO.
ECHO %LIGNEUP%
ECHO � %TYPELICENCE% 
ECHO %LIGNEMIDDLE%

IF EXIST %castX_Local% (
  REM Execution de l'executable cast local
  ECHO �                   EXECUTION de %castX_Local%  LOCAL                   �
  SET CASTEXEC="%castX_Local%"
) ELSE (
  REM Execution de l'executable Cast3M d'origine
  ECHO �          EXECUTION de %castX% ORIGINAL          �
  ECHO �                           Realisation %VERSION%.0.%REVISION%                           �
  SET CASTEXEC="%CASTEM_REP%\bin\%castX%")
  REM retrait des doubles cotes
SET CASTEXEC=%CASTEXEC:~1,-1%

ECHO %LIGNEMIDDLE%
ECHO � UTILISATEUR    : %UTILISATEUR:~0,54%�
ECHO � REPERTOIRE EXEC: %REPERTOIRE_COURANT:~0,54%�

IF NOT "%NomFDGIBI%"=="" (
  REM Cas ou un nom de fichier est donne
  TITLE Cast3M 20%VERSION% - %BIT%bits : %NomFDGIBI%
  REM Definition du nom pour la sortie du fichier .trace (Drive Letter\Chemin sans Drive Letter\Nom du fichier sans chemin ni extension)
  

  ECHO � REPERTOIRE JEU : %NomF3text:~0,54%�
  ECHO � NOM FICHIER    : %NomF2text:~0,54%�
  IF EXIST "%NomFDGIBI%" (
    ECHO � TAILLE FICHIER : %size:~0,54%�
  )

  REM Affichage des informations sur la licence INDUSTRIELLE le cas Echeant
  IF EXIST "%DIRLIC%" (
    ECHO INFO INFO; >> fort.3
  )
) ELSE (
  REM Cas ou aucun nom de fichier n'est donne
  TITLE Cast3M 20%VERSION% - %BIT%bits
  REM Definition du nom pour la sortie du fichier .trace (Drive Letter\Chemin sans Drive Letter\Nom du fichier sans chemin ni extension)
  SET CASTEM_PROJET=Castem_20%VERSION%_Output
  SET NomF2=Castem_20%VERSION%_Output

  REM Affichage des informations sur la licence INDUSTRIELLE le cas Echeant
  IF EXIST "%DIRLIC%" (
    ECHO INFO INFO; >> fort.3
  ) )

ECHO � DATE  DEBUT    : %STARTDATE0%                                            �
ECHO � HEURE DEBUT    : %STARTTIME0%                                           �
ECHO � Nombre CPU     : !NUMBER_OF_PROCESSORS:~0,3!                                                     �

ECHO %LIGNEMIDDLE%
TYPE "%CASTEM_REP%\bin\LOGO_ASCII_%VERSION%.txt"
ECHO %LIGNEDOWN%

CALL %DEBUG% "%CASTEXEC%"

:mess_fin
REM Enregistrement de la date finale et de l'heure finale
SET ENDDATE0=%DATE%
SET ENDTIME0=%TIME%

REM convert STARTTIME0 and ENDTIME0 to centiseconds
IF     "%STARTTIME0:~0,1%"==" " SET /A STARTTIME=%STARTTIME0:~1,1%*360000
IF NOT "%STARTTIME0:~0,1%"==" " SET /A STARTTIME=%STARTTIME0:~0,2%*360000
IF     "%STARTTIME0:~3,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~4,1%*6000
IF NOT "%STARTTIME0:~3,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~3,2%*6000
IF     "%STARTTIME0:~6,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~7,1%*100
IF NOT "%STARTTIME0:~6,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~6,2%*100
IF     "%STARTTIME0:~9,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~10,1%
IF NOT "%STARTTIME0:~9,1%"=="0" SET /A STARTTIME=%STARTTIME% + %STARTTIME0:~9,2%

IF     "%ENDTIME0:~0,1%"==" "   SET /A ENDTIME=%ENDTIME0:~1,1%*360000
IF NOT "%ENDTIME0:~0,1%"==" "   SET /A ENDTIME=%ENDTIME0:~0,2%*360000
IF     "%ENDTIME0:~3,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~4,1%*6000
IF NOT "%ENDTIME0:~3,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~3,2%*6000
IF     "%ENDTIME0:~6,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~7,1%*100
IF NOT "%ENDTIME0:~6,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~6,2%*100
IF     "%ENDTIME0:~9,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~10,1%
IF NOT "%ENDTIME0:~9,1%"=="0"   SET /A ENDTIME=%ENDTIME% + %ENDTIME0:~9,2%

REM calculating the duration is easy
SET /A DURATION=%ENDTIME%-%STARTTIME%

REM we might have measured the time inbetween days
IF %ENDTIME% LSS %STARTTIME% SET SET /A DURATION=%STARTTIME%-%ENDTIME%

REM now break the centiseconds down to hours, minutes, seconds and the REMaining centiseconds
SET /A DURATIONH=%DURATION% / 360000
SET /A DURATIONM=(%DURATION% - %DURATIONH%*360000) / 6000
SET /A DURATIONS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000) / 100
SET /A DURATIONCS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000 - %DURATIONS%*100)

REM some formatting
IF %DURATIONH% LSS 10 SET DURATIONH=0%DURATIONH%
IF %DURATIONM% LSS 10 SET DURATIONM=0%DURATIONM%
IF %DURATIONS% LSS 10 SET DURATIONS=0%DURATIONS%
IF %DURATIONCS% LSS 10 SET DURATIONCS=0%DURATIONCS%

REM les espaces a la fin de DURATION_TOT sont importants
SET DURATION_TOT=%DURATIONH%:%DURATIONM%:%DURATIONS%,%DURATIONCS%         �

ECHO.
ECHO %LIGNEUP%
ECHO �                          INFORMATIONS FINALES                          �
ECHO %LIGNEMIDDLE%
ECHO � DATE  DEBUT    : %STARTDATE0%      HEURE DEBUT    : %STARTTIME0%          �
ECHO � DATE  FIN      : %ENDDATE0%      HEURE FIN      : %ENDTIME0%          �
ECHO �                                  DUREE          : %DURATION_TOT:~0,20% �
ECHO �                                                                        �
ECHO � Support  Cast3M : http://www-cast3m.cea.fr/index.php?page=mailsupport  �
ECHO � Site Web Cast3M : http://www-cast3m.cea.fr/index.php                   �
ECHO %LIGNEDOWN%

REM Suppression des fichiers UTILPROC, UTILNOTI, .dgibi, .ps s'ils sont de taille nulle
SET size=-1
IF EXIST UTILPROC (
  CALL :size_file UTILPROC
)
IF %size%==0 DEL UTILPROC

SET size=-2
IF EXIST UTILNOTI (
  CALL :size_file UTILNOTI
)
IF %size%==0 DEL UTILNOTI

SET size=-3
IF EXIST "%NomF2%.ps" (
  CALL :size_file %NomF2%.ps
)
IF %size%==0 DEL "%NomF2%.ps"

REM pause effectuee si l'option --pause a ete renseignee
IF DEFINED PAUSEFIN (pause)

REM la couleur est REMise a la couleur Standard
color 07
ENDLOCAL
GOTO :EOF



:size_file
REM Calcul la taille d'un fichier en octets passe en argument
SET size=%~z1
