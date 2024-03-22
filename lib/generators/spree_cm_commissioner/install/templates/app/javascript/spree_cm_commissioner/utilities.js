import jquery from "jquery";
import "bootstrap/js/dist/popover.js";
import "bootstrap/js/dist/tooltip.js";

const $ = jquery;

document.addEventListener("spree:load", function () {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});
