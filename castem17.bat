@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET LIGNEUP=ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
SET LIGNEDOWN=ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
SET LIGNEMIDDLE=ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
SET LIGNEVIDE=                                                                           บazerty


REM Enregistrement de l'heure initiale
SET STARTDATE0=%DATE%
SET STARTTIME0=%TIME%


REM Chargement de l'environnement
CALL environnement_Cast3M17

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

IF EXIST "%TMP%" (
  SET ESOPE_TEMP=%TMP%
) ELSE (
  SET ESOPE_TEMP=C:/tmp)
SET MIF_PATH=%CASTEM_REP%\header

REM Initialisations :
SET PAUSEFIN=
SET /A ERROLEV=0
SET DEBUG=
SET AIDE=
SET HELP=
SET SWAP=VRAI
SET Val=
SET NomF=
SET NomF2=
SET ESOPE_PARAM=
SET MEMDEF=FAUX
SET ZERMEM=FAUX

REM Les espaces apres %USERNAME% et %CD% sont importants
SET UTILISATEUR=%USERNAME%                                                      บ
SET REPERTOIRE_COURANT=%CD%                                                      บ

REM Lecture des Arguments d'entree
:DEBUT_LECTURE
SET ArgNAME1=%~1
SET ArgNAME2=%2

REM affichage de l'aide en Francais
IF "%ArgNAME1%"=="--aide" (
  SET AIDE=VRAI
  GOTO LABEL_AIDE
)
IF "%ArgNAME1%"=="-aide" (
  SET AIDE=VRAI
  GOTO LABEL_AIDE
)
IF "%ArgNAME1%"=="aide" (
  SET AIDE=VRAI
  GOTO LABEL_AIDE
)
IF "%ArgNAME1%"=="/?" (
  SET AIDE=VRAI
  GOTO LABEL_AIDE
)

REM affichage de l'aide en Anglais
IF "%ArgNAME1%"=="--help" (
  SET HELP=VRAI
  GOTO LABEL_HELP
)
IF "%ArgNAME1%"=="-help" (
  SET HELP=VRAI
  GOTO LABEL_HELP
)
IF "%ArgNAME1%"=="help" (
  SET HELP=VRAI
  GOTO LABEL_HELP
)
IF "%ArgNAME1%"=="-h" (
  SET HELP=VRAI
  GOTO LABEL_HELP
)

REM lancement avec l'icone : pause a la fin du script pour ne pas perdre le contenu de la fenetre
IF "%ArgNAME1%"=="--pause" (
  SET PAUSEFIN=VRAI
  SHIFT
  GOTO DEBUT_LECTURE
)

REM lancement avec l'icone : pause a la fin du script pour ne pas perdre le contenu de la fenetre
IF "%ArgNAME1%"=="-test" (
  GOTO CAS_TESTS
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

REM deactivation du debordement MEMOIRE
IF  "%ArgNAME1%"=="-NOSWAP" (
  SET SWAP=FAUX
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
    SET /A Val=%ArgNAME2% * 1024 / %BIT%  * 1024 * 8
    SET MEMDEF=VRAI
    SHIFT
    SHIFT
    GOTO DEBUT_LECTURE )
)

REM remise a zero physique de la MEMOIRE
IF  "%ArgNAME1%"=="-ZERMEM" (
  SET ZERMEM=VRAI
  SHIFT
  GOTO DEBUT_LECTURE
)

REM Reglage du nombre de CPU reserves par Cast3M (Par defaut la totalite des CPU disponibles sont pris)
IF  "%ArgNAME1%"=="-NCPU" (
  IF "%ArgNAME2%"=="" (
    ECHO.
    ECHO Il manque le nombre de CPU a reserver apres l'option -NCPU
    GOTO mess_fin
  ) ELSE (
    SET CPU_CAST3M=%ArgNAME2%
    SHIFT
    SHIFT
    GOTO DEBUT_LECTURE )
)

REM Faire UTILPROC et UTILNOTI
IF  "%ArgNAME1%"=="-u" (
  CALL "%CASTEM_REP%\bin\cast_UTIL%VERSION%"
  SHIFT
  GOTO DEBUT_LECTURE
)

REM Nom complet        donne en argument
SET NomF=%~1
SET NomFDGIBI=
REM Nom sans extension donne en argument
SET NomF2=%~n1
REM Repertoire du jeu de donnees (Drive Letter\Chemin sans Drive Letter)
SET NomF3=%~d1%~p1
SET NomF3text=%NomF3%                                                      บ

