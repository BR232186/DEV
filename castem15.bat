@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
color 07

SET VERSION=15
SET REVISION=0
SET CASTEM_REP=C:\Cast3M\PCW_15

REM Enregistrement de l'heure initiale
SET STARTDATE0=%DATE%
SET STARTTIME0=%TIME%
SET LIGNEUP=ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
SET LIGNEDOWN=ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
SET LIGNEMIDDLE=ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน

REM Detection si WIN32 ou WIN64-bits ou si BIT est deja defini
IF "%BIT%"=="64" (
  SET MINGWPATH="%CASTEM_REP%\MinGW\x64-4.6.3-posix-sjlj-rev2\mingw\bin"
  GOTO SUITE
) ELSE IF "%BIT%"=="32" (
  SET MINGWPATH="%CASTEM_REP%\MinGW\x32-4.6.3-posix-dwarf-rev2\mingw\bin"
  GOTO SUITE)

IF DEFINED ProgramFiles(x86) (
  SET BIT=64
  SET MINGWPATH="%CASTEM_REP%\MinGW\x64-4.6.3-posix-sjlj-rev2\mingw\bin"
) ELSE (
  SET BIT=32
  SET MINGWPATH="%CASTEM_REP%\MinGW\x32-4.6.3-posix-dwarf-rev2\mingw\bin")
  
REM Balise de suite pour tenir compte de la definition de BIT
:SUITE

REM retrait des doubles cotes
SET MINGWPATH2=%MINGWPATH:~1,-1%

REM Definition du chemin pour aller trouver les librairies dynamiques (.dll)
SET PATH=%MINGWPATH2%;%PATH%;%CASTEM_REP%\lib%BIT%

REM Definition des chemins pour les fichiers ERREUR, MASTER et PROC
SET CASTEM_ERREUR=%CASTEM_REP%\data\GIBI.ERREUR
SET CASTEM_NOTICE=%CASTEM_REP%\data\GIBI.MASTER
SET CASTEM_PROC=%CASTEM_REP%\data\GIBI.PROC
SET DIRLIC=%CASTEM_REP%\licence

REM Le nom du binaire depend du type de licence
IF EXIST "%DIRLIC%" (
  SET castX=bin_Cast3M_Win_INDUS_%BIT%_%VERSION%.exe
  SET TYPELICENCE=                        Licence INDUSTRIELLE                          
) ELSE (
  SET castX=bin_Cast3M_Win_DEVEL_%BIT%_%VERSION%.exe
  SET TYPELICENCE=                   Licence EDUCATION - RECHERCHE                      )

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
SET DEBUG=
SET AIDE=FAUX
SET HELP=FAUX

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
  color F2
  SHIFT
  GOTO DEBUT_LECTURE
)

