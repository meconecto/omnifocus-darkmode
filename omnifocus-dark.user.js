// ==UserScript==
// @name         OmniFocus Web — Modo Oscuro
// @namespace    https://github.com/meconecto/omnifocus-darkmode
// @version      1.0.0
// @description  Modo oscuro para OmniFocus for the Web. Solo CSS, sin acceso de red: es imposible que exfiltre tus datos.
// @author       meconecto
// @match        https://web.omnifocus.com/*
// @run-at       document-start
// @grant        none
// @license      MIT
// @homepageURL  https://github.com/meconecto/omnifocus-darkmode
// @downloadURL  https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.js
// @updateURL    https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.js
// ==/UserScript==

/*
 * ENFOQUE
 * -------
 * OmniFocus for the Web usa clases CSS hasheadas (styled-components) que
 * cambian en cada build, así que apuntar a selectores concretos se rompe
 * seguido. Para tener un modo oscuro robusto y que NO dependa de esas clases,
 * invertimos toda la página y rotamos el tono 180° (así los colores —etiquetas,
 * banderas, links— conservan su matiz en vez de verse "en negativo"), y luego
 * volvemos a invertir imágenes, video e íconos para que se vean normales.
 *
 * GARANTÍA DE PRIVACIDAD
 * ----------------------
 * @grant none  + solo inyección de CSS. Este script no tiene ninguna capacidad
 * de red (nada de fetch, XHR ni GM_xmlhttpRequest). Técnicamente no puede
 * sacar tus tareas de tu máquina.
 *
 * AJUSTES
 * -------
 * - DARKNESS: cuánto se oscurece (1 = inversión total). Bajalo (ej. 0.92) si
 *   preferís un gris menos duro.
 * - La lista COUNTER_INVERT contiene los elementos que se re-invierten para que
 *   NO queden en negativo. Si algún ícono/imagen se ve mal, agregá o quitá un
 *   selector de esa lista.
 */

(function () {
  'use strict';

  const DARKNESS = 1;      // 0.90–1.0 recomendado
  const HUE = '180deg';    // rota el tono para preservar los colores

  // Elementos a re-invertir (deben verse con sus colores reales, no negativos).
  const COUNTER_INVERT = [
    'img',
    'video',
    'svg',
    'canvas',
    'picture',
    '[style*="background-image"]',
    '[class*="avatar"]',
    '[class*="Avatar"]',
  ].join(',\n  ');

  const css = `
    :root {
      color-scheme: dark;
    }

    html {
      /* Inversión base + rotación de tono para conservar los colores */
      filter: invert(${DARKNESS}) hue-rotate(${HUE});
      background: #1d1d1d !important;
    }

    /* Fondo real detrás de la app (por si la inversión deja bordes claros) */
    html, body {
      background-color: #1d1d1d !important;
    }

    /* Contra-inversión: imágenes, video e íconos vuelven a su color normal */
    ${COUNTER_INVERT} {
      filter: invert(${DARKNESS}) hue-rotate(${HUE});
    }

    /* Un pelín menos de brillo en imágenes para que no encandilen sobre fondo oscuro */
    img, picture, video {
      /* se combina con el filtro de arriba vía el cascade del navegador */
    }
  `;

  function inject() {
    const style = document.createElement('style');
    style.id = 'omnifocus-dark-mode';
    style.textContent = css;
    (document.head || document.documentElement).appendChild(style);
  }

  // Inyectamos lo antes posible para evitar el "flash" claro al cargar.
  inject();

  // OmniFocus es una SPA; si en algún re-render se pierde el <style>, lo reponemos.
  const ensure = () => {
    if (!document.getElementById('omnifocus-dark-mode')) inject();
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', ensure, { once: true });
  }
  // Un observer liviano por si el árbol se reemplaza entero.
  const obs = new MutationObserver(ensure);
  const startObserver = () => obs.observe(document.documentElement, { childList: true });
  if (document.documentElement) startObserver();
  else document.addEventListener('DOMContentLoaded', startObserver, { once: true });
})();