REM Travail sur le fichier d'entree (existence etc...)
IF EXIST "%NomF%.dgibi" (
  SET NomFDGIBI=%NomF%.dgibi
  CALL :size_file %NomF%.dgibi
) ELSE IF EXIST "%NomF%" (
  SET NomFDGIBI=%NomF%
  CALL :size_file %NomF%
) ELSE (
  SET NomF2=Castem_20%VERSION%_Defaut)
SET CASTEM_PROJET=%NomFDGIBI%
SET NomF2text=%NomFDGIBI%                                                       บ

REM Les espaces apres octets sont importants
SET size=%size% octets                                              บ

:LABEL_AIDE
IF DEFINED AIDE (
REM Affiche l'aide en Francais
  ECHO.
  ECHO %LIGNEUP%
  ECHO บNOM                                                                     บ
  ECHO บ    castem%VERSION% : Logiciel de calcul par Element Finis                     บ
  ECHO บ    Site web : http://www-cast3m.cea.fr/                                บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บVERSION                                                                 บ
  ECHO บ    Version du Script : %VERSION%.%REVISION%                                            บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บSYNTAXE                                                                 บ
  ECHO บ    castem%VERSION% [OPTION]... [LISTE_FICHIERS]...                            บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บDESCRIPTION                                                             บ
  ECHO บ     --aide  : Affiche le manuel de cette commande en Francais          บ
  ECHO บ     --help  : Affiche le manuel de cette commande en Anglais           บ
  ECHO บ     -test   : execute la base des cas-tests de Cast3M                  บ
  ECHO บ     -u      : Contruit UTILPROC et UTILNOTI                            บ
  ECHO บ     -d      : Lance Cast3M avec gdb [Version developpeur]              บ
  ECHO บ     -MEM Val: Memoire reservee par Cast3M en MegaOctets                บ
  ECHO บ     -ZERMEM : Remise a zero physique de la memoire                     บ
  ECHO บ     -NOSWAP : Interdiction d'utiliser le fichier de debordement        บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บEXEMPLES                                                                บ
  ECHO บ     castem%VERSION%                                                           บ
  ECHO บ          Lance Cast3M sans jeu de donnee : Mode Interactif             บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% fichier                                                   บ
  ECHO บ          Lance le jeu de donnee 'fichier'                              บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% -d fichier                                                บ
  ECHO บ          Lance le jeu de donnee 'fichier' dans l'environnement         บ
  ECHO บ          gdb                                                           บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% -u fichier%                                                บ
  ECHO บ          Construit UTILPROC et UTILNOTI avec les fichiers .procedur    บ
  ECHO บ          et .notice du repertoire courant et lance le jeu de donnee    บ
  ECHO บ          'fichier'                                                     บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บAUTEUR                                                                  บ
  ECHO บ    Script ecrit par Clement BERTHINIER                                 บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บVOIR AUSSI                                                              บ
  ECHO บ    Aide du Script 'compilcast%VERSION%' : 'compilcast%VERSION% --aide'               บ
  ECHO บ    Aide du Script 'essaicast%VERSION%'  : 'essaicast%VERSION%  --aide'               บ
  ECHO บ    [Version developpeur de Cast3M seulement]                           บ
  ECHO บ                                                                        บ
  ECHO %LIGNEDOWN%
  EXIT /B !ERROLEV!
)
:LABEL_HELP
IF DEFINED HELP (
REM Affiche l'aide en Anglais
  ECHO.
  ECHO %LIGNEUP%
  ECHO บNOM                                                                     บ
  ECHO บ    castem%VERSION% : Finite Element solver Software                           บ
  ECHO บ    Site web : http://www-cast3m.cea.fr/                                บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บVERSION                                                                 บ
  ECHO บ    Script Version    : %VERSION%.%REVISION%                                            บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บSYNTAX                                                                  บ
  ECHO บ    castem%VERSION% [OPTION]... [FILES_LIST]...                                บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บDESCRIPTION                                                             บ
  ECHO บ     --aide  : Print the manual of this script in French                บ
  ECHO บ     --help  : Print the manual of this script in English               บ
  ECHO บ     -test   : run the Cast3M testing files                             บ
  ECHO บ     -u      : Build UTILPROC and UTILNOTI                              บ
  ECHO บ     -d      : Execute Cast3M with gdb [Developpeur Version]            บ
  ECHO บ     -MEM Val: Memoire allocated by Cast3M in MegaOctets                บ
  ECHO บ     -ZERMEM : The memory is physicaly defined to 0                     บ
  ECHO บ     -NOSWAP : The SWAP is not allowed                                  บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บEXAMPLES                                                                บ
  ECHO บ     castem%VERSION%                                                           บ
  ECHO บ          Execute Cast3M without any input file : Interactive mode      บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% file                                                      บ
  ECHO บ          Execute Cast3M with the input file 'file'                     บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% -d file                                                   บ
  ECHO บ          Execute Cast3M with the input file 'file'                     บ
  ECHO บ          in the gdb environment                                        บ
  ECHO บ                                                                        บ
  ECHO บ     castem%VERSION% -u file                                                   บ
  ECHO บ          Build UTILPROC and UTILPROC with the files .procedur  and     บ
  ECHO บ          .notice of the current directory and execute the input file   บ
  ECHO บ          'file'                                                        บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บAUTHOR                                                                  บ
  ECHO บ    Script written by Clement BERTHINIER                                บ
  ECHO บ                                                                        บ
  ECHO %LIGNEMIDDLE%
  ECHO บSEE ALSO                                                                บ
  ECHO บ    Manual for 'compilcast%VERSION%' : 'compilcast%VERSION% --help'                   บ
  ECHO บ    Manual for 'essaicast%VERSION%'  : 'essaicast%VERSION%  --help'                   บ
  ECHO บ    [Developper version of Cast3M only]                                 บ
  ECHO บ                                                                        บ
  ECHO %LIGNEDOWN%
  EXIT /B !ERROLEV!
)

