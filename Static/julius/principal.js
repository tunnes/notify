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