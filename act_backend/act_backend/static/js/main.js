
particlesJS.load('particles-js', 'assets/particles-config.json');


$.ajax({
  url: "assets/readme.md",
  success: function(response) {
    console.log(response);
    var converter = new showdown.Converter();
    document.getElementById("showdown-root").innerHTML = converter.makeHtml(response);
  }
});