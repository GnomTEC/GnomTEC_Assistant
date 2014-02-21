-- **********************************************************************
-- GnomTEC Assistant - T_GNOMTEC_DEMO
-- Version: 5.4.2.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Templates global Constants (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Templates global variables (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------
	T_GnomTEC_Demo_Window_Header_Title:SetText("GnomTEC Templates Demonstration")
	T_GnomTEC_Demo_Window_InnerFrame_Container_Tabulator_Tab1_Title:SetText("Karte")
	T_GnomTEC_Demo_Window_InnerFrame_Container_Tabulator_Tab2_Title:SetText("EditBox")
	T_GnomTEC_Demo_Window_InnerFrame_Container_Tabulator_Tab3_Title:SetText("Messages")

	local text = [[	
Als am andern Tag Genelon sich auf den Heimweg begab, hatte Marsilias schon achthundert mit dem Tribut beladene Kamele nebst den Geiseln vorausgesandt, er selbst aber gab mit Blancandrin dem neuen Freund noch eine Strecke weit das Geleite und beschwor ihn nochmals, seinen Sinn nicht wenden.
"Sorget dafür, daß Roland bei der Nachhut bleibt!" Das war sein letztes Wort, als er ihm zum Abschied die Schlüssel Saragossas als Zeichen der Unterwerfung unter Karls Herrschaft übergab.

Genelon gelobte nochmals alles aufs feierliche und ritt nun so schnell wie möglich nach Cordova. Der Kaiser, dem die Ankunft der Karawane mit dem Tribut der Sarazenen schon gemeldet worden war, empfing den rückkehrenden Abgesandten alsbald. Er erwartete ihn auf einem grünen Rasenplatz von seinem Zelt, umgeben von den Paladinen, und empfing ihn äußerst gnädig. Genelon trug seinen Bericht mit großer Klugheit vor. "Gott hat meine Botenfahrt gesegnet," begann er, "ich bringe Euch hier die Schlüssel Saragossas und den Tribut zusamt den Geiseln, die Ihr verlangt habt. Marsilias sendet Euch ins Frankenland nachzufolgen und dort die Taufe zu empfangen, ehe noch ein Monat verflossen ist. Er wird sich Euch mit geschlossenen Händen stellen, um Hispanien als Lehen wiederum durch Euch zu empfangen; darum seid gepriesen, erhabener Herr und Kaiser, ob Eurer Weisheit, durch die der Krieg jetzo beendet ist!" Karl entgegnete: "Den hehren Herrn des Himmels wollen wir preisen, der durch deine Klugheit, edler Genelon, uns alles so wohl gelingen ließ. Auf! meine Freunde, laßt tausend Hörner durch das Kriegsheer tönen, daß jedermann erfahre: Der Krieg ist aus und heimwärts geht's nach Aachen!"

Des Kaisers Gebot wurde sogleich vollzogen, und bald war das ganze Heer zum Abzug bereit. In der Nacht, die der Heimfahrt voranging, hatte Karl merkwürdige Traumgesichte. Ihm war, als ritte er in dem großen Paß von Sizer, den Eschenspeer in seiner Rechten, da rißihm plötzlich Genelon den Schaft aus der Hand und zertrümmerte ihn an einem Felsen dermaßen, daß die Splitter auf gen Himmel flogen. Er erwachte, schlief aber bald wieder ein, und da träumte ihm nochmals. Er war in Aachen, seiner guten Stadt, da sprang ein Bär und ein Panther auf ihn zu, und der Bär biß ihn in den rechten Arm, daß der Knochen bloß lag, und vergeblich versuchte sein getreuer Hund, die Untiere zu bestehen; die Franken riefen: welch gewaltiger Kampf! Doch niemand kam zur Hilfe herbei.

Als das Frühlicht kam und der Kaiser erwachte, sann er über die Träume nach, aber er wußte keine rechte Deutung dafür zu finden, denn es kam ihm keinerlei Gedanke, daß Genelon zum Verräter geworden sei. Vor dem Wegritt hielt er noch einen Kriegsrat und sprach, auf die gewaltigen Berge und Felsen der in dunkler Ferne aufgetürmten Pyrenäen deutend: "Ihr Herrn Barone, die Pässe seht ihr und die engen Pfade, die wir durchziehen müssen, sagt an, wer soll die Nachhut, wer die Vorhut führen?"

Da waren alle darüber einig, daß Ogier von Dänemark, Olivier und Roland die besten und geeignetsten Männer hiezu wären und Genelon hob die Tüchtigkeit seines Stiefsohns Roland zu dieser Führerschaft aufs rühmlichste hervor. "Keiner von uns allen ist von solcher Kühnheit und Klugheit wie Roland," sprach er; "darum vertraut ihm die Nachhut! Dann seid Ihr sicher, daß wir alle ungefährdet in die Heimat kommen."

Als Roland seinen Stiefvater so sprechen hörte, wußte er nicht recht, was er von dieser eifrigen Lobspendung seines Widersachers halten sollte, der ihm die gefahrenreiche, aber ehrenvolle Aufgabe, die Nachhut zu führen, so ganz ausschließlich zuerkannt wissen wollte. Er neigte sich deshalb vor ihm nach Rittersitte und sprach mit kalter Höflichkeit; "Sehr schätzen muß ich Euer Wort, Herr Stiefvater, aber ich hoffe, diesem Amte, sofern es mir der Kaiser zuerkennt, gerecht zu werden und es so zu verwalten, daß kein einzig Roß, kein Maultier und kein Säumer dem Frankenheer verloren geht."

Jetzt ergriff auch der Kaiser das Wort. "Ich hätte Euch," sprach er, "zwar lieber bei mir behalten, teurer Neffe, da ich Euren Rat und Euren Arm ungern entbehre, doch zur Führung der Nachhut bedarf es des unermüdlichsten von allen Helden, denn Ihr müsset nicht nur auf die Nachzügler ein achtsam Auge haben, sondern insbesondere auch darauf, daß nicht verräterische Scharen uns in den Rücken fallen; darum will ich Euch, wenn Ihr dies ernste Amt verwalten wollt, mein halbes Heer zur Verfügung lassen."

"Nimmermehr nehme ich dies an," rief Roland, "es wäre eine Schande für mich, bedürfte ich zu meiner Sicherheit ein solch gewaltiges Heer; wir haben ja jetzt Frieden mit Marsilias, da brauche ich nicht mehr als zwanzigtausend Degen unter der Obhut Eurer Paladine, dann habt Ihr niemand zu fürchten, so lang ich lebe."

"Euer Wunsch soll erfüllt werden," sprach Karl, "wählt Euch selbst diejenigen aus, die mit Euch die Nachhut bilden sollen und stürzet Euch nicht allzu kühnlich in Gefahren! Lebt wohl auf Wiedersehen in meinem Schloß zu Aachen!"

Er umarmte und küßte den kühnen Helden und ritt nun zu Ogier von Dänemark, um diesem die Vorhut zu übergeben, worauf sich die Heerscharen in Bewegung setzten und nach wenigen Tagen die Pässe erreichten. Hoch und steil waren die Berge, die sie überstiegen, und eng und düster die Täler, die sie durchziehen mußten, aber Ogier führte die Vorhut mit großer Umsicht und ließ stets vorher die Felsschluchten und Engpässe durchsuchen, ehe die zusammengedrängten Heermassen der Franken, deren Waffenklirren und Getöse man auf fünfzehn Meilen und weiter vernahm, dieselben durchschreiten durften. Aber kein Feind zeigte sich, und so kam der größte Teil des Heers zwar mit großer Mühsal, aber doch wohlbehalten durch die Pyrenäenpässe. Bei dem letzten Paßübergang machte Karl Halt und ließ die Scharen nochmals an sich vorüberziehen. Er war ernst gestimmt und seine Stirne erschien gefurcht und sorgenvoll, so daß der Herzog Reimes, der neben ihm hoch zu Roß hielt, ihm um seinen Kummer frug. Da vertraute ihm Karl sein Leid, indem er sprach: "Mich warnte heute Nacht im Traume ein Engel vor Genelon, der uns noch schweres Herzeleid bringen wird. Ich war zu sorglos, als ich Rolands kühnem Verlangen, nur zwanzigtausend Mann bei ihm und den Paladinen zurückzulassen, nachgab; Genelon haßt ihn, und seine Tücke wird ihn und die andern mit Hilfe der Sarazenen zu verderben suchen. Jetzt ist mir der Traum mit dem zersplitterten Speer klar. Auf Genelon geht er, der mir Roland rauben will, den Speer und Hort des Frankenreichs."

Roland befand sich zu dieser Zeit zu Ronceval im Pyrenäental, und mit ihm seine Freunde und Kampfgenossen, die Paladine Olivier, Gerin, Otfried, Berengar, Graf Gere, Samson, der alte Anseis, Gerhard von Roussillon, Herzog Engelir, Graf Walter und Erzbischof Turpin. Die Helden hatten alle Vorsichtsmaßregeln getroffen, um gegen unvermutete Überfälle geschützt zu sein, und Roland seinen Freund, den wegekundigen Walter, gebeten mit tausend Mann die wichtigsten Pässe und die Hügel zu besetzen und alsbald Nachricht ins Lager kommen zu lassen, wenn sich unvermutet Feinde zeigen sollten.
]]
	T_GnomTEC_Demo_Window_InnerFrame_Container_InnerFrame_EditBox_Text:SetText(text)

	T_GnomTEC_Demo_Window_InnerFrame_Container_InnerFrame_Messages_Text:AddMessage("Demonstration eines Messageframes",1.0,1.0,0.0)
	for i=1, 10 do
		T_GnomTEC_Demo_Window_InnerFrame_Container_InnerFrame_Messages_Text:AddMessage("Eintrag Nummer "..i,0.8,0.8,0.8)
	end
	


-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Frame event handler and functions
-- ----------------------------------------------------------------------
