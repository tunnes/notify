<<<<<<< HEAD
function ola(){
    alert("Ola")
}
=======
function navBUG(){
    $('nav_affix').offset({ //sticky header at bottom of bg
        offset: {
          top: $("#headerID").height()
        }
    });
}

$(document).ready(function(){
    $(window).resize(function(){
        navBUG();
        console.log($("#headerID").height());
    });
});
>>>>>>> e40e84f2b74a16a4e82cef22c395ba5f630a8afa
