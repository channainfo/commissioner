import jquery from "jquery";
import "bootstrap/js/dist/popover.js";

const $ = jquery;

document.addEventListener("spree:load", function () {
  $('[data-toggle="popover"]').popover();
});