REM Fin de la lecture des arguments
:FIN_LECTURE

IF %SWAP%==VRAI (
  REM NTRK : Nombre de blocs de debordement
  REM LTRK : Taille des blocs du fichier de debordement
  SET ESOPE_PARAM=NTRK=300000,LTRK=1
)
IF %MEMDEF%==VRAI (
  REM ESOPE : (Optionnel) Memoire Virtuelle reservee au lancement de Cast3M en MOTS (1 MOT = 4 octets en 32-bits et 8 octets en 64-bits)
  IF "!ESOPE_PARAM!"=="" (
    SET ESOPE_PARAM=ESOPE=!Val!
  ) ELSE (
    SET ESOPE_PARAM=!ESOPE_PARAM!,ESOPE=!Val!)
)

IF %ZERMEM%==VRAI (
  REM ZERMEM : OUI (remet la memoire physiquement a 0), NON (remise a zero vituelle ==> Par defaut)
  IF "!ESOPE_PARAM!"=="" (
    SET ESOPE_PARAM=ZERMEM=OUI
  ) ELSE (
    SET ESOPE_PARAM=!ESOPE_PARAM!,ZERMEM=OUI)
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
  ECHO บ          EXECUTION de %castX% ORIGINAL%LIGNEVIDE:~65,11%
  ECHO บ                           Realisation %VERSION%.0.%REVISION%%LIGNEVIDE:~48,28%
  SET CASTEXEC="%CASTEM_REP%\bin\%castX%")
  REM retrait des doubles cotes
SET CASTEXEC=%CASTEXEC:~1,-1%

ECHO %LIGNEMIDDLE%
ECHO บ UTILISATEUR    : %UTILISATEUR:~0,54%บ
ECHO บ REPERTOIRE EXEC: %REPERTOIRE_COURANT:~0,54%บ

IF NOT "%NomFDGIBI%"=="" (
  REM Cas ou un nom de fichier est donne
  TITLE Cast3M 20%VERSION% - %BIT%bits : %NomFDGIBI%
  REM Definition du nom pour la sortie du fichier .trace (Drive Letter\Chemin sans Drive Letter\Nom du fichier sans chemin ni extension)

  ECHO บ REPERTOIRE JEU : %NomF3text:~0,54%บ
  ECHO บ NOM FICHIER    : %NomF2text:~0,54%บ
  IF EXIST "%NomFDGIBI%" (
    ECHO บ TAILLE FICHIER : %size:~0,54%บ
  )
) ELSE (
  REM Cas ou aucun nom de fichier n'est donne
  TITLE Cast3M 20%VERSION% - %BIT%bits)