REM activation du mode DEBUG
IF  "%ArgNAME1%"=="-d" (
  IF EXIST "%MINGWPATH2%\gdb.exe" (
    SET DEBUG=%MINGWPATH2%\gdb.exe
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

REM Reglage de la memoire reservee par Cast3M (Par defaut 80% de la memoire physique totale)
IF  "%ArgNAME1%"=="-MEM" (
  IF "%ArgNAME2%"=="" (
ECHO.
ECHO Il manque la quantite de memoire a reserver en Mo apres l'option -MEM
    GOTO mess_fin
  ) ELSE (
    SET /A Val=%ArgNAME2% * 8 / %BIT% * 1024 * 1024
    SET ESOPE_PARAM=%ESOPE_PARAM%,ESOPE=!Val!
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
REM Nom sans extension donne en argument
SET NomF2=%~n1
SET NomF2text=%NomF2%.dgibi                                                บ
REM Repertoire du jeu de donnees (Drive Letter\Chemin sans Drive Letter)
SET NomF3=%~d1%~p1
SET NomF3text=%NomF3%                                                      บ

REM Le fichier donne existe : On calcule sa taille
IF EXIST "%NomF%" (
  CALL :size_file %NomF%
)

REM Les espaces apres %USERNAME% et %CD% sont importants
SET size=%size% octets                                              บ

REM Fin de la lecture des arguments
:FIN_LECTURE


IF "%AIDE%"=="VRAI" (
REM Affiche l'aide en Francais
  TYPE "%CASTEM_REP%\bin\Aide_Fr_Cast3M_%VERSION%.txt"
  GOTO :EOF
)
IF "%HELP%"=="VRAI" (
REM Affiche l'aide en Francais
  TYPE "%CASTEM_REP%\bin\Aide_En_Cast3M_%VERSION%.txt"
  GOTO :EOF
)

ECHO.
ECHO %LIGNEUP%
ECHO บ %TYPELICENCE% บ
ECHO %LIGNEMIDDLE%

IF EXIST %castX_Local% (
  REM Execution de l'executable cast local
  ECHO บ                   EXECUTION de %castX_Local%  LOCAL                   บ
  SET CASTEXEC="%castX_Local%"
) ELSE (
  REM Execution de l'executable Cast3M d'origine
  ECHO บ          EXECUTION de %castX% ORIGINAL          บ
  ECHO บ                           Realisation %VERSION%.0.%REVISION%                           บ
  SET CASTEXEC="%CASTEM_REP%\bin\%castX%")
  REM retrait des doubles cotes
SET CASTEXEC=%CASTEXEC:~1,-1%

REM Les espaces apres %USERNAME% et %CD% sont importants
SET UTILISATEUR=%USERNAME%                                                      บ
SET REPERTOIRE_COURANT=%CD%                                                      บ

ECHO %LIGNEMIDDLE%
ECHO บ UTILISATEUR    : %UTILISATEUR:~0,54%บ
ECHO บ REPERTOIRE EXEC: %REPERTOIRE_COURANT:~0,54%บ

IF NOT "%NomF%"=="" (
  REM Cas ou un nom de fichier est donne
  TITLE Cast3M 20%VERSION% - %BIT%bits : %NomF2%.dgibi
  REM Definition du nom pour la sortie du fichier .trace (Drive Letter\Chemin sans Drive Letter\Nom du fichier sans chemin ni extension)
  SET CASTEM_PROJET=%~d1%~p1%~n1

  ECHO บ REPERTOIRE JEU : %NomF3text:~0,54%บ
  ECHO บ NOM FICHIER    : %NomF2text:~0,54%บ
  IF EXIST "%NomF%" (
    COPY "%NomF%" fort.3>nul
    ECHO บ TAILLE FICHIER : %size:~0,54%บ
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

ECHO บ DATE  DEBUT    : %STARTDATE0%                                            บ
ECHO บ HEURE DEBUT    : %STARTTIME0%                                           บ
ECHO บ Nombre CPU     : !NUMBER_OF_PROCESSORS:~0,3!                                                     บ

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
SET DURATION_TOT=%DURATIONH%:%DURATIONM%:%DURATIONS%,%DURATIONCS%         บ

ECHO.
ECHO %LIGNEUP%
ECHO บ                          INFORMATIONS FINALES                          บ
ECHO %LIGNEMIDDLE%
ECHO บ DATE  DEBUT    : %STARTDATE0%      HEURE DEBUT    : %STARTTIME0%          บ
ECHO บ DATE  FIN      : %ENDDATE0%      HEURE FIN      : %ENDTIME0%          บ
ECHO บ                                  DUREE          : %DURATION_TOT:~0,20% บ
ECHO บ                                                                        บ
ECHO บ Support  Cast3M : http://www-cast3m.cea.fr/index.php?page=mailsupport  บ
ECHO บ Site Web Cast3M : http://www-cast3m.cea.fr/index.php                   บ
ECHO %LIGNEDOWN%

REM Menage dans les fichiers en sortant de Cast3M
IF EXIST  fort.3       DEL  fort.3
IF EXIST "%NomF2%.lgi" DEL "%NomF2%.lgi"
IF EXIST "%NomF2%.mIF" DEL "%NomF2%.mIF"

IF EXIST fort.25 MOVE /Y fort.25 "%NomF2%.lgi">nul
IF EXIST fort.97 MOVE /Y fort.97 "%NomF2%.mIF">nul

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

SET size=-4
IF EXIST "%NomF2%.dgibi" (
  CALL :size_file %NomF2%.dgibi
)
IF %size%==0 DEL "%NomF2%.dgibi"


REM pause effectuee si l'option --pause a ete renseignee
IF DEFINED PAUSEFIN (pause)

REM la couleur est REMise a la couleur Standard
color 07
ENDLOCAL
GOTO :EOF

:size_file
REM Calcul la taille d'un fichier en octets passe en argument
SET size=%~z1
