function selezionaLegenda() {
  var select = document.getElementById("legendaSelect");
  var scelta = select.value;
  var contenutoLegenda = document.getElementById("contenutoLegenda");
  var divchat = document.getElementsByClassName("intervistachat");
  var div2 = document.getElementsByClassName("intervista2");

  // Nascondi tutti i div chat e div2
  for (var i = 0; i < divchat.length; i++) {
    divchat[i].style.display = "none";
  }
  for (var i = 0; i < div2.length; i++) {
    div2[i].style.display = "none";
  }
  
  // Nascondi il contenuto precedente della legenda
  contenutoLegenda.style.display = "none";

  if (scelta == "legendachat") {
    // Inserisci il contenuto per Legenda 1
    contenutoLegenda.innerHTML = "<h2>Legenda CHAT</h2> <ul> <li>Registrazione non chiara: [?]</li> <li>Parte mancante: xxx</li> <li>tono in crescendo: ↑ </li> <li>pausa: (..)</li></ul>";
    contenutoLegenda.style.display = "block"; // Mostra il contenuto della legenda
    for (var i = 0; i < divchat.length; i++) {
      divchat[i].style.display = "block"; // Mostra i div chat
    }
  } else if (scelta == "legenda2") {
    // Inserisci il contenuto per Legenda 2
    contenutoLegenda.innerHTML = "<h2>Legenda DT1</h2><ul> <li>Registrazione non chiara: xxx</li> <li>tono in crescendo: /</li> <li>pausa: ...</li>";
    contenutoLegenda.style.display = "block"; // Mostra il contenuto della legenda
    for (var i = 0; i < div2.length; i++) {
      div2[i].style.display = "block"; // Mostra i div2
    }
  } 


  }


function nascondiTutti() {
  var divchat = document.getElementsByClassName("intervistachat");
  var div2 = document.getElementsByClassName("intervista2");
  var contenutoLegenda = document.getElementById("contenutoLegenda");

  // Nascondi tutti i div chat e div2
  for (var i = 0; i < divchat.length; i++) {
    divchat[i].style.display = "none";
  }
  for (var i = 0; i < div2.length; i++) {
    div2[i].style.display = "none";
  }

  // Nascondi il contenuto della legenda
  contenutoLegenda.style.display = "none";
}
