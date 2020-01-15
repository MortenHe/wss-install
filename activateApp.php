<?php
header('Access-Control-Allow-Origin: *');

//Welcher Modus soll gestartet werden
$mode = filter_input(INPUT_GET, 'mode');

//Bisherigen Prozess stoppen (Node und mplayer)
exec('sudo /home/pi/mh_prog/AudioServer/stopnode.sh');

//passenden Modus starten
switch ($mode) {

//Audio Player
case "audio":

    //Player merken fuer naechsten Autostart und Player starten
    $command = "sudo /home/pi/mh_prog/AudioServer/startnode.sh";
    writePlayerAutostartFile($command);
    exec($command);
    break;

//SH Audio Player
case "sh":

    //Ggf. schon audioMode uebergeben, der gestartet werden soll
    $audioMode = filter_input(INPUT_GET, 'audioMode');
    $suffix = $audioMode ? " " . $audioMode : "";

    //Player merken fuer naechsten Autostart und Player starten
    $command = "sudo /home/pi/mh_prog/NewSHAudioServer/startnodesh.sh" . $suffix;
    writePlayerAutostartFile($command);
    exec($command);
    break;

//Sound Quiz
case "soundquiz":

    //Ggf. schon Spiel uebergeben, das gestartet werden soll
    $gameSelect = filter_input(INPUT_GET, 'gameSelect');
    $suffix = $gameSelect ? " " . $gameSelect : "";

    exec('sudo /home/pi/mh_prog/SoundQuizServer/startnodesound.sh' . $suffix);
    break;

//Sound Quiz Player
case "soundquizplayer":
    exec('sudo /home/pi/mh_prog/SoundQuizServer/startnodesoundplayer.sh' . $suffix);
    break;
};

//Letzter Player in Datei schreiben fuer naechsten Autostart
function writePlayerAutostartFile($command) {
    $file = '/home/pi/last-player';
    $handle = fopen($file, 'w') or die('Cannot open file:  ' . $file);
    fwrite($handle, "AUTOSTART=" . $command);
    fclose($handle);
}
?>