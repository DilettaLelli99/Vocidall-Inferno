xquery version "3.1";

(:~ This is the default application library module of the progettotesi app.
 :
 : @author Diletta Lelli
 : @version 1.0.0
 : @see http://exist-db.org
 :)

(: Module for app-specific template functions :)
module namespace app="http://exist-db.org/apps/proget/templates";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace lib="http://exist-db.org/xquery/html-templating/lib";
import module namespace config="http://exist-db.org/apps/proget/config" at "config.xqm";



declare namespace xslt = "http://expath.org/ns/xslt";
declare namespace exslt = "http://exslt.org/common";
declare namespace exsl = "http://exslt.org/common";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";



declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace myapp="http://example.com/app";



declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";




declare function app:footer($node as node(), $model as map (*))
{
    <img src="resources/images/unipi-logo-orizz.png" id="unipilogo" alt="existdb"/>
};




(: formatta ricorsivamente i figli e sotto-figli di un enunciato espanso con exist:match ottenuto da ricerche con lucene :) 
declare
function app:formatta-match($nodo_corrente as node()) {
    let $localName := $nodo_corrente/local-name()
    return 
        (: se localName del nodo corrente è stringa vuota, è un nodo di testo semplice (non si evidenzia) :)
        if ($localName = "" ) then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            (: se localName del nodo corrente è "match", è un nodo da evidenziare :)
            if ($localName = "match" ) then
                <span class="evidenziato"> { data($nodo_corrente) } </span>
            else
                (: altrimenti (cioè per tutti gli altri tipi di nodo) si effettua la ricorsione sui figli del nodo corrente:)
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta-match($nodo_figlio)
                    }
                </span>
};

(: creo una funzione per prendere tutti gli 'u' :)

