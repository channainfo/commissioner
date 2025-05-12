import jquery from "jquery";
import "bootstrap/js/dist/popover.js";

const $ = jquery;

document.addEventListener("spree:load", function () {
  $('[data-toggle="popover"]').popover();
});

document.documentElement.addEventListener("turbo:frame-load", (event) => {
  $('[data-toggle="popover"]').popover();
});
