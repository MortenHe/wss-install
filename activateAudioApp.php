<?php
header('Access-Control-Allow-Origin: *');

//Welcher Modus soll gestartet werden
$mode = filter_input(INPUT_GET, 'mode');

//Bisherigen Prozess stoppen (Node und mplayer)
$audioServerDir = "/home/pi/mh_prog/AudioServer";
exec("sudo $audioServerDir/stopnode.sh");

//passenden Modus starten
switch ($mode) {

        //Audio Player
    case "audio":
        exec("sudo $audioServerDir/startnode.sh");
        break;

        //SH Audio Player
    case "sh":

        //Ggf. schon audioMode uebergeben, der gestartet werden soll
        $audioMode = filter_input(INPUT_GET, 'audioMode');
        $suffix = $audioMode ? " " . $audioMode : "";

        //Player starten
        exec("sudo $audioServerDir/startnodesh.sh" . $suffix);
        break;

        //Sound Quiz
    case "soundquiz":

        //Ggf. schon Spiel uebergeben, das gestartet werden soll
        $gameSelect = filter_input(INPUT_GET, 'gameSelect');
        $suffix = $gameSelect ? " " . $gameSelect : "";

        //Quiz starten
        exec("sudo $audioServerDir/startnodesound.sh" . $suffix);
        break;

        //Sound Quiz Player
    case "soundquizplayer":
        exec("sudo $audioServerDir/startnodesoundplayer.sh");
        break;
};
