$(document).ready(function(){
  $("img").each(function(){
    $(this).attr("src","http://ogmentapp.com/black.png");
  });

  p_c = $("p, td, th, li, span, a").get().length;

  r_p = $("p, td, th, li, span, a").get().sort(function(){
    return Math.round(Math.random())-0.5;
  }).slice(0,p_c/2);

  $(r_p).addClass("censored");
});