document.addEventListener("DOMContentLoaded", function () {

  const btn = document.createElement("button");
  btn.id = "backToTop";
  btn.innerHTML = "↑ Back To Top";
  document.body.appendChild(btn);

  window.addEventListener("scroll", function () {
    btn.style.display = window.scrollY > 200 ? "block" : "none";
  });

  btn.onclick = function () {
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

});