ECHO บ DATE  DEBUT    : %STARTDATE0%                                            บ
ECHO บ HEURE DEBUT    : %STARTTIME0%                                           บ

ECHO %LIGNEMIDDLE%
TYPE "%CASTEM_REP%\bin\LOGO_ASCII_%VERSION%.txt"
ECHO %LIGNEDOWN%

CALL %DEBUG% "%CASTEXEC%"
SET /A ERROLEV=%ERRORLEVEL%

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
EXIT /B !ERROLEV!

:size_file
REM Calcul la taille d'un fichier en octets passe en argument
SET size=%~z1
EXIT /B 0

:CAS_TESTS
REM Lancement de la base des Cas-Tests
ECHO.
IF "%REPERTOIRE_COURANT%"=="%CASTEM_REP%" (
  ECHO Impossible de lancer la base des cas-tests dans le repertoire d'installation
  SET /A ERROLEV=20
  EXIT /B !ERROLEV!
)

REM Preparation des repertoires de travail
IF EXIST dgibi (
  DEL /S /Q dgibi\*>nul
)
IF EXIST divers (
  DEL /S /Q divers\*>nul
)

CALL XCOPY /S /I "%CASTEM_REP%\dgibi"  dgibi >nul
CALL XCOPY /S /I "%CASTEM_REP%\divers" divers>nul

IF EXIST %castX_Local% CALL XCOPY /Y %castX_Local% dgibi>nul
IF EXIST UTILPROC      CALL XCOPY /Y UTILPROC      dgibi>nul
IF EXIST UTILNOTI      CALL XCOPY /Y UTILNOTI      dgibi>nul
CD dgibi

REM Calcul du nombre de dgibi
SET /A dgibicompt=0
FOR %%i IN (*.dgibi) DO SET /A dgibicompt+=1

REM Lancement des Cas-Tests
SET /A dgibinum=0
SET /A dgibierr=0
IF EXIST *.dgibi (
  FOR %%j IN (*.dgibi) DO (
    SET NomF=%%j
    SET NomF2=!NomF:~0,-6!
    ECHO !NomF!
    ECHO 'FIN'; | castem%VERSION% -MEM 1220 -ZERMEM -NOSWAP !NomF! > !NomF2!.res 2>&1

    REM Verifie la presence de la chaine de caractere "ARRET DU PROGRAMME GIBI NIVEAU D'ERREUR:   0" : Si elle est absente, le cas-tests a echoue
    SET /A ERROR_CASTEM=0
    for /f "delims=" %%i in ('find /C "ARRET DU PROGRAMME GIBI NIVEAU D'ERREUR:   0" !NomF2!.res ^| find /C /I "!NomF2!.res: 0"') DO SET /A ERROR_CASTEM=%%i

    IF !ERROR_CASTEM!==0 (
      SET /A dgibinum+=1
    ) ELSE (
      SET /A dgibierr+=1
      MOVE /Y !NomF2!.res !NomF2!.err>nul 2>&1
      REM ATTENTION : les espaces dans NomF3 sont importants pour la presentation
      SET NomF3=!NomF!                                                                 บ
      ECHO บ !NomF3:~0,71!บ>>ZZZ_ERROR.log)
    IF !dgibinum! GTR 0 ECHO  Cas-tests reussis : !dgibinum!/!dgibicompt!
    IF !dgibierr! GTR 0 ECHO  Cas-tests echoues : !dgibierr!/!dgibicompt!
    ECHO.
  )

  REM Affichage final apres l'execution
  ECHO %LIGNEUP%
  IF !dgibierr!==0 (
    ECHO บ               LES CAS-TESTS ONT ETE EXECUTES AVEC SUCCES               บ
  ) ELSE (
    SET /A ERROLEV=24
    SET NBR_ERROR=!dgibierr!   บ
    ECHO บ                LES !NBR_ERROR:~0,4! CAS-TESTS SUIVANTS ONT ECHOUES                 บ
    ECHO %LIGNEMIDDLE%
    TYPE ZZZ_ERROR.log
    ECHO %LIGNEMIDDLE%
    ECHO บ               Consultez les fichiers .err correspondants               บ)

  ECHO %LIGNEDOWN%
) ELSE (  
  SET /A ERROLEV=25
  ECHO.
  ECHO Aucun fichier .dgibi dans ce repertoire
  ECHO.)

EXIT /B !ERROLEV!