declare function app:intervista_chat($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "")
  let $xmls := collection("/db/apps/proget/xml")/*
  let $testimonianza_ := replace($testimonianza, "\s+", "_")

  let $fileXML := (
    for $xml in $xmls
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2]
    return $xml
  )
  
  let $xslt := doc("/db/apps/proget/xslt/xslt_chat.xsl")
  let $newHTML := transform:transform($fileXML, $xslt, ())
  
  return $newHTML
};

declare function app:intervista2($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "")
  let $xmls := collection("/db/apps/proget/xml")/*
  let $testimonianza_ := replace($testimonianza, "\s+", "_")

  let $fileXML := (
    for $xml in $xmls
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2]
    return $xml
  )
  
  let $xslt := doc("/db/apps/proget/xslt/xslt2.xsl")
  let $newHTML := transform:transform($fileXML, $xslt, ())
  
  return $newHTML
};


(: creo una funzione per recuperare il nome e il cognome di una persona a partire dal suo @xml:id dentro persName :)

declare function app:nome_persona_da_id($id_persona) {
    let $dati_persone := doc("/db/apps/proget/xml/Fiano_Codifica.xml")//tei:persName
    for $persona in $dati_persone 
    where $persona/@xml:id = $id_persona
    return data($persona) (: con data() si ottiene il contenuto testuale dell'elemento person, sia che sia nome / cognome o una descrizione:)
    };

(: questa funzione serve per evidenziare il fenomeno che mi interessa nell'enunciato :)    
    
declare function app:formatta_u_con_elementi($nodo_corrente as node(), $tipo as xs:string, $classe as xs:string) {
    let $localName := $nodo_corrente/local-name()
    return 
        (: se localName del nodo corrente è stringa vuota, è un nodo di testo semplice (non si evidenzia) :)
        if ($localName = "") then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            (: se localName del nodo corrente è del tipo da evidenziare, si evidenzia (via classe stile css) :)
            if ($localName = $tipo ) then
                <span class="{ $classe }"> { data($nodo_corrente) } </span>
            else
                (: altrimenti (cioè per tutti gli altri tipi di nodo) si effettua la ricorsione sui figli del nodo corrente:)
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta_u_con_elementi($nodo_figlio, $tipo, $classe)
                    }
                </span>
};

(: lavoro con il regesto in maniera dinamica e automatica :)

(: creo una funzione dinamica e automatica che mi conta quante parti del regesto ci sono :)

declare function app:contaRegesti($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo Fiano :)
  let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
  let $xmlCollection := collection("/db/apps/proget/xml")
  let $count := count(
    for $xml in $xmlCollection/*
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2] (: dove $forename = $testimonianza[1] e $surname = $testimonianza[2]. Esempio: $forename = Nedo and $surname = Fiano :)
    let $timeline := $xml//tei:timeline[@xml:id = 'TL1']
    return $timeline//tei:when
  )
  return $count
};

(: creo una funzione dinamica che per ogni "item" dentro "list", mi crea un div :)

declare function app:restituisciRegesti($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo Fiano :)
  let $xmls := collection("/db/apps/proget/xml")/* (: Ottenere tutti i documenti XML nella cartella XML :)
  let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
  
  let $fileXML := (
    for $xml in $xmls
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2] (: dove $forename = $testimonianza[1] e $surname = $testimonianza[2]. Esempio: $forename = Nedo and $surname = Fiano :)
    return $xml
  )
  
  let $list := $fileXML//tei:abstract/tei:ab/tei:list
  let $timeline := $fileXML//tei:timeline[@xml:id="TL1"]

  for $i in 1 to count($list//tei:item)
    let $audio_id := "my-audio-" || $i
    let $item := $list//tei:item[$i]
    let $synch := $item/@synch/string()
    let $xml_id := tokenize($synch, '#')[2]
    let $inizio := $timeline//tei:when[@xml:id = $xml_id]/@absolute/string()
    let $fine := if ($i < count($list//tei:item)) then
      let $synch := $list//tei:item[$i + 1]/@synch/string()
      let $xml_id := tokenize($synch, "#")[2]
      let $prossimo_inizio := $timeline//tei:when[@xml:id = $xml_id]/@absolute/string()
      return $prossimo_inizio
    else ()
    let $div := element div {
      attribute class {"regesto-" || $i},
      attribute synch {$synch},
      $item,
      element span {
        attribute class {"minuto"},
        concat("Questa parte inizia al minuto: ", $inizio, if ($fine) then concat(" e finisce al minuto: ", $fine) else (" e continua fino alla fine dell'audio."))
      },
      element audio {
        attribute id {$audio_id}, 
        attribute controls {"controls"},
        attribute data-inizio {$inizio},
        attribute data-fine {$fine},
        element source {
          attribute src {concat("http://127.0.0.1/Audio/", $testimonianza_, ".mp3")}, 
          attribute type {"audio/mpeg"}
        }
      }
    }
    return $div
};



(: creo la funzione per il catalogo. Dentro la collection "xml" ci sono i file .xml. Per ogni file, creo un div :)

declare function app:creaCatalogo($node as node(), $model as map(*)) {
  for $xml in collection("/db/apps/proget/xml")/*
  let $testimone := $xml//tei:person[@role = 'testimone']
  let $nome-format0 := concat($testimone/tei:persName/tei:forename, '_', $testimone/tei:persName/tei:surname) (: es. Nedo_Fiano :)
  let $nome-format := replace($nome-format0, '_', ' ') (: es. Nedo Fiano :)
  return
    <div class="catSing" onclick='riportaAllaTestimonianza("{$nome-format}")'>
        <h3>{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="resources/images/noimage.jpeg" id="imgcat" alt="" data-testimone="{$nome-format0}"/> 
    </div>
};


declare function app:creaTitoloCatalogo($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "")
  let $nomeFile := replace($testimonianza, "\s+", "_")
  return
      <div id="divInd">
        <h1>Testimonianza di { $testimonianza }</h1>
        <img src="resources/images/noimage.jpeg" id="imgInd" alt="{concat("Immagine di ", $testimonianza)}" data-testimone="{$nomeFile}" />
       
    </div>
};


(: creo una funzione che crea un audio HTML con la source di chi sta parlando :)

declare function app:creaAudio($node as node(), $model as map(*)) {
    let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo_Fiano :)
    let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
    return 
        <audio id="audio-intervista" controls="controls">
                <source src="{concat("http://127.0.0.1/Audio/", $testimonianza_, ".mp3")}"/>
            </audio>
};


declare function local:generaTemplate($xml as node(), $parola as xs:string) as element(template) {
  <template>
  {
    for $u in $xml//u[contains(text(), $parola)]
    return
    <enunciato>{$u}</enunciato>
  }
  </template>
};

(: funzioni per la ricerca nel catalogo :)
(: funzione id ricerca del nome :)
declare function app:cercaForename($nome as xs:string) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:persName/tei:forename = $nome] (: Itera su tutti i documenti nella collezione :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};

declare function app:cerca_catalogo_nome($node as node(), $model as map(*)) {
  let $nome := request:get-parameter("nome", "")
  let $result := app:cercaForename($nome)
  
  return
  if (exists($result)) then
    <div class="risultato">
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
          <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
          <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>
      }
    </div>
  else
    "file non presente"
};




(: funzioni ricerca cognome :)


declare function app:cercaSurname($cognome as xs:string?) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:persName/tei:surname = $cognome] (: Itera su tutti i documenti nella collezione :)
            (: Verifica se il tag surname è uguale a $cognome :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};


declare function app:cerca_catalogo_cognome($node as node(), $model as map(*)) {
    let $cognome := request:get-parameter("cognome", "")

  let $result := app:cercaSurname($cognome)

  return
  if (exists($result)) then
    <div class="risultato" >
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
        <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>

      }
    </div>
  else
    "file non presente"  (: Restituisce "file non presente" se $nome non è presente in nessun documento :)
};

(: funzioni ricerca nazionalita :)

declare function app:cercaNazionalita($nazionalita as xs:string?) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:nationality = $nazionalita] (: Itera su tutti i documenti nella collezione :)
            (: Verifica se il tag nationality è uguale a $nazionalita :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};


declare function app:cerca_catalogo_nazionalita($node as node(), $model as map(*)) {
    let $nazionalita := request:get-parameter("nazionalita", "")

  let $result := app:cercaNazionalita($nazionalita)

  return
  if (exists($result)) then
    <div class="risultato" >
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
        <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>

      }
    </div>
  else
    "file non presente"  (: Restituisce "file non presente" se $nazionalita non è presente in nessun documento :)
};


(: funzioni ricerca sesso :)

declare function app:cercaSesso($sesso as xs:string?) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:sex = $sesso] (: Itera su tutti i documenti nella collezione :)
            (: Verifica se il tag sex è uguale a $sesso :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};


declare function app:cerca_catalogo_sesso($node as node(), $model as map(*)) {
    let $sesso := request:get-parameter("sesso", "")

  let $result := app:cercaSesso($sesso)

  return
  if (exists($result)) then
    <div class="risultato" >
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
        <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>

      }
    </div>
  else
    "file non presente"  (: Restituisce "file non presente" se $sesso non è presente in nessun documento :)
};

(: funzioni ricerca annonascita :)

declare function app:cercaAnnonascita($annonascita as xs:string?) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:birth/@when = $annonascita] (: Itera su tutti i documenti nella collezione :)
            (: Verifica se il tag birth è uguale a $annonascita :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};


declare function app:cerca_catalogo_annonascita($node as node(), $model as map(*)) {
    let $annonascita := request:get-parameter("annonascita", "")

  let $result := app:cercaAnnonascita($annonascita)

  return
  if (exists($result)) then
    <div class="risultato" >
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
        <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>

      }
    </div>
  else
    "file non presente"  (: Restituisce "file non presente" se $annonascita non è presente in nessun documento :)
};

(: funzioni ricerca annomorte :)

declare function app:cercaAnnomorte($annomorte as xs:string?) as element()* {
  for $doc in collection("/db/apps/proget/xml")//tei:listPerson/tei:person[tei:death/@when = $annomorte] (: Itera su tutti i documenti nella collezione :)
            (: Verifica se il tag death è uguale a $annomorte :)
  return $doc                           (: Restituisce i documenti che soddisfano la condizione :)
};


declare function app:cerca_catalogo_annomorte($node as node(), $model as map(*)) {
    let $annomorte := request:get-parameter("annomorte", "")

  let $result := app:cercaAnnomorte($annomorte)

  return
  if (exists($result)) then
    <div class="risultato" >
      {
        for $doc in $result
        let $forename := $doc//tei:persName/tei:forename
        let $surname := $doc//tei:persName/tei:surname
        let $nome-format0 := concat($forename, '_', $surname)
        let $nome-format := replace($nome-format0, '_', ' ')
        let $imageName := concat($forename, '_', $surname, '.jpeg')
        return
        <div class="testimonianzacatalogo" onclick='riportaAllaTestimonianza("{$nome-format}")' style="background-color: #DCDCDC; color: black;">
        <h3 style="font-size: 16px;">{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="{$imageName}" id="imgcat" alt="" data-testimone="{$nome-format0}" style="width: 100px; height: 100px; border: 1px solid black;"/>
        </div>

      }
    </div>
  else
    "file non presente"  (: Restituisce "file non presente" se $annomorte non è presente in nessun documento :)
};

